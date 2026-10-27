import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_labels.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_status_enum.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';

void main() {
  test('transactionTypeLabel', () {
    expect(transactionTypeLabel(TransactionTypeEnum.income), 'Entrada');
    expect(transactionTypeLabel(TransactionTypeEnum.expense), 'Saída');
  });

  test('transactionStatusLabel', () {
    expect(
      transactionStatusLabel(TransactionStatusEnum.completed),
      'Concluída',
    );
    expect(
      transactionStatusLabel(TransactionStatusEnum.pending),
      'Pendente',
    );
    expect(transactionStatusLabel(TransactionStatusEnum.failed), 'Falha');
    expect(
      transactionStatusLabel(TransactionStatusEnum.refunded),
      'Estornada',
    );
  });
}
