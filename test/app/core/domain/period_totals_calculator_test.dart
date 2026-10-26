import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/domain/money.dart';
import 'package:teste_cobuccio/app/core/domain/period_totals_calculator.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_status_enum.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';

void main() {
  group('PeriodTotalsCalculator', () {
    TransactionEntity tx({
      required String id,
      required int cents,
      required TransactionTypeEnum type,
      required DateTime occurredAt,
      TransactionStatusEnum status = TransactionStatusEnum.completed,
    }) {
      return TransactionEntity(
        id: id,
        description: id,
        amount: Money(cents),
        occurredAt: occurredAt,
        type: type,
        status: status,
      );
    }

    test('returns zero totals for empty list', () {
      final totals = PeriodTotalsCalculator.calculate(transactions: const []);

      expect(totals.totalIncome.cents, 0);
      expect(totals.totalExpense.cents, 0);
    });

    test('sums only income', () {
      final totals = PeriodTotalsCalculator.calculate(
        transactions: [
          tx(
            id: '1',
            cents: 1000,
            type: TransactionTypeEnum.income,
            occurredAt: DateTime.utc(2026, 10, 1),
          ),
          tx(
            id: '2',
            cents: 500,
            type: TransactionTypeEnum.income,
            occurredAt: DateTime.utc(2026, 10, 2),
          ),
        ],
      );

      expect(totals.totalIncome.cents, 1500);
      expect(totals.totalExpense.cents, 0);
    });

    test('sums only expense', () {
      final totals = PeriodTotalsCalculator.calculate(
        transactions: [
          tx(
            id: '1',
            cents: 200,
            type: TransactionTypeEnum.expense,
            occurredAt: DateTime.utc(2026, 10, 1),
          ),
          tx(
            id: '2',
            cents: 300,
            type: TransactionTypeEnum.expense,
            occurredAt: DateTime.utc(2026, 10, 2),
          ),
        ],
      );

      expect(totals.totalIncome.cents, 0);
      expect(totals.totalExpense.cents, 500);
    });

    test('sums mixed income and expense', () {
      final totals = PeriodTotalsCalculator.calculate(
        transactions: [
          tx(
            id: '1',
            cents: 1000,
            type: TransactionTypeEnum.income,
            occurredAt: DateTime.utc(2026, 10, 1),
          ),
          tx(
            id: '2',
            cents: 400,
            type: TransactionTypeEnum.expense,
            occurredAt: DateTime.utc(2026, 10, 2),
          ),
        ],
      );

      expect(totals.totalIncome.cents, 1000);
      expect(totals.totalExpense.cents, 400);
      expect(totals.net.cents, 600);
    });

    test('ignores failed transactions', () {
      final totals = PeriodTotalsCalculator.calculate(
        transactions: [
          tx(
            id: '1',
            cents: 1000,
            type: TransactionTypeEnum.income,
            occurredAt: DateTime.utc(2026, 10, 1),
            status: TransactionStatusEnum.failed,
          ),
          tx(
            id: '2',
            cents: 200,
            type: TransactionTypeEnum.expense,
            occurredAt: DateTime.utc(2026, 10, 1),
          ),
        ],
      );

      expect(totals.totalIncome.cents, 0);
      expect(totals.totalExpense.cents, 200);
    });

    test('respects UTC day boundary for period filter', () {
      final start = DateTime.utc(2026, 10, 2);
      final end = DateTime.utc(2026, 10, 2, 23, 59, 59);

      final totals = PeriodTotalsCalculator.calculate(
        transactions: [
          tx(
            id: 'before',
            cents: 100,
            type: TransactionTypeEnum.income,
            occurredAt: DateTime.utc(2026, 10, 1, 23, 59, 59),
          ),
          tx(
            id: 'inside',
            cents: 500,
            type: TransactionTypeEnum.income,
            occurredAt: DateTime.utc(2026, 10, 2, 0, 0, 0),
          ),
          tx(
            id: 'after',
            cents: 200,
            type: TransactionTypeEnum.income,
            occurredAt: DateTime.utc(2026, 10, 3, 0, 0, 0),
          ),
        ],
        startDate: start,
        endDate: end,
      );

      expect(totals.totalIncome.cents, 500);
      expect(totals.totalExpense.cents, 0);
    });
  });
}
