import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_cobuccio/app/core/network/dio_client.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/repository/get_wallet_balance_repository.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/repository/get_wallet_summary_repository.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:teste_cobuccio/app/features/dashboard/infra/repository/get_wallet_balance_repository_impl.dart';
import 'package:teste_cobuccio/app/features/dashboard/infra/repository/get_wallet_summary_repository_impl.dart';
import 'package:teste_cobuccio/app/features/transaction_detail/domain/repository/get_transaction_by_id_repository.dart';
import 'package:teste_cobuccio/app/features/transaction_detail/domain/usecases/get_transaction_detail_usecase.dart';
import 'package:teste_cobuccio/app/features/transaction_detail/infra/repository/get_transaction_by_id_repository_impl.dart';
import 'package:teste_cobuccio/app/features/transactions/data/datasource/dio_coin_market_datasource.dart';
import 'package:teste_cobuccio/app/features/transactions/data/service/coin_gecko_service.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/repository/list_transactions_repository.dart';
import 'package:teste_cobuccio/app/features/transactions/domain/usecases/list_transactions_usecase.dart';
import 'package:teste_cobuccio/app/features/transactions/data/cache/transactions_local_cache.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/datasources/coin_market_datasource.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/financial_snapshot_provider.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/repository/list_transactions_repository_impl.dart';
import 'package:teste_cobuccio/app/presentation/dashboard/view_model/dashboard_cubit.dart';
import 'package:teste_cobuccio/app/presentation/transaction_detail/view_model/transaction_detail_cubit.dart';
import 'package:teste_cobuccio/app/presentation/transactions/view_model/transactions_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  _registerCore();
  await _registerData();
  _registerInfra();
  _registerDomain();
  _registerPresentation();
}

void _registerCore() {
  getIt.registerLazySingleton<Dio>(DioClient.create);
}

Future<void> _registerData() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerLazySingleton<TransactionsLocalCache>(
    () => TransactionsLocalCache(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<CoinGeckoService>(
    () => CoinGeckoService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<CoinMarketDatasource>(
    () => DioCoinMarketDatasource(getIt<CoinGeckoService>()),
  );
}

void _registerInfra() {
  getIt.registerLazySingleton<FinancialSnapshotProvider>(
    () => FinancialSnapshotProvider(
      datasource: getIt<CoinMarketDatasource>(),
      cache: getIt<TransactionsLocalCache>(),
    ),
  );
  getIt.registerLazySingleton<ListTransactionsRepository>(
    () => ListTransactionsRepositoryImpl(getIt<FinancialSnapshotProvider>()),
  );
  getIt.registerLazySingleton<GetTransactionByIdRepository>(
    () =>
        GetTransactionByIdRepositoryImpl(getIt<FinancialSnapshotProvider>()),
  );
  getIt.registerLazySingleton<GetWalletSummaryRepository>(
    () => GetWalletSummaryRepositoryImpl(getIt<FinancialSnapshotProvider>()),
  );
  getIt.registerLazySingleton<GetWalletBalanceRepository>(
    () => GetWalletBalanceRepositoryImpl(getIt<FinancialSnapshotProvider>()),
  );
}

void _registerDomain() {
  getIt.registerLazySingleton<ListTransactionsUseCase>(
    () => ListTransactionsUseCase(getIt<ListTransactionsRepository>()),
  );
  getIt.registerLazySingleton<GetTransactionDetailUseCase>(
    () => GetTransactionDetailUseCase(getIt<GetTransactionByIdRepository>()),
  );
  getIt.registerLazySingleton<GetWalletSummaryUseCase>(
    () => GetWalletSummaryUseCase(getIt<GetWalletSummaryRepository>()),
  );
}

void _registerPresentation() {
  getIt.registerFactory(
    () => DashboardCubit(
      getWalletSummaryUseCase: getIt(),
      listTransactionsUseCase: getIt(),
      snapshotProvider: getIt(),
      preferences: getIt(),
    ),
  );
  getIt.registerFactory(
    () => TransactionsCubit(
      listTransactionsUseCase: getIt(),
      snapshotProvider: getIt(),
    ),
  );
  getIt.registerFactoryParam<TransactionDetailCubit, String, void>(
    (id, _) => TransactionDetailCubit(
      getTransactionDetailUseCase: getIt(),
      transactionId: id,
    ),
  );
}
