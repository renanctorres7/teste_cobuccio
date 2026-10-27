import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/core/widgets/offline_banner.dart';
import 'package:teste_cobuccio/app/features/transaction_detail/domain/usecases/get_transaction_detail_usecase.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view/transaction_detail_page.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view_model/transaction_detail_cubit.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/fixtures.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester,
    TransactionDetailCubit cubit,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: TransactionDetailPage(transactionId: cubit.transactionId),
        ),
      ),
    );
    await tester.pump();
  }

  TransactionDetailCubit buildCubit({
    StubGetByIdRepository? repo,
    String transactionId = 'tx-1',
    FakeNetworkInfo? networkInfo,
  }) {
    return TransactionDetailCubit(
      getTransactionDetailUseCase: GetTransactionDetailUseCase(
        repo ?? StubGetByIdRepository(),
      ),
      transactionId: transactionId,
      networkInfo: networkInfo ?? FakeNetworkInfo(),
    );
  }

  testWidgets('shows loading indicator', (tester) async {
    await pumpPage(tester, buildCubit());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty-like failure for missing transaction', (tester) async {
    final cubit = buildCubit(
      repo: StubGetByIdRepository(
        failure: const UnexpectedFailure(message: 'Não encontrada'),
      ),
      transactionId: 'missing',
    );
    await cubit.load();
    await pumpPage(tester, cubit);

    expect(find.text('Não encontrada'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('shows error with retry', (tester) async {
    final cubit = buildCubit(
      repo: StubGetByIdRepository(failure: const NetworkFailure()),
    );
    await cubit.load();
    await pumpPage(tester, cubit);

    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('shows detail fields on success', (tester) async {
    final tx = sampleTransaction(
      metadata: const {'origem': 'CoinGecko'},
    );
    final cubit = buildCubit(
      repo: StubGetByIdRepository(transaction: tx),
      transactionId: tx.id,
    );
    await cubit.load();
    await pumpPage(tester, cubit);

    expect(find.text('Detalhe da transação'), findsOneWidget);
    expect(find.text(tx.id), findsOneWidget);
    expect(find.text('Bitcoin variação'), findsOneWidget);
    expect(find.text('CoinGecko'), findsOneWidget);
    expect(find.byTooltip('Copiar identificador'), findsOneWidget);
    expect(find.byType(OfflineBanner), findsNothing);
  });

  testWidgets('shows offline banner when isOffline', (tester) async {
    final tx = sampleTransaction();
    final cubit = buildCubit(
      repo: StubGetByIdRepository(transaction: tx),
      transactionId: tx.id,
      networkInfo: FakeNetworkInfo(online: false),
    );
    await cubit.load();
    await pumpPage(tester, cubit);

    expect(find.text(OfflineBanner.message), findsOneWidget);
    expect(find.byType(OfflineBanner), findsOneWidget);
  });
}
