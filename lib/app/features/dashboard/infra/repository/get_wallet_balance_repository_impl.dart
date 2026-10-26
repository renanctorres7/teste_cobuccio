import 'package:teste_cobuccio/app/core/domain/money.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/repository/get_wallet_balance_repository.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/financial_snapshot_provider.dart';

final class GetWalletBalanceRepositoryImpl
    implements GetWalletBalanceRepository {
  const GetWalletBalanceRepositoryImpl(this._snapshotProvider);

  final FinancialSnapshotProvider _snapshotProvider;

  @override
  Future<Result<Money>> getBalance() async {
    final snapshotResult = await _snapshotProvider.getSnapshot();
    return snapshotResult.when(
      success: (snapshot) => Success(snapshot.balance),
      error: Error.new,
    );
  }
}
