import 'package:equatable/equatable.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';

final class PagedTransactions extends Equatable {
  const PagedTransactions({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<TransactionEntity> items;
  final String? nextCursor;
  final bool hasMore;

  @override
  List<Object?> get props => [items, nextCursor, hasMore];
}
