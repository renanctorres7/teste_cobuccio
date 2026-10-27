import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';
import 'package:teste_cobuccio/app/features/transactions/data/cache/transactions_local_cache.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/datasources/coin_market_datasource.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/coin_price_model.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/financial_snapshot.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/market_chart_model.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/financial_snapshot_provider.dart';

import '../../../../../helpers/fakes.dart';

class _ControllableDatasource implements CoinMarketDatasource {
  _ControllableDatasource({
    this.chart,
    this.price,
  });

  MarketChartModel? chart;
  CoinPriceModel? price;

  var marketChartCalls = 0;
  var simplePriceCalls = 0;
  CancelToken? lastCancelToken;

  Completer<void>? _gate;

  void hold() {
    _gate = Completer<void>();
  }

  void release() {
    _gate?.complete();
    _gate = null;
  }

  Future<void> _waitIfHeld(CancelToken? cancelToken) async {
    final gate = _gate;
    if (gate == null) {
      return;
    }

    if (cancelToken == null) {
      await gate.future;
      return;
    }

    // Race release vs cancel without completing the shared gate on cancel,
    // so a replacement request can still wait on the same hold.
    final cancelled = Completer<void>();
    cancelToken.whenCancel.then((_) {
      if (!cancelled.isCompleted) {
        cancelled.complete();
      }
    });

    await Future.any([gate.future, cancelled.future]);
    _throwIfCancelled(cancelToken);
  }

  void _throwIfCancelled(CancelToken? cancelToken) {
    if (cancelToken == null || !cancelToken.isCancelled) {
      return;
    }
    throw DioException(
      requestOptions: RequestOptions(),
      type: DioExceptionType.cancel,
      message: 'cancelled',
    );
  }

  @override
  Future<MarketChartModel> getMarketChart({
    required String coinId,
    required String vsCurrency,
    required int days,
    CancelToken? cancelToken,
  }) async {
    marketChartCalls++;
    lastCancelToken = cancelToken;
    await _waitIfHeld(cancelToken);
    _throwIfCancelled(cancelToken);
    return chart!;
  }

  @override
  Future<CoinPriceModel> getSimplePrice({
    required String coinId,
    required String vsCurrency,
    CancelToken? cancelToken,
  }) async {
    simplePriceCalls++;
    lastCancelToken = cancelToken;
    await _waitIfHeld(cancelToken);
    _throwIfCancelled(cancelToken);
    return price!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late _ControllableDatasource datasource;
  late FakeNetworkInfo networkInfo;
  late FinancialSnapshotProvider provider;

  MarketChartModel sampleChart({double secondPrice = 120}) {
    return MarketChartModel(
      prices: [
        const MarketChartPointModel(timestampMs: 1_000, price: 100),
        MarketChartPointModel(timestampMs: 2_000, price: secondPrice),
        const MarketChartPointModel(timestampMs: 3_000, price: 90),
      ],
    );
  }

  FinancialSnapshotProvider buildProvider({
    TransactionsLocalCache? cache,
    FakeNetworkInfo? network,
  }) {
    return FinancialSnapshotProvider(
      datasource: datasource,
      cache: cache ?? TransactionsLocalCache(prefs),
      networkInfo: network ?? networkInfo,
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    networkInfo = FakeNetworkInfo();
    datasource = _ControllableDatasource(
      chart: sampleChart(),
      price: const CoinPriceModel(coinId: 'bitcoin', price: 100),
    );
    provider = buildProvider();
  });

  test('coalesces concurrent getSnapshot into one network round-trip', () async {
    datasource.hold();

    final first = provider.getSnapshot();
    final second = provider.getSnapshot();

    expect(identical(first, second), isTrue);

    // Yield so the async online check can reach the datasource hold.
    await Future<void>.delayed(Duration.zero);
    expect(datasource.marketChartCalls, 1);

    datasource.release();

    final results = await Future.wait([first, second]);
    expect(results[0].isSuccess, isTrue);
    expect(results[1].isSuccess, isTrue);
    expect(datasource.marketChartCalls, 1);
    expect(datasource.simplePriceCalls, 1);
  });

  test('returns memory snapshot without hitting network again', () async {
    await provider.getSnapshot();
    expect(datasource.marketChartCalls, 1);

    final again = await provider.getSnapshot();
    expect(again.isSuccess, isTrue);
    expect(datasource.marketChartCalls, 1);
  });

  test('forceRefresh cancels in-flight request and starts a new one', () async {
    datasource.hold();

    final obsolete = provider.getSnapshot();
    await Future<void>.delayed(Duration.zero);
    expect(datasource.marketChartCalls, 1);
    final obsoleteToken = datasource.lastCancelToken;

    datasource.chart = sampleChart(secondPrice: 150);
    datasource.price = const CoinPriceModel(coinId: 'bitcoin', price: 200);

    final refreshed = provider.getSnapshot(forceRefresh: true);
    expect(obsoleteToken?.isCancelled, isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(datasource.marketChartCalls, 2);

    datasource.release();

    final obsoleteResult = await obsolete;
    final refreshedResult = await refreshed;

    expect(obsoleteResult.isFailure, isTrue);
    expect((obsoleteResult as Error).failure, isA<UnexpectedFailure>());

    expect(refreshedResult.isSuccess, isTrue);
    final snapshot = (refreshedResult as Success<FinancialSnapshot>).data;
    expect(snapshot.balance.cents, 20000);
    expect(snapshot.isFromCache, isFalse);
  });

  test('clearMemory cancels in-flight request', () async {
    datasource.hold();

    final inFlight = provider.getSnapshot();
    await Future<void>.delayed(Duration.zero);
    final token = datasource.lastCancelToken;

    provider.clearMemory();
    expect(token?.isCancelled, isTrue);

    datasource.release();

    final result = await inFlight;
    expect(result.isFailure, isTrue);
  });

  test('cancelled request does not overwrite memory with cache fallback', () async {
    final cache = TransactionsLocalCache(prefs);
    await cache.save(chart: sampleChart(), price: 50);
    provider = buildProvider(cache: cache);

    datasource.hold();
    final obsolete = provider.getSnapshot();
    await Future<void>.delayed(Duration.zero);

    provider.clearMemory();
    datasource.release();
    await obsolete;

    datasource.chart = sampleChart(secondPrice: 180);
    datasource.price = const CoinPriceModel(coinId: 'bitcoin', price: 300);
    final next = await provider.getSnapshot();

    expect(next.isSuccess, isTrue);
    final snapshot = (next as Success<FinancialSnapshot>).data;
    expect(snapshot.balance.cents, 30000);
    expect(snapshot.isFromCache, isFalse);
  });

  test('offline with cache returns isFromCache without hitting network', () async {
    final cache = TransactionsLocalCache(prefs);
    await cache.save(chart: sampleChart(), price: 50);
    networkInfo.online = false;
    provider = buildProvider(cache: cache);

    final result = await provider.getSnapshot();

    expect(result.isSuccess, isTrue);
    final snapshot = (result as Success<FinancialSnapshot>).data;
    expect(snapshot.isFromCache, isTrue);
    expect(snapshot.balance.cents, 5000);
    expect(datasource.marketChartCalls, 0);
    expect(datasource.simplePriceCalls, 0);
  });

  test('offline without cache returns NetworkFailure without hitting network',
      () async {
    networkInfo.online = false;
    provider = buildProvider();

    final result = await provider.getSnapshot();

    expect(result.isFailure, isTrue);
    expect((result as Error).failure, isA<NetworkFailure>());
    expect(datasource.marketChartCalls, 0);
    expect(datasource.simplePriceCalls, 0);
  });
}
