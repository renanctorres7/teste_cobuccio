import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teste_cobuccio/app/core/network/network_info.dart';
import 'package:teste_cobuccio/app/features/transaction_detail/domain/usecases/get_transaction_detail_usecase.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view_model/transaction_detail_state.dart';

final class TransactionDetailCubit extends Cubit<TransactionDetailState> {
  TransactionDetailCubit({
    required this._getTransactionDetailUseCase,
    required this.transactionId,
    required this._networkInfo,
  }) : super(const TransactionDetailLoading()) {
    _connectivitySub = _networkInfo.onStatusChanged.listen(_onConnectivity);
  }

  final GetTransactionDetailUseCase _getTransactionDetailUseCase;
  final String transactionId;
  final NetworkInfo _networkInfo;

  StreamSubscription<bool>? _connectivitySub;

  Future<void> load() async {
    emit(const TransactionDetailLoading());
    final isOffline = !await _networkInfo.isOnline;
    final result = await _getTransactionDetailUseCase(transactionId);
    result.when(
      success: (transaction) => emit(
        TransactionDetailSuccess(transaction, isOffline: isOffline),
      ),
      error: (failure) => emit(TransactionDetailFailure(failure)),
    );
  }

  void _onConnectivity(bool online) {
    final current = state;
    if (current is! TransactionDetailSuccess) {
      return;
    }
    final isOffline = !online;
    if (current.isOffline == isOffline) {
      return;
    }
    emit(current.copyWith(isOffline: isOffline));
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
