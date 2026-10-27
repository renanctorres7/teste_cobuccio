import 'package:teste_cobuccio/app/core/domain/money.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_status_enum.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/entities/wallet_summary_entity.dart';

TransactionEntity sampleTransaction({
  String id = 'tx-1',
  String description = 'Bitcoin variação',
  int cents = 1500,
  DateTime? occurredAt,
  TransactionTypeEnum type = TransactionTypeEnum.income,
  TransactionStatusEnum status = TransactionStatusEnum.completed,
  Map<String, String> metadata = const {},
}) {
  return TransactionEntity(
    id: id,
    description: description,
    amount: Money(cents),
    occurredAt: occurredAt ?? DateTime.utc(2026, 10, 27, 12),
    type: type,
    status: status,
    metadata: metadata,
  );
}

const sampleSummary = WalletSummaryEntity(
  availableBalance: Money(10000),
  totalIncome: Money(5000),
  totalExpense: Money(2000),
);

const sampleCachedSummary = WalletSummaryEntity(
  availableBalance: Money(10000),
  totalIncome: Money(5000),
  totalExpense: Money(2000),
  isFromCache: true,
);
