import 'package:equatable/equatable.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/entities/wallet_summary_entity.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardSuccess extends DashboardState {
  const DashboardSuccess({
    required this.summary,
    required this.recentTransactions,
    required this.isBalanceHidden,
  });

  final WalletSummaryEntity summary;
  final List<TransactionEntity> recentTransactions;
  final bool isBalanceHidden;

  DashboardSuccess copyWith({
    WalletSummaryEntity? summary,
    List<TransactionEntity>? recentTransactions,
    bool? isBalanceHidden,
  }) {
    return DashboardSuccess(
      summary: summary ?? this.summary,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      isBalanceHidden: isBalanceHidden ?? this.isBalanceHidden,
    );
  }

  @override
  List<Object?> get props => [summary, recentTransactions, isBalanceHidden];
}

final class DashboardFailure extends DashboardState {
  const DashboardFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
