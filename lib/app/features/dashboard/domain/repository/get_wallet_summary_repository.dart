import 'package:teste_cobuccio/app/core/errors/result.dart';
import 'package:teste_cobuccio/app/features/dashboard/domain/entities/wallet_summary_entity.dart';

abstract interface class GetWalletSummaryRepository {
  Future<Result<WalletSummaryEntity>> getSummary({
    DateTime? startDate,
    DateTime? endDate,
  });
}
