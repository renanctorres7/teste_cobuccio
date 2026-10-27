import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/features/transactions/data/cache/transactions_local_cache.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/usecases/list_transactions_usecase.dart';
import 'package:teste_cobuccio/app/presentation/transactions/view/transactions_page.dart';
import 'package:teste_cobuccio/app/presentation/transactions/view_model/transactions_cubit.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpPage(WidgetTester tester, TransactionsCubit cubit) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const TransactionsPage(),
        ),
      ),
    );
    await tester.pump();
  }

  TransactionsCubit buildCubit(StubListTransactionsRepository repo) {
    return TransactionsCubit(
      listTransactionsUseCase: ListTransactionsUseCase(repo),
      snapshotProvider: unusedSnapshotProvider(TransactionsLocalCache(prefs)),
    );
  }

  testWidgets('shows loading indicator', (tester) async {
    await pumpPage(tester, buildCubit(StubListTransactionsRepository()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty state', (tester) async {
    final cubit = buildCubit(StubListTransactionsRepository(items: const []));
    await cubit.load();
    await pumpPage(tester, cubit);

    expect(find.text('Extrato'), findsOneWidget);
    expect(find.text('Nenhuma transação encontrada'), findsOneWidget);
  });

  testWidgets('shows error with retry', (tester) async {
    final cubit = buildCubit(
      StubListTransactionsRepository(
        failure: const RateLimitFailure(),
      ),
    );
    await cubit.load();
    await pumpPage(tester, cubit);

    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(
      find.text('Limite de requisições atingido. Aguarde e tente novamente.'),
      findsOneWidget,
    );
  });

  testWidgets('shows transaction list on success', (tester) async {
    final cubit = buildCubit(
      StubListTransactionsRepository(items: [sampleTransaction()]),
    );
    await cubit.load();
    await pumpPage(tester, cubit);

    expect(find.text('Bitcoin variação'), findsOneWidget);
  });
}
