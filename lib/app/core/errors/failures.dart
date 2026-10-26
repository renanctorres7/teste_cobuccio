import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.message});
}

final class ServerFailure extends Failure {
  const ServerFailure({super.message, this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

final class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

final class RateLimitFailure extends Failure {
  const RateLimitFailure({super.message});
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message});
}
