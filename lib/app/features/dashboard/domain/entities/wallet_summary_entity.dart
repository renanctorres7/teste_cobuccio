import 'package:equatable/equatable.dart';
import 'package:teste_cobuccio/app/core/domain/money.dart';

final class WalletSummaryEntity extends Equatable {
  const WalletSummaryEntity({
    required this.availableBalance,
    required this.totalIncome,
    required this.totalExpense,
  });

  final Money availableBalance;
  final Money totalIncome;
  final Money totalExpense;

  @override
  List<Object?> get props => [availableBalance, totalIncome, totalExpense];
}
