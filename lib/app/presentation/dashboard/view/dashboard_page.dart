import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:teste_cobuccio/app/core/errors/failure_message.dart';
import 'package:teste_cobuccio/app/core/router/app_routes.dart';
import 'package:teste_cobuccio/app/core/widgets/app_error_view.dart';
import 'package:teste_cobuccio/app/core/widgets/app_loading_view.dart';
import 'package:teste_cobuccio/app/core/widgets/balance_card.dart';
import 'package:teste_cobuccio/app/core/widgets/period_totals_chart.dart';
import 'package:teste_cobuccio/app/core/widgets/stale_cache_banner.dart';
import 'package:teste_cobuccio/app/core/widgets/total_card.dart';
import 'package:teste_cobuccio/app/core/widgets/transaction_tile.dart';
import 'package:teste_cobuccio/app/presentation/dashboard/view_model/dashboard_cubit.dart';
import 'package:teste_cobuccio/app/presentation/dashboard/view_model/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return switch (state) {
            DashboardLoading() => const AppLoadingView(),
            DashboardFailure(:final failure) => AppErrorView(
              message: failureMessage(failure),
              onRetry: () =>
                  context.read<DashboardCubit>().load(forceRefresh: true),
            ),
            DashboardSuccess(
              :final summary,
              :final recentTransactions,
              :final isBalanceHidden,
              :final isFromCache,
            ) =>
              Column(
                children: [
                  if (isFromCache) const StaleCacheBanner(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => context.read<DashboardCubit>().load(
                        forceRefresh: true,
                      ),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          BalanceCard(
                            formattedBalance: summary.availableBalance.format(),
                            isHidden: isBalanceHidden,
                            onToggleVisibility: () => context
                                .read<DashboardCubit>()
                                .toggleBalanceVisibility(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TotalCard(
                                  label: 'Entradas',
                                  value: summary.totalIncome.format(),
                                  icon: Icons.arrow_downward,
                                  color: Theme.of(context).colorScheme.primary,
                                  isHidden: isBalanceHidden,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TotalCard(
                                  label: 'Saídas',
                                  value: summary.totalExpense.format(),
                                  icon: Icons.arrow_upward,
                                  color: Theme.of(context).colorScheme.error,
                                  isHidden: isBalanceHidden,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Semantics(
                            header: true,
                            child: Text(
                              'Evolução do período',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 8),
                          PeriodTotalsChart(
                            totalIncome: summary.totalIncome,
                            totalExpense: summary.totalExpense,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Semantics(
                                header: true,
                                child: Text(
                                  'Recentes',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () =>
                                    context.push(AppRoutes.transactions),
                                child: const Text('Ver extrato'),
                              ),
                            ],
                          ),
                          if (recentTransactions.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Semantics(
                                liveRegion: true,
                                child: const Center(
                                  child: Text('Nenhuma transação recente'),
                                ),
                              ),
                            )
                          else
                            ...recentTransactions.map(
                              (tx) => TransactionTile(
                                transaction: tx,
                                onTap: () => context.push(
                                  AppRoutes.transactionDetailPath(tx.id),
                                ),
                                isHidden: isBalanceHidden,
                              ),
                            ),
                          const SizedBox(height: 8),
                          ExcludeSemantics(
                            child: Text(
                              'Entradas usam seta para baixo · Saídas usam seta para cima',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          };
        },
      ),
    );
  }
}
