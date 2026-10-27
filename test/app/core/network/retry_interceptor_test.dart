import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/network/retry_interceptor.dart';

class _SequenceAdapter implements HttpClientAdapter {
  _SequenceAdapter(this._statuses);

  final List<({int status, Map<String, List<String>>? headers})> _statuses;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final index = calls;
    calls++;
    final entry = _statuses[index.clamp(0, _statuses.length - 1)];
    return ResponseBody.fromString(
      jsonEncode({'ok': entry.status == 200}),
      entry.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...?entry.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late List<Duration> slept;
  late Dio dio;

  Dio buildDio({
    required List<({int status, Map<String, List<String>>? headers})> statuses,
    int maxRetries = 3,
    Random? random,
  }) {
    slept = <Duration>[];
    final client = Dio(BaseOptions(baseUrl: 'https://example.test'));
    client.httpClientAdapter = _SequenceAdapter(statuses);
    client.interceptors.add(
      RetryInterceptor(
        dio: client,
        maxRetries: maxRetries,
        baseDelay: const Duration(milliseconds: 100),
        maxDelay: const Duration(seconds: 2),
        random: random ?? Random(0),
        sleeper: (duration) async {
          slept.add(duration);
        },
      ),
    );
    return client;
  }

  test('retries on 429 then succeeds', () async {
    dio = buildDio(
      statuses: [
        (status: 429, headers: null),
        (status: 200, headers: null),
      ],
    );

    final response = await dio.get<dynamic>('/ping');

    expect(response.statusCode, 200);
    expect((dio.httpClientAdapter as _SequenceAdapter).calls, 2);
    expect(slept, hasLength(1));
  });

  test('respects Retry-After header in seconds', () async {
    dio = buildDio(
      statuses: [
        (
          status: 429,
          headers: {
            'retry-after': ['2'],
          },
        ),
        (status: 200, headers: null),
      ],
    );

    await dio.get<dynamic>('/ping');

    expect(slept, [const Duration(seconds: 2)]);
  });

  test('stops after maxRetries and surfaces last 429', () async {
    dio = buildDio(
      maxRetries: 2,
      statuses: [
        (status: 429, headers: null),
        (status: 429, headers: null),
        (status: 429, headers: null),
      ],
    );

    await expectLater(
      dio.get<dynamic>('/ping'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          429,
        ),
      ),
    );

    // 1 original + 2 retries
    expect((dio.httpClientAdapter as _SequenceAdapter).calls, 3);
    expect(slept, hasLength(2));
  });

  test('does not retry non-transient client errors', () async {
    dio = buildDio(
      statuses: [
        (status: 404, headers: null),
      ],
    );

    await expectLater(
      dio.get<dynamic>('/missing'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          404,
        ),
      ),
    );

    expect((dio.httpClientAdapter as _SequenceAdapter).calls, 1);
    expect(slept, isEmpty);
  });

  test('retries transient 503 then succeeds', () async {
    dio = buildDio(
      statuses: [
        (status: 503, headers: null),
        (status: 200, headers: null),
      ],
    );

    final response = await dio.get<dynamic>('/ping');

    expect(response.statusCode, 200);
    expect((dio.httpClientAdapter as _SequenceAdapter).calls, 2);
    expect(slept, hasLength(1));
  });

  test('resolveDelay uses exponential backoff when Retry-After is absent', () {
    final interceptor = RetryInterceptor(
      dio: Dio(),
      baseDelay: const Duration(milliseconds: 100),
      maxDelay: const Duration(seconds: 8),
      random: Random(0),
    );

    final first = interceptor.resolveDelay(attempt: 0, retryAfter: null);
    final second = interceptor.resolveDelay(attempt: 1, retryAfter: null);

    expect(first.inMilliseconds, greaterThanOrEqualTo(100));
    expect(second.inMilliseconds, greaterThanOrEqualTo(200));
    expect(second.inMilliseconds, greaterThan(first.inMilliseconds));
  });

  test('resolveDelay prefers Retry-After over backoff', () {
    final interceptor = RetryInterceptor(
      dio: Dio(),
      baseDelay: const Duration(milliseconds: 100),
      maxDelay: const Duration(seconds: 8),
      random: Random(0),
    );

    expect(
      interceptor.resolveDelay(
        attempt: 0,
        retryAfter: const Duration(seconds: 3),
      ),
      const Duration(seconds: 3),
    );
  });

  test('resolveDelay caps Retry-After at maxDelay', () {
    final interceptor = RetryInterceptor(
      dio: Dio(),
      maxDelay: const Duration(seconds: 2),
      random: Random(0),
    );

    expect(
      interceptor.resolveDelay(
        attempt: 0,
        retryAfter: const Duration(seconds: 30),
      ),
      const Duration(seconds: 2),
    );
  });
}
