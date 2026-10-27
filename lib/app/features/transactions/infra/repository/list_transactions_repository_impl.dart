import 'package:teste_cobuccio/app/core/domain/paged_transactions.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_filters.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/repository/list_transactions_repository.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/financial_snapshot_provider.dart';

final class ListTransactionsRepositoryImpl
    implements ListTransactionsRepository {
  const ListTransactionsRepositoryImpl(this._snapshotProvider);

  final FinancialSnapshotProvider _snapshotProvider;

  @override
  Future<Result<PagedTransactions>> list({
    TransactionFilters filters = const TransactionFilters(),
    String? cursor,
    int limit = 20,
  }) async {
    final snapshotResult = await _snapshotProvider.getSnapshot();
    return snapshotResult.when(
      success: (snapshot) {
        final filtered = snapshot.transactions
            .where(filters.matches)
            .toList(growable: false);

        final start = int.tryParse(cursor ?? '0') ?? 0;
        final safeStart = start.clamp(0, filtered.length);
        final end = (safeStart + limit).clamp(0, filtered.length);
        final page = filtered.sublist(safeStart, end);
        final hasMore = end < filtered.length;

        return Success(
          PagedTransactions(
            items: page,
            nextCursor: hasMore ? '$end' : null,
            hasMore: hasMore,
            isFromCache: snapshot.isFromCache,
          ),
        );
      },
      error: Error.new,
    );
  }
}
