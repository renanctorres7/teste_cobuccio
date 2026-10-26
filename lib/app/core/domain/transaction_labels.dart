import 'package:teste_cobuccio/app/core/domain/transaction_status_enum.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';

String transactionTypeLabel(TransactionTypeEnum type) {
  return switch (type) {
    TransactionTypeEnum.income => 'Entrada',
    TransactionTypeEnum.expense => 'Saída',
  };
}

String transactionStatusLabel(TransactionStatusEnum status) {
  return switch (status) {
    TransactionStatusEnum.completed => 'Concluída',
    TransactionStatusEnum.pending => 'Pendente',
    TransactionStatusEnum.failed => 'Falha',
    TransactionStatusEnum.refunded => 'Estornada',
  };
}
