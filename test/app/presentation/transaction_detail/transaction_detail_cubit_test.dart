import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/features/transaction_detail/domain/usecases/get_transaction_detail_usecase.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view_model/transaction_detail_cubit.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view_model/transaction_detail_state.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/fixtures.dart';

void main() {
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

  test('starts in loading', () {
    expect(buildCubit().state, isA<TransactionDetailLoading>());
  });

  test('load emits success', () async {
    final tx = sampleTransaction();
    final cubit = buildCubit(
      repo: StubGetByIdRepository(transaction: tx),
      transactionId: tx.id,
    );

    await cubit.load();

    expect(cubit.state, TransactionDetailSuccess(tx));
    expect((cubit.state as TransactionDetailSuccess).isOffline, isFalse);
  });

  test('load emits isOffline when network is offline', () async {
    final tx = sampleTransaction();
    final cubit = buildCubit(
      repo: StubGetByIdRepository(transaction: tx),
      transactionId: tx.id,
      networkInfo: FakeNetworkInfo(online: false),
    );

    await cubit.load();

    expect((cubit.state as TransactionDetailSuccess).isOffline, isTrue);
  });

  test('load emits failure', () async {
    final cubit = buildCubit(
      repo: StubGetByIdRepository(failure: const CacheFailure()),
      transactionId: 'missing',
    );

    await cubit.load();

    expect(cubit.state, isA<TransactionDetailFailure>());
    expect(
      (cubit.state as TransactionDetailFailure).failure,
      const CacheFailure(),
    );
  });

  test('empty id fails in use case without hitting repository', () async {
    final repo = StubGetByIdRepository();
    final cubit = buildCubit(repo: repo, transactionId: '   ');

    await cubit.load();

    expect(repo.callCount, 0);
    expect(cubit.state, isA<TransactionDetailFailure>());
    expect(
      (cubit.state as TransactionDetailFailure).failure,
      isA<UnexpectedFailure>(),
    );
  });
}
