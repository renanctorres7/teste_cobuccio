import 'package:dio/dio.dart';

final class CoinGeckoService {
  const CoinGeckoService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getMarketChart({
    required String coinId,
    required String vsCurrency,
    required int days,
  }) {
    return _dio.get<dynamic>(
      '/coins/$coinId/market_chart',
      queryParameters: {
        'vs_currency': vsCurrency,
        'days': days,
      },
    );
  }

  Future<Response<dynamic>> getSimplePrice({
    required String coinId,
    required String vsCurrency,
  }) {
    return _dio.get<dynamic>(
      '/simple/price',
      queryParameters: {
        'ids': coinId,
        'vs_currencies': vsCurrency,
      },
    );
  }
}
