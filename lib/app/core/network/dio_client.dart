import 'package:dio/dio.dart';
import 'package:teste_cobuccio/app/core/configs/env_keys.dart';

abstract final class DioClient {
  static Dio create() {
    const baseUrl = String.fromEnvironment(
      EnvKeys.apiBaseUrl,
      defaultValue: 'https://api.coingecko.com/api/v3',
    );
    const apiKey = String.fromEnvironment(EnvKeys.apiKey);

    final headers = <String, dynamic>{
      Headers.contentTypeHeader: Headers.jsonContentType,
      Headers.acceptHeader: Headers.jsonContentType,
    };

    if (apiKey.isNotEmpty) {
      headers['x-cg-demo-api-key'] = apiKey;
    }

    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: headers,
      ),
    );
  }
}
