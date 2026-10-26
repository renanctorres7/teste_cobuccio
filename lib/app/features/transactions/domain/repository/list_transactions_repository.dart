import 'package:teste_cobuccio/app/core/domain/paged_transactions.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_filters.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';

abstract interface class ListTransactionsRepository {
  Future<Result<PagedTransactions>> list({
    TransactionFilters filters = const TransactionFilters(),
    String? cursor,
    int limit = 20,
  });
}
