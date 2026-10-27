import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/errors/failure_message.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';

void main() {
  test('maps each Failure to a user message', () {
    expect(
      failureMessage(const NetworkFailure()),
      contains('Sem conexão'),
    );
    expect(
      failureMessage(const RateLimitFailure()),
      contains('Limite de requisições'),
    );
    expect(
      failureMessage(const ServerFailure(statusCode: 503)),
      'Erro no servidor (503).',
    );
    expect(
      failureMessage(const ServerFailure()),
      'Erro no servidor.',
    );
    expect(
      failureMessage(const CacheFailure()),
      contains('cache'),
    );
    expect(
      failureMessage(const UnexpectedFailure(message: 'boom')),
      'boom',
    );
    expect(
      failureMessage(const UnexpectedFailure()),
      contains('Algo deu errado'),
    );
  });
}
