import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_filters.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_status_enum.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';
import 'package:teste_cobuccio/app/core/network/network_info.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/usecases/list_transactions_usecase.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/financial_snapshot_provider.dart';
import 'package:teste_cobuccio/app/presentation/transactions/view_model/transactions_state.dart';

final class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit({
    required this._listTransactionsUseCase,
    required this._snapshotProvider,
    required this._networkInfo,
  }) : super(const TransactionsLoading()) {
    _connectivitySub = _networkInfo.onStatusChanged.listen(_onConnectivity);
  }

  final ListTransactionsUseCase _listTransactionsUseCase;
  final FinancialSnapshotProvider _snapshotProvider;
  final NetworkInfo _networkInfo;

  TransactionFilters _filters = const TransactionFilters();
  Timer? _debounce;
  StreamSubscription<bool>? _connectivitySub;
  bool _isOffline = false;

  Future<void> load({bool forceRefresh = false}) async {
    emit(const TransactionsLoading());
    if (forceRefresh) {
      _snapshotProvider.clearMemory();
    }
    _isOffline = !await _networkInfo.isOnline;
    await _fetch(reset: true);
  }

  void onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _filters = TransactionFilters(
        type: _filters.type,
        status: _filters.status,
        startDate: _filters.startDate,
        endDate: _filters.endDate,
        query: query,
      );
      load();
    });
  }

  Future<void> applyFilters({
    TransactionTypeEnum? type,
    TransactionStatusEnum? status,
    DateTime? startDate,
    DateTime? endDate,
    bool clearType = false,
    bool clearStatus = false,
    bool clearPeriod = false,
  }) async {
    _filters = TransactionFilters(
      type: clearType ? null : (type ?? _filters.type),
      status: clearStatus ? null : (status ?? _filters.status),
      startDate: clearPeriod ? null : (startDate ?? _filters.startDate),
      endDate: clearPeriod ? null : (endDate ?? _filters.endDate),
      query: _filters.query,
    );
    await load();
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! TransactionsSuccess ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    await _fetch(reset: false, cursor: current.nextCursor);
  }

  Future<void> _fetch({required bool reset, String? cursor}) async {
    final previousItems = !reset && state is TransactionsSuccess
        ? (state as TransactionsSuccess).items
        : const <TransactionEntity>[];

    final result = await _listTransactionsUseCase(
      filters: _filters,
      cursor: reset ? null : cursor,
      limit: 20,
    );

    result.when(
      success: (page) {
        emit(
          TransactionsSuccess(
            items: [...previousItems, ...page.items],
            filters: _filters,
            hasMore: page.hasMore,
            nextCursor: page.nextCursor,
            isFromCache: page.isFromCache,
            isOffline: _isOffline,
          ),
        );
      },
      error: (failure) {
        if (reset) {
          emit(TransactionsFailure(failure));
        } else if (state is TransactionsSuccess) {
          emit((state as TransactionsSuccess).copyWith(isLoadingMore: false));
        }
      },
    );
  }

  void _onConnectivity(bool online) {
    _isOffline = !online;
    final current = state;
    if (current is! TransactionsSuccess) {
      return;
    }
    if (current.isOffline == _isOffline) {
      return;
    }
    emit(current.copyWith(isOffline: _isOffline));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _connectivitySub?.cancel();
    return super.close();
  }
}
