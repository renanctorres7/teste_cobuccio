import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teste_cobuccio/app/features/transaction_detail/domain/usecases/get_transaction_detail_usecase.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view_model/transaction_detail_state.dart';

final class TransactionDetailCubit extends Cubit<TransactionDetailState> {
  TransactionDetailCubit({
    required this._getTransactionDetailUseCase,
    required this.transactionId,
  }) : super(const TransactionDetailLoading());

  final GetTransactionDetailUseCase _getTransactionDetailUseCase;
  final String transactionId;

  Future<void> load() async {
    emit(const TransactionDetailLoading());
    final result = await _getTransactionDetailUseCase(transactionId);
    result.when(
      success: (transaction) => emit(TransactionDetailSuccess(transaction)),
      error: (failure) => emit(TransactionDetailFailure(failure)),
    );
  }
}
