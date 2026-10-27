import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:teste_cobuccio/app/features/transaction_detail/domain/usecases/get_transaction_detail_usecase.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/usecases/list_transactions_usecase.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/fixtures.dart';

void main() {
  test('GetWalletSummaryUseCase delegates to repository', () async {
    final repo = StubWalletSummaryRepository();
    final useCase = GetWalletSummaryUseCase(repo);

    final result = await useCase();

    expect(result, isA<Success>());
    expect(repo.callCount, 1);
  });

  test('ListTransactionsUseCase passes filters cursor and limit', () async {
    final repo = StubListTransactionsRepository(items: [sampleTransaction()]);
    final useCase = ListTransactionsUseCase(repo);

    await useCase(cursor: 'c1', limit: 10);

    expect(repo.lastCursor, 'c1');
    expect(repo.lastLimit, 10);
  });

  test('GetTransactionDetailUseCase rejects blank id', () async {
    final repo = StubGetByIdRepository();
    final useCase = GetTransactionDetailUseCase(repo);

    final result = await useCase('  ');

    expect(result, isA<Error>());
    expect((result as Error).failure, isA<UnexpectedFailure>());
    expect(repo.callCount, 0);
  });

  test('GetTransactionDetailUseCase trims id', () async {
    final repo = StubGetByIdRepository(transaction: sampleTransaction());
    final useCase = GetTransactionDetailUseCase(repo);

    await useCase(' tx-1 ');

    expect(repo.lastId, 'tx-1');
  });
}
