import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/widgets/transaction_tile.dart';

class GroupedTransactionsList extends StatelessWidget {
  const GroupedTransactionsList({
    super.key,
    required this.controller,
    required this.items,
    required this.isLoadingMore,
    required this.onTransactionTap,
  });

  final ScrollController controller;
  final List<TransactionEntity> items;
  final bool isLoadingMore;
  final ValueChanged<TransactionEntity> onTransactionTap;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    final entries = <({String? header, TransactionEntity? tx})>[];

    String? lastHeader;
    for (final item in items) {
      final header = formatter.format(item.occurredAt.toLocal());
      if (header != lastHeader) {
        entries.add((header: header, tx: null));
        lastHeader = header;
      }
      entries.add((header: null, tx: item));
    }

    return ListView.builder(
      controller: controller,
      itemCount: entries.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= entries.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final entry = entries[index];
        if (entry.header != null) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              entry.header!,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
        }

        final tx = entry.tx!;
        return TransactionTile(
          transaction: tx,
          onTap: () => onTransactionTap(tx),
        );
      },
    );
  }
}
