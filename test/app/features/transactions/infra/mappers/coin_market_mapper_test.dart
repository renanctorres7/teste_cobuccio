import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_status_enum.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/mappers/coin_market_mapper.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/market_chart_model.dart';

void main() {
  group('CoinMarketMapper', () {
    test('maps price rises to income and drops to expense', () {
      final chart = MarketChartModel(
        prices: [
          const MarketChartPointModel(timestampMs: 1_000, price: 100),
          const MarketChartPointModel(timestampMs: 2_000, price: 110.5),
          const MarketChartPointModel(timestampMs: 3_000, price: 105.25),
        ],
      );

      final transactions = CoinMarketMapper.fromMarketChart(chart);

      expect(transactions, hasLength(2));
      expect(transactions[0].type, TransactionTypeEnum.expense);
      expect(transactions[0].amount.cents, 525);
      expect(transactions[1].type, TransactionTypeEnum.income);
      expect(transactions[1].amount.cents, 1050);
      expect(
        transactions.map((tx) => tx.status),
        everyElement(isA<TransactionStatusEnum>()),
      );
    });

    test('returns empty list when chart has fewer than 2 points', () {
      final chart = MarketChartModel(
        prices: [const MarketChartPointModel(timestampMs: 1_000, price: 100)],
      );

      expect(CoinMarketMapper.fromMarketChart(chart), isEmpty);
    });

    test('converts price holding to money cents', () {
      final balance = CoinMarketMapper.balanceFromPrice(250.75);
      expect(balance.cents, 25075);
    });
  });
}
