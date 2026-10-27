import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_cobuccio/app/core/router/app_routes.dart';
import 'package:teste_cobuccio/app/core/theme/app_theme_data.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:teste_cobuccio/app/features/transaction_detail/domain/usecases/get_transaction_detail_usecase.dart';
import 'package:teste_cobuccio/app/features/transactions/data/cache/transactions_local_cache.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/usecases/list_transactions_usecase.dart';
import 'package:teste_cobuccio/app/presentation/dashboard/view/dashboard_page.dart';
import 'package:teste_cobuccio/app/presentation/dashboard/view_model/dashboard_cubit.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view/transaction_detail_page.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view_model/transaction_detail_cubit.dart';
import 'package:teste_cobuccio/app/presentation/transactions/view/transactions_page.dart';
import 'package:teste_cobuccio/app/presentation/transactions/view_model/transactions_cubit.dart';

import '../helpers/fakes.dart';
import '../helpers/fixtures.dart';

void main() {
  testWidgets('dashboard → extrato → detalhe with stubs', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final snapshot = unusedSnapshotProvider(TransactionsLocalCache(prefs));
    final tx = sampleTransaction();

    final listRepo = StubListTransactionsRepository(items: [tx]);
    final listUseCase = ListTransactionsUseCase(listRepo);
    final detailUseCase = GetTransactionDetailUseCase(
      StubGetByIdRepository(transaction: tx),
    );

    final networkInfo = FakeNetworkInfo();
    final dashboardCubit = DashboardCubit(
      getWalletSummaryUseCase: GetWalletSummaryUseCase(
        StubWalletSummaryRepository(),
      ),
      listTransactionsUseCase: listUseCase,
      snapshotProvider: snapshot,
      preferences: prefs,
      networkInfo: networkInfo,
    );
    await dashboardCubit.load();

    final router = GoRouter(
      initialLocation: AppRoutes.dashboard,
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => BlocProvider.value(
            value: dashboardCubit,
            child: const DashboardPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.transactions,
          builder: (context, state) => BlocProvider(
            create: (_) => TransactionsCubit(
              listTransactionsUseCase: listUseCase,
              snapshotProvider: snapshot,
              networkInfo: FakeNetworkInfo(),
            )..load(),
            child: const TransactionsPage(),
          ),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return BlocProvider(
                  create: (_) => TransactionDetailCubit(
                    getTransactionDetailUseCase: detailUseCase,
                    transactionId: id,
                    networkInfo: FakeNetworkInfo(),
                  )..load(),
                  child: TransactionDetailPage(transactionId: id),
                );
              },
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildAppTheme(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Ver extrato'), findsOneWidget);

    await tester.tap(find.text('Ver extrato'));
    await tester.pumpAndSettle();

    expect(find.text('Extrato'), findsOneWidget);
    expect(find.text('Bitcoin variação'), findsOneWidget);

    await tester.tap(find.text('Bitcoin variação'));
    await tester.pumpAndSettle();

    expect(find.text('Detalhe da transação'), findsOneWidget);
    expect(find.text(tx.id), findsOneWidget);
    expect(find.text('Descrição'), findsOneWidget);
  });
}
