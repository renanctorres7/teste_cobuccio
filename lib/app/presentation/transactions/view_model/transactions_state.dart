import 'package:equatable/equatable.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_filters.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';

sealed class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

final class TransactionsLoading extends TransactionsState {
  const TransactionsLoading();
}

final class TransactionsSuccess extends TransactionsState {
  const TransactionsSuccess({
    required this.items,
    required this.filters,
    required this.hasMore,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  final List<TransactionEntity> items;
  final TransactionFilters filters;
  final bool hasMore;
  final String? nextCursor;
  final bool isLoadingMore;

  TransactionsSuccess copyWith({
    List<TransactionEntity>? items,
    TransactionFilters? filters,
    bool? hasMore,
    String? nextCursor,
    bool? isLoadingMore,
  }) {
    return TransactionsSuccess(
      items: items ?? this.items,
      filters: filters ?? this.filters,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [items, filters, hasMore, nextCursor, isLoadingMore];
}

final class TransactionsFailure extends TransactionsState {
  const TransactionsFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
