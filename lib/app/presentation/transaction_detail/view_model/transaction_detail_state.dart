import 'package:equatable/equatable.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';

sealed class TransactionDetailState extends Equatable {
  const TransactionDetailState();

  @override
  List<Object?> get props => [];
}

final class TransactionDetailLoading extends TransactionDetailState {
  const TransactionDetailLoading();
}

final class TransactionDetailSuccess extends TransactionDetailState {
  const TransactionDetailSuccess(this.transaction);

  final TransactionEntity transaction;

  @override
  List<Object?> get props => [transaction];
}

final class TransactionDetailFailure extends TransactionDetailState {
  const TransactionDetailFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
