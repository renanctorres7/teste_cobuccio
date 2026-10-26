import 'package:teste_cobuccio/app/core/domain/money.dart';
import 'package:teste_cobuccio/app/core/domain/period_totals.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_status_enum.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';

abstract final class PeriodTotalsCalculator {
  static PeriodTotals calculate({
    required List<TransactionEntity> transactions,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var incomeCents = 0;
    var expenseCents = 0;

    for (final transaction in transactions) {
      if (!_isInPeriod(transaction.occurredAt, startDate, endDate)) {
        continue;
      }
      if (transaction.status == TransactionStatusEnum.failed) {
        continue;
      }

      switch (transaction.type) {
        case TransactionTypeEnum.income:
          incomeCents += transaction.amount.cents.abs();
        case TransactionTypeEnum.expense:
          expenseCents += transaction.amount.cents.abs();
      }
    }

    return PeriodTotals(
      totalIncome: Money(incomeCents),
      totalExpense: Money(expenseCents),
    );
  }

  static bool _isInPeriod(
    DateTime occurredAt,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final utc = occurredAt.toUtc();
    if (startDate != null && utc.isBefore(startDate.toUtc())) {
      return false;
    }
    if (endDate != null && utc.isAfter(endDate.toUtc())) {
      return false;
    }
    return true;
  }
}
