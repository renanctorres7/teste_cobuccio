import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_cobuccio/app/core/domain/money.dart';
import 'package:teste_cobuccio/app/core/domain/paged_transactions.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_filters.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_status_enum.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/entities/wallet_summary_entity.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/repository/get_wallet_summary_repository.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:teste_cobuccio/app/features/transaction_detail/domain/repository/get_transaction_by_id_repository.dart';
import 'package:teste_cobuccio/app/features/transaction_detail/domain/usecases/get_transaction_detail_usecase.dart';
import 'package:teste_cobuccio/app/features/transactions/data/cache/transactions_local_cache.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/repository/list_transactions_repository.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/usecases/list_transactions_usecase.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/datasources/coin_market_datasource.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/coin_price_model.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/market_chart_model.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/financial_snapshot_provider.dart';
import 'package:teste_cobuccio/app/presentation/dashboard/view/dashboard_page.dart';
import 'package:teste_cobuccio/app/presentation/dashboard/view_model/dashboard_cubit.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view/transaction_detail_page.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view_model/transaction_detail_cubit.dart';
import 'package:teste_cobuccio/app/presentation/transactions/view/transactions_page.dart';
import 'package:teste_cobuccio/app/presentation/transactions/view_model/transactions_cubit.dart';

void main() {
  final sampleTx = TransactionEntity(
    id: 'tx-1',
    description: 'Bitcoin variação',
    amount: const Money(1500),
    occurredAt: DateTime.utc(2024, 1, 15, 12),
    type: TransactionTypeEnum.income,
    status: TransactionStatusEnum.completed,
  );

  late SharedPreferences prefs;
  late FinancialSnapshotProvider snapshotProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    snapshotProvider = FinancialSnapshotProvider(
      datasource: _FailingDatasource(),
      cache: TransactionsLocalCache(prefs),
    );
  });

  testWidgets('Dashboard shows success content', (tester) async {
    final cubit = DashboardCubit(
      getWalletSummaryUseCase: GetWalletSummaryUseCase(
        _StubWalletSummaryRepository(),
      ),
      listTransactionsUseCase: ListTransactionsUseCase(
        _StubListTransactionsRepository(items: [sampleTx]),
      ),
      snapshotProvider: snapshotProvider,
      preferences: prefs,
    );
    await cubit.load();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const DashboardPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Saldo disponível'), findsOneWidget);
    expect(find.text('Ver extrato'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Bitcoin variação'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Bitcoin variação'), findsOneWidget);
  });

  testWidgets('Dashboard shows error with retry', (tester) async {
    final cubit = DashboardCubit(
      getWalletSummaryUseCase: GetWalletSummaryUseCase(
        _FailingWalletSummaryRepository(),
      ),
      listTransactionsUseCase: ListTransactionsUseCase(
        _StubListTransactionsRepository(items: const []),
      ),
      snapshotProvider: snapshotProvider,
      preferences: prefs,
    );
    await cubit.load();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const DashboardPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('Transactions shows empty state', (tester) async {
    final cubit = TransactionsCubit(
      listTransactionsUseCase: ListTransactionsUseCase(
        _StubListTransactionsRepository(items: const []),
      ),
      snapshotProvider: snapshotProvider,
    );
    await cubit.load();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const TransactionsPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Extrato'), findsOneWidget);
    expect(find.text('Nenhuma transação encontrada'), findsOneWidget);
  });

  testWidgets('Transaction detail shows fields and copy action', (tester) async {
    final cubit = TransactionDetailCubit(
      getTransactionDetailUseCase: GetTransactionDetailUseCase(
        _StubGetByIdRepository(sampleTx),
      ),
      transactionId: sampleTx.id,
    );
    await cubit.load();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: TransactionDetailPage(transactionId: sampleTx.id),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Detalhe da transação'), findsOneWidget);
    expect(find.text(sampleTx.id), findsOneWidget);
    expect(find.text('Bitcoin variação'), findsOneWidget);
    expect(find.byTooltip('Copiar identificador'), findsOneWidget);
  });
}

final class _StubWalletSummaryRepository implements GetWalletSummaryRepository {
  @override
  Future<Result<WalletSummaryEntity>> getSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return const Success(
      WalletSummaryEntity(
        availableBalance: Money(10000),
        totalIncome: Money(5000),
        totalExpense: Money(2000),
      ),
    );
  }
}

final class _FailingWalletSummaryRepository
    implements GetWalletSummaryRepository {
  @override
  Future<Result<WalletSummaryEntity>> getSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return const Error(NetworkFailure(message: 'offline'));
  }
}

final class _StubListTransactionsRepository
    implements ListTransactionsRepository {
  _StubListTransactionsRepository({required this.items});

  final List<TransactionEntity> items;

  @override
  Future<Result<PagedTransactions>> list({
    TransactionFilters filters = const TransactionFilters(),
    String? cursor,
    int limit = 20,
  }) async {
    return Success(PagedTransactions(items: items));
  }
}

final class _StubGetByIdRepository implements GetTransactionByIdRepository {
  _StubGetByIdRepository(this.transaction);

  final TransactionEntity transaction;

  @override
  Future<Result<TransactionEntity>> getById(String id) async {
    return Success(transaction);
  }
}

final class _FailingDatasource implements CoinMarketDatasource {
  @override
  Future<MarketChartModel> getMarketChart({
    required String coinId,
    required String vsCurrency,
    required int days,
  }) {
    throw Exception('not used');
  }

  @override
  Future<CoinPriceModel> getSimplePrice({
    required String coinId,
    required String vsCurrency,
  }) {
    throw Exception('not used');
  }
}
