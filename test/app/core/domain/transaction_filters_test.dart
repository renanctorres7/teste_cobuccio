import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_filters.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_status_enum.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('TransactionFilters.matches', () {
    final tx = sampleTransaction(
      type: TransactionTypeEnum.income,
      status: TransactionStatusEnum.completed,
      occurredAt: DateTime.utc(2026, 10, 27, 12),
      description: 'Bitcoin variação diária',
    );

    test('matches everything with empty filters', () {
      expect(const TransactionFilters().matches(tx), isTrue);
    });

    test('filters by type', () {
      expect(
        const TransactionFilters(type: TransactionTypeEnum.income).matches(tx),
        isTrue,
      );
      expect(
        const TransactionFilters(type: TransactionTypeEnum.expense).matches(tx),
        isFalse,
      );
    });

    test('filters by status', () {
      expect(
        const TransactionFilters(status: TransactionStatusEnum.completed)
            .matches(tx),
        isTrue,
      );
      expect(
        const TransactionFilters(status: TransactionStatusEnum.pending)
            .matches(tx),
        isFalse,
      );
    });

    test('filters by period', () {
      expect(
        TransactionFilters(
          startDate: DateTime.utc(2026, 10, 1),
          endDate: DateTime.utc(2026, 10, 30, 23, 59, 59),
        ).matches(tx),
        isTrue,
      );
      expect(
        TransactionFilters(startDate: DateTime.utc(2026, 11, 1)).matches(tx),
        isFalse,
      );
      expect(
        TransactionFilters(endDate: DateTime.utc(2026, 10, 1)).matches(tx),
        isFalse,
      );
    });

    test('filters by query (case insensitive)', () {
      expect(const TransactionFilters(query: ' bitcoin ').matches(tx), isTrue);
      expect(const TransactionFilters(query: 'ethereum').matches(tx), isFalse);
      expect(const TransactionFilters(query: '   ').matches(tx), isTrue);
    });
  });
}
