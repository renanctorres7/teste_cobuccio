import 'package:teste_cobuccio/app/core/domain/money.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';

abstract interface class GetWalletBalanceRepository {
  Future<Result<Money>> getBalance();
}
