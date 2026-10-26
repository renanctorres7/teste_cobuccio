import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:teste_cobuccio/app/core/errors/failure_message.dart';
import 'package:teste_cobuccio/app/core/router/app_routes.dart';
import 'package:teste_cobuccio/app/core/widgets/app_error_view.dart';
import 'package:teste_cobuccio/app/core/widgets/grouped_transactions_list.dart';
import 'package:teste_cobuccio/app/core/widgets/transactions_filter_bar.dart';
import 'package:teste_cobuccio/app/presentation/transactions/view_model/transactions_cubit.dart';
import 'package:teste_cobuccio/app/presentation/transactions/view_model/transactions_state.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<TransactionsCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Extrato')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por descrição',
                border: OutlineInputBorder(),
              ),
              onChanged: context.read<TransactionsCubit>().onQueryChanged,
            ),
          ),
          BlocBuilder<TransactionsCubit, TransactionsState>(
            builder: (context, state) {
              final filters = state is TransactionsSuccess
                  ? state.filters
                  : null;
              return TransactionsFilterBar(
                filters: filters,
                onTypeSelected: (type, {required clear}) {
                  context.read<TransactionsCubit>().applyFilters(
                    type: type,
                    clearType: clear,
                  );
                },
                onStatusSelected: (status, {required clear}) {
                  context.read<TransactionsCubit>().applyFilters(
                    status: status,
                    clearStatus: clear,
                  );
                },
                onPeriodPressed: () => _pickPeriod(context),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<TransactionsCubit, TransactionsState>(
              builder: (context, state) {
                return switch (state) {
                  TransactionsLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  TransactionsFailure(:final failure) => AppErrorView(
                    message: failureMessage(failure),
                    onRetry: () => context.read<TransactionsCubit>().load(
                      forceRefresh: true,
                    ),
                  ),
                  TransactionsSuccess(:final items, :final isLoadingMore) =>
                    items.isEmpty
                        ? const Center(
                            child: Text('Nenhuma transação encontrada'),
                          )
                        : RefreshIndicator(
                            onRefresh: () => context
                                .read<TransactionsCubit>()
                                .load(forceRefresh: true),
                            child: GroupedTransactionsList(
                              isHidden: false,
                              controller: _scrollController,
                              items: items,
                              isLoadingMore: isLoadingMore,
                              onTransactionTap: (tx) => context.push(
                                AppRoutes.transactionDetailPath(tx.id),
                              ),
                            ),
                          ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPeriod(BuildContext context) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
    );
    if (range == null || !context.mounted) {
      return;
    }
    await context.read<TransactionsCubit>().applyFilters(
      startDate: DateTime.utc(
        range.start.year,
        range.start.month,
        range.start.day,
      ),
      endDate: DateTime.utc(
        range.end.year,
        range.end.month,
        range.end.day,
        23,
        59,
        59,
      ),
    );
  }
}
