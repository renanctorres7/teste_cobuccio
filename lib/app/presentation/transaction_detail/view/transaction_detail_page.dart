import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_labels.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';
import 'package:teste_cobuccio/app/core/errors/failure_message.dart';
import 'package:teste_cobuccio/app/core/widgets/app_error_view.dart';
import 'package:teste_cobuccio/app/core/widgets/app_loading_view.dart';
import 'package:teste_cobuccio/app/core/widgets/detail_row.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view_model/transaction_detail_cubit.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view_model/transaction_detail_state.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da transação')),
      body: BlocBuilder<TransactionDetailCubit, TransactionDetailState>(
        builder: (context, state) {
          return switch (state) {
            TransactionDetailLoading() => const AppLoadingView(),
            TransactionDetailFailure(:final failure) => AppErrorView(
                message: failureMessage(failure),
                onRetry: () => context.read<TransactionDetailCubit>().load(),
              ),
            TransactionDetailSuccess(:final transaction) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DetailRow(
                    label: 'Identificador',
                    value: transaction.id,
                    trailing: IconButton(
                      tooltip: 'Copiar identificador',
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: transaction.id),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Identificador copiado'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy),
                    ),
                  ),
                  DetailRow(
                    label: 'Descrição',
                    value: transaction.description,
                  ),
                  DetailRow(
                    label: 'Valor',
                    value:
                        '${transaction.type == TransactionTypeEnum.income ? '+' : '-'}'
                        '${transaction.amount.format()}',
                  ),
                  DetailRow(
                    label: 'Data e hora',
                    value: DateFormat('dd/MM/yyyy HH:mm:ss')
                        .format(transaction.occurredAt.toLocal()),
                  ),
                  DetailRow(
                    label: 'Tipo',
                    value: transactionTypeLabel(transaction.type),
                  ),
                  DetailRow(
                    label: 'Status',
                    value: transactionStatusLabel(transaction.status),
                  ),
                  if (transaction.metadata.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Metadados',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...transaction.metadata.entries.map(
                      (entry) => DetailRow(
                        label: entry.key,
                        value: entry.value,
                      ),
                    ),
                  ],
                ],
              ),
          };
        },
      ),
    );
  }
}
