import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';
import 'package:teste_cobuccio/app/features/transaction_detail/domain/repository/get_transaction_by_id_repository.dart';

final class GetTransactionDetailUseCase {
  const GetTransactionDetailUseCase(this._repository);

  final GetTransactionByIdRepository _repository;

  Future<Result<TransactionEntity>> call(String id) {
    final trimmed = id.trim();
    if (trimmed.isEmpty) {
      return Future.value(
        const Error(UnexpectedFailure(message: 'Transaction id is required')),
      );
    }
    return _repository.getById(trimmed);
  }
}
