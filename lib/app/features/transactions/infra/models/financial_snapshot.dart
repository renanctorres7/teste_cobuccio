import 'package:equatable/equatable.dart';
import 'package:teste_cobuccio/app/core/domain/money.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';

final class FinancialSnapshot extends Equatable {
  const FinancialSnapshot({
    required this.balance,
    required this.transactions,
    this.isFromCache = false,
  });

  final Money balance;
  final List<TransactionEntity> transactions;
  final bool isFromCache;

  @override
  List<Object?> get props => [balance, transactions, isFromCache];
}
