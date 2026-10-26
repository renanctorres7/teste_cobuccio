import 'package:equatable/equatable.dart';
import 'package:teste_cobuccio/app/core/domain/money.dart';

final class PeriodTotals extends Equatable {
  const PeriodTotals({
    required this.totalIncome,
    required this.totalExpense,
  });

  final Money totalIncome;
  final Money totalExpense;

  Money get net => totalIncome - totalExpense;

  @override
  List<Object?> get props => [totalIncome, totalExpense];
}
