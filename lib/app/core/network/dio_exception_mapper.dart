import 'package:dio/dio.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';

abstract final class DioExceptionMapper {
  static Failure map(Object error) {
    if (error is! DioException) {
      return UnexpectedFailure(message: error.toString());
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.transformTimeout:
        return NetworkFailure(message: error.message);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 429) {
          return RateLimitFailure(message: error.message);
        }
        return ServerFailure(message: error.message, statusCode: statusCode);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return UnexpectedFailure(message: error.message);
    }
  }
}
