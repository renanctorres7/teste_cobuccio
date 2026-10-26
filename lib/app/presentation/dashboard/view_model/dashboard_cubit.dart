import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/usecases/list_transactions_usecase.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/financial_snapshot_provider.dart';
import 'package:teste_cobuccio/app/presentation/dashboard/view_model/dashboard_state.dart';

final class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required this._getWalletSummaryUseCase,
    required this._listTransactionsUseCase,
    required this._snapshotProvider,
    required this._preferences,
  }) : super(const DashboardLoading());

  static const _balanceHiddenKey = 'balance_hidden';

  final GetWalletSummaryUseCase _getWalletSummaryUseCase;
  final ListTransactionsUseCase _listTransactionsUseCase;
  final FinancialSnapshotProvider _snapshotProvider;
  final SharedPreferences _preferences;

  Future<void> load({bool forceRefresh = false}) async {
    emit(const DashboardLoading());
    if (forceRefresh) {
      _snapshotProvider.clearMemory();
    }

    final summaryResult = await _getWalletSummaryUseCase();
    final recentResult = await _listTransactionsUseCase(limit: 5);
    final isHidden = _preferences.getBool(_balanceHiddenKey) ?? false;

    summaryResult.when(
      success: (summary) {
        recentResult.when(
          success: (page) {
            emit(
              DashboardSuccess(
                summary: summary,
                recentTransactions: page.items,
                isBalanceHidden: isHidden,
              ),
            );
          },
          error: (failure) => emit(DashboardFailure(failure)),
        );
      },
      error: (failure) => emit(DashboardFailure(failure)),
    );
  }

  Future<void> toggleBalanceVisibility() async {
    final current = state;
    if (current is! DashboardSuccess) {
      return;
    }
    final next = !current.isBalanceHidden;
    await _preferences.setBool(_balanceHiddenKey, next);
    emit(current.copyWith(isBalanceHidden: next));
  }
}
