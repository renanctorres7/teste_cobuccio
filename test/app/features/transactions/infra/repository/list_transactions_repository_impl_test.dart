import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';
import 'package:teste_cobuccio/app/features/transactions/data/cache/transactions_local_cache.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/datasources/coin_market_datasource.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/coin_price_model.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/market_chart_model.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/financial_snapshot_provider.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/list_transactions_repository_impl.dart';

import '../../../../../helpers/fakes.dart';

class _FakeDatasource implements CoinMarketDatasource {
  _FakeDatasource({
    this.chart,
    this.price,
    this.error,
  });

  MarketChartModel? chart;
  CoinPriceModel? price;
  Object? error;

  @override
  Future<MarketChartModel> getMarketChart({
    required String coinId,
    required String vsCurrency,
    required int days,
    CancelToken? cancelToken,
  }) async {
    if (error != null) {
      throw error!;
    }
    return chart!;
  }

  @override
  Future<CoinPriceModel> getSimplePrice({
    required String coinId,
    required String vsCurrency,
    CancelToken? cancelToken,
  }) async {
    if (error != null) {
      throw error!;
    }
    return price!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  MarketChartModel sampleChart() {
    return const MarketChartModel(
      prices: [
        MarketChartPointModel(timestampMs: 1_000, price: 100),
        MarketChartPointModel(timestampMs: 2_000, price: 120),
        MarketChartPointModel(timestampMs: 3_000, price: 90),
      ],
    );
  }

  test('lists mapped transactions on success', () async {
    final datasource = _FakeDatasource(
      chart: sampleChart(),
      price: const CoinPriceModel(coinId: 'bitcoin', price: 100),
    );
    final provider = FinancialSnapshotProvider(
      datasource: datasource,
      cache: TransactionsLocalCache(prefs),
      networkInfo: FakeNetworkInfo(),
    );
    final repository = ListTransactionsRepositoryImpl(provider);

    final result = await repository.list(limit: 10);

    expect(result.isSuccess, isTrue);
    final page = (result as Success).data;
    expect(page.items, hasLength(2));
    expect(page.items.first.type, TransactionTypeEnum.expense);
    expect(page.hasMore, isFalse);
    expect(page.isFromCache, isFalse);
  });

  test('falls back to cache when network fails', () async {
    final cache = TransactionsLocalCache(prefs);
    await cache.save(chart: sampleChart(), price: 100);

    final datasource = _FakeDatasource(
      error: DioException(
        requestOptions: RequestOptions(path: '/coins/bitcoin/market_chart'),
        type: DioExceptionType.connectionError,
      ),
    );
    final provider = FinancialSnapshotProvider(
      datasource: datasource,
      cache: cache,
      networkInfo: FakeNetworkInfo(),
    );
    final repository = ListTransactionsRepositoryImpl(provider);

    final result = await repository.list();

    expect(result.isSuccess, isTrue);
    final page = (result as Success).data;
    expect(page.items, isNotEmpty);
    expect(page.isFromCache, isTrue);
  });

  test('returns failure when network fails and cache is empty', () async {
    final datasource = _FakeDatasource(
      error: DioException(
        requestOptions: RequestOptions(path: '/coins/bitcoin/market_chart'),
        type: DioExceptionType.connectionError,
      ),
    );
    final provider = FinancialSnapshotProvider(
      datasource: datasource,
      cache: TransactionsLocalCache(prefs),
      networkInfo: FakeNetworkInfo(),
    );
    final repository = ListTransactionsRepositoryImpl(provider);

    final result = await repository.list();

    expect(result.isFailure, isTrue);
    expect((result as Error).failure, isA<NetworkFailure>());
  });
}
