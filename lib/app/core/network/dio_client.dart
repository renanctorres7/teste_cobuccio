import 'package:dio/dio.dart';
import 'package:teste_cobuccio/app/core/configs/env_keys.dart';

abstract final class DioClient {
  static Dio create() {
    const baseUrlRaw = String.fromEnvironment(
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
        baseUrl: _resolveBaseUrl(baseUrlRaw),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: headers,
      ),
    );
  }

  static String _resolveBaseUrl(String raw) {
    const fallback = 'https://api.coingecko.com/api/v3';
    if (raw.isEmpty) {
      return fallback;
    }

    final withoutQuery = raw.split('?').first;
    final apiIndex = withoutQuery.indexOf('/api/v3');
    if (apiIndex != -1) {
      return withoutQuery.substring(0, apiIndex + '/api/v3'.length);
    }

    if (withoutQuery.endsWith('/')) {
      return withoutQuery.substring(0, withoutQuery.length - 1);
    }
    return withoutQuery;
  }
}
