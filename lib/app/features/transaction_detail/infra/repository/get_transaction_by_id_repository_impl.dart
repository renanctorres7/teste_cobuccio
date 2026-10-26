import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';
import 'package:teste_cobuccio/app/features/transaction_detail/domain/repository/get_transaction_by_id_repository.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/financial_snapshot_provider.dart';

final class GetTransactionByIdRepositoryImpl
    implements GetTransactionByIdRepository {
  const GetTransactionByIdRepositoryImpl(this._snapshotProvider);

  final FinancialSnapshotProvider _snapshotProvider;

  @override
  Future<Result<TransactionEntity>> getById(String id) async {
    final snapshotResult = await _snapshotProvider.getSnapshot();
    return snapshotResult.when(
      success: (snapshot) {
        for (final transaction in snapshot.transactions) {
          if (transaction.id == id) {
            return Success(transaction);
          }
        }
        return const Error(
          UnexpectedFailure(message: 'Transaction not found'),
        );
      },
      error: Error.new,
    );
  }
}
