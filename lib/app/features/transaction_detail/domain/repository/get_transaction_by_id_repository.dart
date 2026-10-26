import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';

abstract interface class GetTransactionByIdRepository {
  Future<Result<TransactionEntity>> getById(String id);
}
