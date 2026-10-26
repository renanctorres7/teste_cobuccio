import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_labels.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final TransactionEntity transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionTypeEnum.income;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;
    final color = isIncome
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    final date = DateFormat('dd/MM/yyyy HH:mm')
        .format(transaction.occurredAt.toLocal());
    final prefix = isIncome ? '+' : '-';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(
          icon,
          color: color,
          semanticLabel: transactionTypeLabel(transaction.type),
        ),
      ),
      title: Text(transaction.description),
      subtitle: Text(
        '$date · ${transactionStatusLabel(transaction.status)} · '
        '${transactionTypeLabel(transaction.type)}',
      ),
      trailing: Text(
        '$prefix${transaction.amount.format()}',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
