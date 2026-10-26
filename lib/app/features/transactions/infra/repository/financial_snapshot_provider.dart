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

  Future<Result<FinancialSnapshot>> getSnapshot({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _memory != null) {
      return Success(_memory!);
    }

    try {
      final chart = await _datasource.getMarketChart(
        coinId: coinId,
        vsCurrency: vsCurrency,
        days: days,
      );
      final price = await _datasource.getSimplePrice(
        coinId: coinId,
        vsCurrency: vsCurrency,
      );

      await _cache.save(chart: chart, price: price.price);

      final snapshot = FinancialSnapshot(
        balance: CoinMarketMapper.balanceFromPrice(price.price),
        transactions: CoinMarketMapper.fromMarketChart(chart, coinId: coinId),
      );
      _memory = snapshot;
      return Success(snapshot);
    } catch (error) {
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
    }
  }

  void clearMemory() {
    _memory = null;
  }
}
