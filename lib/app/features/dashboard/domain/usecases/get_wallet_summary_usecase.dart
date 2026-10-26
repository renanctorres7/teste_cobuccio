import 'package:teste_cobuccio/app/core/errors/result.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/entities/wallet_summary_entity.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/repository/get_wallet_summary_repository.dart';

final class GetWalletSummaryUseCase {
  const GetWalletSummaryUseCase(this._repository);

  final GetWalletSummaryRepository _repository;

  Future<Result<WalletSummaryEntity>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _repository.getSummary(startDate: startDate, endDate: endDate);
  }
}
