import 'package:equatable/equatable.dart';
import 'package:teste_cobuccio/app/core/domain/money.dart';

final class WalletSummaryEntity extends Equatable {
  const WalletSummaryEntity({
    required this.availableBalance,
    required this.totalIncome,
    required this.totalExpense,
    this.isFromCache = false,
  });

  final Money availableBalance;
  final Money totalIncome;
  final Money totalExpense;
  final bool isFromCache;

  @override
  List<Object?> get props =>
      [availableBalance, totalIncome, totalExpense, isFromCache];
}
