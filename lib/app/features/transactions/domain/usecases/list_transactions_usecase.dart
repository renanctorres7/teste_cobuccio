import 'package:teste_cobuccio/app/core/domain/paged_transactions.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_filters.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/repository/list_transactions_repository.dart';

final class ListTransactionsUseCase {
  const ListTransactionsUseCase(this._repository);

  final ListTransactionsRepository _repository;

  Future<Result<PagedTransactions>> call({
    TransactionFilters filters = const TransactionFilters(),
    String? cursor,
    int limit = 20,
  }) {
    return _repository.list(filters: filters, cursor: cursor, limit: limit);
  }
}
