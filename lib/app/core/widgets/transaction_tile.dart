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
    required this.isHidden,
  });

  final TransactionEntity transaction;
  final VoidCallback? onTap;
  final bool isHidden;

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
      leading: ExcludeSemantics(
        child: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
      ),
      title: Text(transaction.description),
      subtitle: Text(
        '$date · ${transactionStatusLabel(transaction.status)} · '
        '${transactionTypeLabel(transaction.type)}',
      ),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.35,
        ),
        child: Text(
          isHidden ? r'R$ ••••••' : '$prefix${transaction.amount.format()}',
          textAlign: TextAlign.end,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
