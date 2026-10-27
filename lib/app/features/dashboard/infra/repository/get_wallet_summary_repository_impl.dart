import 'package:teste_cobuccio/app/core/domain/period_totals_calculator.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/entities/wallet_summary_entity.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/repository/get_wallet_summary_repository.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/financial_snapshot_provider.dart';

final class GetWalletSummaryRepositoryImpl
    implements GetWalletSummaryRepository {
  const GetWalletSummaryRepositoryImpl(this._snapshotProvider);

  final FinancialSnapshotProvider _snapshotProvider;

  @override
  Future<Result<WalletSummaryEntity>> getSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final snapshotResult = await _snapshotProvider.getSnapshot();
    return snapshotResult.when(
      success: (snapshot) {
        final totals = PeriodTotalsCalculator.calculate(
          transactions: snapshot.transactions,
          startDate: startDate,
          endDate: endDate,
        );
        return Success(
          WalletSummaryEntity(
            availableBalance: snapshot.balance,
            totalIncome: totals.totalIncome,
            totalExpense: totals.totalExpense,
            isFromCache: snapshot.isFromCache,
          ),
        );
      },
      error: Error.new,
    );
  }
}
