import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:teste_cobuccio/app/core/di/injection.dart';
import 'package:teste_cobuccio/app/core/router/app_routes.dart';
import 'package:teste_cobuccio/app/presentation/dashboard/view/dashboard_page.dart';
import 'package:teste_cobuccio/app/presentation/dashboard/view_model/dashboard_cubit.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view/transaction_detail_page.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view_model/transaction_detail_cubit.dart';
import 'package:teste_cobuccio/app/presentation/transactions/view/transactions_page.dart';
import 'package:teste_cobuccio/app/presentation/transactions/view_model/transactions_cubit.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<DashboardCubit>()..load(),
          child: const DashboardPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.transactions,
        name: 'transactions',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<TransactionsCubit>()..load(),
          child: const TransactionsPage(),
        ),
        routes: [
          GoRoute(
            path: ':id',
            name: 'transactionDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BlocProvider(
                create: (_) =>
                    getIt<TransactionDetailCubit>(param1: id)..load(),
                child: TransactionDetailPage(transactionId: id),
              );
            },
          ),
        ],
      ),
    ],
  );
}
