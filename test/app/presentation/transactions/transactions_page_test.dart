import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/core/widgets/stale_cache_banner.dart';
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

  Future<void> pumpPage(
    WidgetTester tester,
    TransactionsCubit cubit, {
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: child!,
          );
        },
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
    final handle = tester.ensureSemantics();

    await pumpPage(tester, buildCubit(StubListTransactionsRepository()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Carregando'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('shows empty state', (tester) async {
    final handle = tester.ensureSemantics();

    final cubit = buildCubit(StubListTransactionsRepository(items: const []));
    await cubit.load();
    await pumpPage(tester, cubit);

    expect(find.text('Extrato'), findsOneWidget);
    final empty = find.text('Nenhuma transação encontrada');
    expect(empty, findsOneWidget);
    expect(
      tester.getSemantics(empty),
      containsSemantics(
        label: 'Nenhuma transação encontrada',
        isLiveRegion: true,
      ),
    );
    handle.dispose();
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
    expect(find.text(StaleCacheBanner.message), findsNothing);
  });

  testWidgets('shows stale cache banner when data is from cache', (
    tester,
  ) async {
    final cubit = buildCubit(
      StubListTransactionsRepository(
        items: [sampleTransaction()],
        isFromCache: true,
      ),
    );
    await cubit.load();
    await pumpPage(tester, cubit);

    expect(find.text(StaleCacheBanner.message), findsOneWidget);
    expect(find.byType(StaleCacheBanner), findsOneWidget);
  });

  testWidgets('exposes search field label for screen readers', (tester) async {
    final cubit = buildCubit(
      StubListTransactionsRepository(items: [sampleTransaction()]),
    );
    await cubit.load();
    await pumpPage(tester, cubit);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.labelText, 'Buscar por descrição');
    expect(find.text('Buscar por descrição'), findsOneWidget);
  });

  testWidgets('renders list layout at 200% text scale', (tester) async {
    final cubit = buildCubit(
      StubListTransactionsRepository(items: [sampleTransaction()]),
    );
    await cubit.load();
    await pumpPage(tester, cubit, textScale: 2);

    expect(find.text('Extrato'), findsOneWidget);
    expect(find.text('Buscar por descrição'), findsOneWidget);
    expect(find.text('Bitcoin variação'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
