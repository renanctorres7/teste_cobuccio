import 'package:dio/dio.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';
import 'package:teste_cobuccio/app/core/network/dio_exception_mapper.dart';
import 'package:teste_cobuccio/app/features/transactions/data/cache/transactions_local_cache.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/datasources/coin_market_datasource.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/mappers/coin_market_mapper.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/financial_snapshot.dart';

final class FinancialSnapshotProvider {
  FinancialSnapshotProvider({
    required this._datasource,
    required this._cache,
    this.coinId = 'bitcoin',
    this.vsCurrency = 'brl',
    this.days = 30,
  });

  final CoinMarketDatasource _datasource;
  final TransactionsLocalCache _cache;
  final String coinId;
  final String vsCurrency;
  final int days;

  FinancialSnapshot? _memory;
  Future<Result<FinancialSnapshot>>? _inFlight;
  CancelToken? _cancelToken;

  Future<Result<FinancialSnapshot>> getSnapshot({
    bool forceRefresh = false,
  }) {
    if (forceRefresh) {
      clearMemory();
    } else if (_memory != null) {
      return Future.value(Success(_memory!));
    }

    final existing = _inFlight;
    if (existing != null) {
      return existing;
    }

    final token = CancelToken();
    _cancelToken = token;
    final future = _load(token);
    _inFlight = future;
    return future;
  }

  Future<Result<FinancialSnapshot>> _load(CancelToken token) async {
    try {
      final chart = await _datasource.getMarketChart(
        coinId: coinId,
        vsCurrency: vsCurrency,
        days: days,
        cancelToken: token,
      );
      final price = await _datasource.getSimplePrice(
        coinId: coinId,
        vsCurrency: vsCurrency,
        cancelToken: token,
      );

      if (token.isCancelled) {
        return Error(DioExceptionMapper.map(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.cancel,
            message: 'Request cancelled',
          ),
        ));
      }

      await _cache.save(chart: chart, price: price.price);

      final snapshot = FinancialSnapshot(
        balance: CoinMarketMapper.balanceFromPrice(price.price),
        transactions: CoinMarketMapper.fromMarketChart(chart, coinId: coinId),
      );
      _memory = snapshot;
      return Success(snapshot);
    } catch (error) {
      // Obsolete request: do not write memory/cache fallback for a superseded call.
      if (token.isCancelled) {
        return Error(DioExceptionMapper.map(error));
      }

      final cached = _cache.read();
      if (cached != null) {
        final snapshot = FinancialSnapshot(
          balance: CoinMarketMapper.balanceFromPrice(cached.price),
          transactions: CoinMarketMapper.fromMarketChart(
            cached.chart,
            coinId: coinId,
          ),
          isFromCache: true,
        );
        _memory = snapshot;
        return Success(snapshot);
      }

      return Error(DioExceptionMapper.map(error));
    } finally {
      if (identical(_cancelToken, token)) {
        _inFlight = null;
        _cancelToken = null;
      }
    }
  }

  /// Clears memory and cancels any in-flight network request (e.g. forceRefresh).
  void clearMemory() {
    _cancelInFlight();
    _memory = null;
  }

  /// Cancels the in-flight request without clearing cached memory.
  /// Useful on Cubit dispose when the provider is not shared, or for tests.
  void cancelInFlight() {
    _cancelInFlight();
  }

  void _cancelInFlight() {
    final token = _cancelToken;
    if (token != null && !token.isCancelled) {
      token.cancel('superseded');
    }
    _cancelToken = null;
    _inFlight = null;
  }
}
