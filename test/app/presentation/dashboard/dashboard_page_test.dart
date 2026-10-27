import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:teste_cobuccio/app/features/transactions/data/cache/transactions_local_cache.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/usecases/list_transactions_usecase.dart';
import 'package:teste_cobuccio/app/presentation/dashboard/view/dashboard_page.dart';
import 'package:teste_cobuccio/app/presentation/dashboard/view_model/dashboard_cubit.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpPage(WidgetTester tester, DashboardCubit cubit) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const DashboardPage(),
        ),
      ),
    );
    await tester.pump();
  }

  DashboardCubit buildCubit({
    StubWalletSummaryRepository? wallet,
    StubListTransactionsRepository? list,
  }) {
    return DashboardCubit(
      getWalletSummaryUseCase: GetWalletSummaryUseCase(
        wallet ?? StubWalletSummaryRepository(),
      ),
      listTransactionsUseCase: ListTransactionsUseCase(
        list ?? StubListTransactionsRepository(items: [sampleTransaction()]),
      ),
      snapshotProvider: unusedSnapshotProvider(TransactionsLocalCache(prefs)),
      preferences: prefs,
    );
  }

  testWidgets('shows loading indicator', (tester) async {
    await pumpPage(tester, buildCubit());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty recent transactions', (tester) async {
    final cubit = buildCubit(
      list: StubListTransactionsRepository(items: const []),
    );
    await cubit.load();
    await pumpPage(tester, cubit);

    await tester.scrollUntilVisible(
      find.text('Nenhuma transação recente'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Nenhuma transação recente'), findsOneWidget);
  });

  testWidgets('shows error with retry', (tester) async {
    final cubit = buildCubit(
      wallet: StubWalletSummaryRepository(
        failure: const NetworkFailure(message: 'offline'),
      ),
    );
    await cubit.load();
    await pumpPage(tester, cubit);

    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(
      find.text('Sem conexão. Verifique a internet e tente novamente.'),
      findsOneWidget,
    );
  });

  testWidgets('shows success content', (tester) async {
    final cubit = buildCubit();
    await cubit.load();
    await pumpPage(tester, cubit);

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Saldo disponível'), findsOneWidget);
    expect(find.text('Ver extrato'), findsOneWidget);

    final legend = find.text(
      'Entradas usam seta para baixo · Saídas usam seta para cima',
    );
    await tester.scrollUntilVisible(
      legend,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(legend, findsOneWidget);
    expect(find.textContaining('income'), findsNothing);
    expect(find.textContaining('expense'), findsNothing);
  });
}
