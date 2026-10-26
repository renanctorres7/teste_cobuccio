import 'package:teste_cobuccio/app/core/errors/failures.dart';

String failureMessage(Failure failure) {
  return switch (failure) {
    NetworkFailure() => 'Sem conexão. Verifique a internet e tente novamente.',
    RateLimitFailure() =>
      'Limite de requisições atingido. Aguarde e tente novamente.',
    ServerFailure(:final statusCode) =>
      'Erro no servidor${statusCode != null ? ' ($statusCode)' : ''}.',
    CacheFailure() => 'Não foi possível ler os dados em cache.',
    UnexpectedFailure(:final message) =>
      message?.isNotEmpty == true ? message! : 'Algo deu errado. Tente novamente.',
  };
}
