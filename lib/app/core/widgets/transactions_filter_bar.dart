import 'package:flutter/material.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_filters.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_status_enum.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';

class TransactionsFilterBar extends StatelessWidget {
  const TransactionsFilterBar({
    super.key,
    required this.filters,
    required this.onTypeSelected,
    required this.onStatusSelected,
    required this.onPeriodPressed,
  });

  final TransactionFilters? filters;
  final void Function(TransactionTypeEnum type, {required bool clear})
      onTypeSelected;
  final void Function(TransactionStatusEnum status, {required bool clear})
      onStatusSelected;
  final VoidCallback onPeriodPressed;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Entradas'),
            selected: filters?.type == TransactionTypeEnum.income,
            onSelected: (selected) {
              onTypeSelected(
                TransactionTypeEnum.income,
                clear: !selected,
              );
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Saídas'),
            selected: filters?.type == TransactionTypeEnum.expense,
            onSelected: (selected) {
              onTypeSelected(
                TransactionTypeEnum.expense,
                clear: !selected,
              );
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Concluídas'),
            selected: filters?.status == TransactionStatusEnum.completed,
            onSelected: (selected) {
              onStatusSelected(
                TransactionStatusEnum.completed,
                clear: !selected,
              );
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Pendentes'),
            selected: filters?.status == TransactionStatusEnum.pending,
            onSelected: (selected) {
              onStatusSelected(
                TransactionStatusEnum.pending,
                clear: !selected,
              );
            },
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.date_range, size: 18),
            label: const Text('Período'),
            onPressed: onPeriodPressed,
          ),
        ],
      ),
    );
  }
}
