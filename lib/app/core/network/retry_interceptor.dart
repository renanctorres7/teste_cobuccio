import 'dart:math';

import 'package:dio/dio.dart';

/// Retries failed requests on rate-limit (429) and selected transient 5xx
/// responses, using exponential backoff with jitter.
///
/// When the response includes a `Retry-After` header, that value is preferred
/// over the computed backoff (still capped by [maxDelay]).
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 8),
    this.retryStatusCodes = const {429, 500, 502, 503, 504},
    Random? random,
    Future<void> Function(Duration duration)? sleeper,
  })  : _random = random ?? Random(),
        _sleeper = sleeper ?? Future<void>.delayed;

  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;
  final Set<int> retryStatusCodes;
  final Random _random;
  final Future<void> Function(Duration duration) _sleeper;

  /// Dio that shares the parent adapter/options but has no interceptors,
  /// so retries do not re-enter this interceptor.
  Dio _retryClient() {
    return Dio(dio.options)..httpClientAdapter = dio.httpClientAdapter;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final client = _retryClient();
    var current = err;

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      if (!_shouldRetry(current)) {
        break;
      }

      final delay = resolveDelay(
        attempt: attempt,
        retryAfter: _parseRetryAfter(current.response?.headers),
      );
      await _sleeper(delay);

      try {
        final response = await client.fetch<dynamic>(current.requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryError) {
        current = retryError;
      }
    }

    return handler.next(current);
  }

  bool _shouldRetry(DioException err) {
    if (err.type != DioExceptionType.badResponse) {
      return false;
    }
    final statusCode = err.response?.statusCode;
    if (statusCode == null) {
      return false;
    }
    return retryStatusCodes.contains(statusCode);
  }

  /// Public for unit tests: delay for [attempt] (0-based) given optional
  /// [retryAfter] from the response headers.
  Duration resolveDelay({
    required int attempt,
    Duration? retryAfter,
  }) {
    if (retryAfter != null && retryAfter > Duration.zero) {
      return retryAfter < maxDelay ? retryAfter : maxDelay;
    }

    final exponentialMs = baseDelay.inMilliseconds * (1 << attempt);
    final cappedMs = min(exponentialMs, maxDelay.inMilliseconds);
    final jitterMs = _random.nextInt(max(1, cappedMs ~/ 4) + 1);
    return Duration(milliseconds: cappedMs + jitterMs);
  }

  static Duration? _parseRetryAfter(Headers? headers) {
    if (headers == null) {
      return null;
    }

    final raw = headers.value('retry-after');
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final seconds = int.tryParse(raw.trim());
    if (seconds != null && seconds >= 0) {
      return Duration(seconds: seconds);
    }

    final date = DateTime.tryParse(raw);
    if (date != null) {
      final delta = date.difference(DateTime.now().toUtc());
      return delta.isNegative ? Duration.zero : delta;
    }

    return null;
  }
}
