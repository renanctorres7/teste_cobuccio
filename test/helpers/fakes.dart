import 'package:teste_cobuccio/app/core/domain/paged_transactions.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_filters.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/entities/wallet_summary_entity.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/repository/get_wallet_summary_repository.dart';
import 'package:teste_cobuccio/app/features/transaction_detail/domain/repository/get_transaction_by_id_repository.dart';
import 'package:teste_cobuccio/app/features/transactions/data/cache/transactions_local_cache.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/repository/list_transactions_repository.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/datasources/coin_market_datasource.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/coin_price_model.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/market_chart_model.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/financial_snapshot_provider.dart';

import 'fixtures.dart';

final class StubWalletSummaryRepository implements GetWalletSummaryRepository {
  StubWalletSummaryRepository({
    this.summary = sampleSummary,
    this.failure,
  });

  final WalletSummaryEntity summary;
  final Failure? failure;
  var callCount = 0;

  @override
  Future<Result<WalletSummaryEntity>> getSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    callCount++;
    if (failure != null) {
      return Error(failure!);
    }
    return Success(summary);
  }
}

final class StubListTransactionsRepository
    implements ListTransactionsRepository {
  StubListTransactionsRepository({
    this.items = const [],
    this.failure,
    this.hasMore = false,
    this.nextCursor,
  });

  List<TransactionEntity> items;
  Failure? failure;
  bool hasMore;
  String? nextCursor;
  TransactionFilters? lastFilters;
  String? lastCursor;
  int? lastLimit;
  var callCount = 0;

  @override
  Future<Result<PagedTransactions>> list({
    TransactionFilters filters = const TransactionFilters(),
    String? cursor,
    int limit = 20,
  }) async {
    callCount++;
    lastFilters = filters;
    lastCursor = cursor;
    lastLimit = limit;
    if (failure != null) {
      return Error(failure!);
    }
    return Success(
      PagedTransactions(
        items: items,
        hasMore: hasMore,
        nextCursor: nextCursor,
      ),
    );
  }
}

/// Returns [page1] with cursor on first call; [page2] when cursor is set.
final class PagingListTransactionsRepository
    implements ListTransactionsRepository {
  PagingListTransactionsRepository({
    required this.page1,
    required this.page2,
    this.loadMoreFailure,
  });

  final List<TransactionEntity> page1;
  final List<TransactionEntity> page2;
  final Failure? loadMoreFailure;
  var callCount = 0;

  @override
  Future<Result<PagedTransactions>> list({
    TransactionFilters filters = const TransactionFilters(),
    String? cursor,
    int limit = 20,
  }) async {
    callCount++;
    if (cursor == null) {
      return Success(
        PagedTransactions(
          items: page1,
          hasMore: true,
          nextCursor: 'page-2',
        ),
      );
    }
    if (loadMoreFailure != null) {
      return Error(loadMoreFailure!);
    }
    return Success(PagedTransactions(items: page2));
  }
}

final class StubGetByIdRepository implements GetTransactionByIdRepository {
  StubGetByIdRepository({
    this.transaction,
    this.failure,
  });

  TransactionEntity? transaction;
  Failure? failure;
  String? lastId;
  var callCount = 0;

  @override
  Future<Result<TransactionEntity>> getById(String id) async {
    callCount++;
    lastId = id;
    if (failure != null) {
      return Error(failure!);
    }
    return Success(transaction ?? sampleTransaction(id: id));
  }
}

final class FailingDatasource implements CoinMarketDatasource {
  @override
  Future<MarketChartModel> getMarketChart({
    required String coinId,
    required String vsCurrency,
    required int days,
  }) {
    throw Exception('not used');
  }

  @override
  Future<CoinPriceModel> getSimplePrice({
    required String coinId,
    required String vsCurrency,
  }) {
    throw Exception('not used');
  }
}

FinancialSnapshotProvider unusedSnapshotProvider(
  TransactionsLocalCache cache,
) {
  return FinancialSnapshotProvider(
    datasource: FailingDatasource(),
    cache: cache,
  );
}
