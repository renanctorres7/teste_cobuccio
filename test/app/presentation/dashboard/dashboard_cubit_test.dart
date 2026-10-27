import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:teste_cobuccio/app/features/transactions/data/cache/transactions_local_cache.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/usecases/list_transactions_usecase.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/financial_snapshot_provider.dart';
import 'package:teste_cobuccio/app/presentation/dashboard/view_model/dashboard_cubit.dart';
import 'package:teste_cobuccio/app/presentation/dashboard/view_model/dashboard_state.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late SharedPreferences prefs;
  late FinancialSnapshotProvider snapshot;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    snapshot = unusedSnapshotProvider(TransactionsLocalCache(prefs));
  });

  DashboardCubit buildCubit({
    StubWalletSummaryRepository? wallet,
    StubListTransactionsRepository? list,
  }) {
    return DashboardCubit(
      getWalletSummaryUseCase: GetWalletSummaryUseCase(
        wallet ?? StubWalletSummaryRepository(),
      ),
      listTransactionsUseCase: ListTransactionsUseCase(
        list ??
            StubListTransactionsRepository(items: [sampleTransaction()]),
      ),
      snapshotProvider: snapshot,
      preferences: prefs,
    );
  }

  test('starts in loading', () {
    expect(buildCubit().state, isA<DashboardLoading>());
  });

  test('load emits success with summary and recent transactions', () async {
    final cubit = buildCubit();
    await cubit.load();

    final state = cubit.state;
    expect(state, isA<DashboardSuccess>());
    state as DashboardSuccess;
    expect(state.summary, sampleSummary);
    expect(state.recentTransactions, [sampleTransaction()]);
    expect(state.isBalanceHidden, isFalse);
    expect(state.isFromCache, isFalse);
  });

  test('load propagates isFromCache from summary or list', () async {
    final cubit = buildCubit(
      wallet: StubWalletSummaryRepository(summary: sampleCachedSummary),
      list: StubListTransactionsRepository(
        items: [sampleTransaction()],
        isFromCache: true,
      ),
    );
    await cubit.load();

    final state = cubit.state as DashboardSuccess;
    expect(state.isFromCache, isTrue);
  });

  test('load emits empty recent list on success', () async {
    final cubit = buildCubit(
      list: StubListTransactionsRepository(items: const []),
    );
    await cubit.load();

    final state = cubit.state as DashboardSuccess;
    expect(state.recentTransactions, isEmpty);
  });

  test('load emits failure when wallet summary fails', () async {
    final cubit = buildCubit(
      wallet: StubWalletSummaryRepository(
        failure: const NetworkFailure(message: 'offline'),
      ),
    );
    await cubit.load();

    expect(cubit.state, isA<DashboardFailure>());
    expect(
      (cubit.state as DashboardFailure).failure,
      const NetworkFailure(message: 'offline'),
    );
  });

  test('load emits failure when recent transactions fail', () async {
    final cubit = buildCubit(
      list: StubListTransactionsRepository(
        failure: const ServerFailure(statusCode: 500),
      ),
    );
    await cubit.load();

    expect(cubit.state, isA<DashboardFailure>());
  });

  test('forceRefresh clears snapshot and reloads', () async {
    final cubit = buildCubit();
    await cubit.load(forceRefresh: true);
    expect(cubit.state, isA<DashboardSuccess>());
  });

  test('toggleBalanceVisibility persists and updates state', () async {
    final cubit = buildCubit();
    await cubit.load();

    await cubit.toggleBalanceVisibility();
    expect((cubit.state as DashboardSuccess).isBalanceHidden, isTrue);
    expect(prefs.getBool('balance_hidden'), isTrue);

    await cubit.toggleBalanceVisibility();
    expect((cubit.state as DashboardSuccess).isBalanceHidden, isFalse);
  });

  test('toggleBalanceVisibility is no-op when not success', () async {
    final cubit = buildCubit();
    await cubit.toggleBalanceVisibility();
    expect(cubit.state, isA<DashboardLoading>());
  });

  test('restores hidden preference on load', () async {
    await prefs.setBool('balance_hidden', true);
    final cubit = buildCubit();
    await cubit.load();
    expect((cubit.state as DashboardSuccess).isBalanceHidden, isTrue);
  });
}
