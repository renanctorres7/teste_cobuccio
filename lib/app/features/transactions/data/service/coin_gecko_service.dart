import 'package:dio/dio.dart';

final class CoinGeckoService {
  const CoinGeckoService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getMarketChart({
    required String coinId,
    required String vsCurrency,
    required int days,
    CancelToken? cancelToken,
  }) {
    return _dio.get<dynamic>(
      '/coins/$coinId/market_chart',
      queryParameters: {
        'vs_currency': vsCurrency,
        'days': days,
      },
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> getSimplePrice({
    required String coinId,
    required String vsCurrency,
    CancelToken? cancelToken,
  }) {
    return _dio.get<dynamic>(
      '/simple/price',
      queryParameters: {
        'ids': coinId,
        'vs_currencies': vsCurrency,
      },
      cancelToken: cancelToken,
    );
  }
}
