import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_filters.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_status_enum.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/features/transactions/data/cache/transactions_local_cache.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/repository/list_transactions_repository.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/usecases/list_transactions_usecase.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/financial_snapshot_provider.dart';
import 'package:teste_cobuccio/app/presentation/transactions/view_model/transactions_cubit.dart';
import 'package:teste_cobuccio/app/presentation/transactions/view_model/transactions_state.dart';

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

  TransactionsCubit buildCubit(ListTransactionsRepository repo) {
    return TransactionsCubit(
      listTransactionsUseCase: ListTransactionsUseCase(repo),
      snapshotProvider: snapshot,
    );
  }

  test('starts in loading', () {
    final cubit = buildCubit(StubListTransactionsRepository());
    expect(cubit.state, isA<TransactionsLoading>());
  });

  test('load emits success', () async {
    final tx = sampleTransaction();
    final cubit = buildCubit(
      StubListTransactionsRepository(items: [tx]),
    );
    await cubit.load();

    final state = cubit.state as TransactionsSuccess;
    expect(state.items, [tx]);
    expect(state.hasMore, isFalse);
    expect(state.filters, const TransactionFilters());
  });

  test('load emits empty success', () async {
    final cubit = buildCubit(StubListTransactionsRepository(items: const []));
    await cubit.load();

    expect((cubit.state as TransactionsSuccess).items, isEmpty);
  });

  test('load emits failure', () async {
    final cubit = buildCubit(
      StubListTransactionsRepository(
        failure: const NetworkFailure(message: 'down'),
      ),
    );
    await cubit.load();

    expect(cubit.state, isA<TransactionsFailure>());
  });

  test('applyFilters updates type and reloads', () async {
    final repo = StubListTransactionsRepository(items: [sampleTransaction()]);
    final cubit = buildCubit(repo);
    await cubit.load();

    await cubit.applyFilters(type: TransactionTypeEnum.expense);

    expect(repo.lastFilters?.type, TransactionTypeEnum.expense);
    expect(
      (cubit.state as TransactionsSuccess).filters.type,
      TransactionTypeEnum.expense,
    );
  });

  test('applyFilters can clear type status and period', () async {
    final repo = StubListTransactionsRepository(items: const []);
    final cubit = buildCubit(repo);
    await cubit.applyFilters(
      type: TransactionTypeEnum.income,
      status: TransactionStatusEnum.pending,
      startDate: DateTime.utc(2024, 1, 1),
      endDate: DateTime.utc(2024, 1, 31),
    );
    await cubit.applyFilters(
      clearType: true,
      clearStatus: true,
      clearPeriod: true,
    );

    final filters = (cubit.state as TransactionsSuccess).filters;
    expect(filters.type, isNull);
    expect(filters.status, isNull);
    expect(filters.startDate, isNull);
    expect(filters.endDate, isNull);
  });

  test('onQueryChanged debounces before applying query', () {
    fakeAsync((async) {
      final repo = StubListTransactionsRepository(items: const []);
      final cubit = buildCubit(repo);

      cubit.onQueryChanged('bit');
      cubit.onQueryChanged('bitcoin');
      expect(repo.callCount, 0);

      async.elapse(const Duration(milliseconds: 399));
      async.flushMicrotasks();
      expect(repo.callCount, 0);

      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();
      expect(repo.callCount, 1);
      expect(repo.lastFilters?.query, 'bitcoin');

      cubit.close();
    });
  });

  test('loadMore appends next page', () async {
    final page1 = [sampleTransaction(id: '1', description: 'A')];
    final page2 = [sampleTransaction(id: '2', description: 'B')];
    final cubit = buildCubit(
      PagingListTransactionsRepository(page1: page1, page2: page2),
    );
    await cubit.load();

    await cubit.loadMore();

    final state = cubit.state as TransactionsSuccess;
    expect(state.items.map((e) => e.id), ['1', '2']);
    expect(state.hasMore, isFalse);
    expect(state.isLoadingMore, isFalse);
  });

  test('loadMore is no-op when hasMore is false', () async {
    final repo = StubListTransactionsRepository(
      items: [sampleTransaction()],
    );
    final cubit = buildCubit(repo);
    await cubit.load();
    final callsAfterLoad = repo.callCount;

    await cubit.loadMore();
    expect(repo.callCount, callsAfterLoad);
  });

  test('loadMore failure keeps previous items and clears loadingMore', () async {
    final cubit = buildCubit(
      PagingListTransactionsRepository(
        page1: [sampleTransaction(id: '1')],
        page2: const [],
        loadMoreFailure: const RateLimitFailure(),
      ),
    );
    await cubit.load();
    await cubit.loadMore();

    final state = cubit.state as TransactionsSuccess;
    expect(state.items.single.id, '1');
    expect(state.isLoadingMore, isFalse);
  });

  test('forceRefresh clears memory and reloads', () async {
    final cubit = buildCubit(
      StubListTransactionsRepository(items: [sampleTransaction()]),
    );
    await cubit.load(forceRefresh: true);
    expect(cubit.state, isA<TransactionsSuccess>());
  });
}
