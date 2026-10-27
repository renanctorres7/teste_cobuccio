import 'package:dio/dio.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/coin_price_model.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/market_chart_model.dart';

abstract interface class CoinMarketDatasource {
  Future<MarketChartModel> getMarketChart({
    required String coinId,
    required String vsCurrency,
    required int days,
    CancelToken? cancelToken,
  });

  Future<CoinPriceModel> getSimplePrice({
    required String coinId,
    required String vsCurrency,
    CancelToken? cancelToken,
  });
}
