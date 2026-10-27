import 'package:dio/dio.dart';
import 'package:teste_cobuccio/app/features/transactions/data/service/coin_gecko_service.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/datasources/coin_market_datasource.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/coin_price_model.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/market_chart_model.dart';

final class DioCoinMarketDatasource implements CoinMarketDatasource {
  const DioCoinMarketDatasource(this._service);

  final CoinGeckoService _service;

  @override
  Future<MarketChartModel> getMarketChart({
    required String coinId,
    required String vsCurrency,
    required int days,
    CancelToken? cancelToken,
  }) async {
    final response = await _service.getMarketChart(
      coinId: coinId,
      vsCurrency: vsCurrency,
      days: days,
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid market chart response');
    }
    return MarketChartModel.fromJson(data);
  }

  @override
  Future<CoinPriceModel> getSimplePrice({
    required String coinId,
    required String vsCurrency,
    CancelToken? cancelToken,
  }) async {
    final response = await _service.getSimplePrice(
      coinId: coinId,
      vsCurrency: vsCurrency,
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid simple price response');
    }
    return CoinPriceModel.fromSimplePriceJson(
      data,
      coinId: coinId,
      vsCurrency: vsCurrency,
    );
  }
}
