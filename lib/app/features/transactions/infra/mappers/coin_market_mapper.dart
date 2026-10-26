import 'package:teste_cobuccio/app/core/domain/money.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_status_enum.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/market_chart_model.dart';

/// Adapta dados da CoinGecko (histórico/preço) para o domínio financeiro do app.
///
/// A API não fornece extrato bancário; por isso transformamos variações de preço
/// em [TransactionEntity] (entrada/saída) e o preço atual em saldo ([Money]).
abstract final class CoinMarketMapper {
  /// Converte pontos do market chart em transações.
  ///
  /// Para cada par consecutivo de preços:
  /// - variação positiva → [TransactionTypeEnum.income]
  /// - variação negativa → [TransactionTypeEnum.expense]
  /// - valor absoluto da variação em centavos
  /// - data UTC a partir do timestamp do ponto
  ///
  /// Retorna do mais recente para o mais antigo. Ignora deltas zerados.
  static List<TransactionEntity> fromMarketChart(
    MarketChartModel chart, {
    String coinId = 'bitcoin',
  }) {
    if (chart.prices.length < 2) {
      return const [];
    }

    final transactions = <TransactionEntity>[];

    for (var i = 1; i < chart.prices.length; i++) {
      final previous = chart.prices[i - 1];
      final current = chart.prices[i];
      final delta = current.price - previous.price;
      if (delta == 0) {
        continue;
      }

      final cents = (delta.abs() * 100).round();
      if (cents == 0) {
        continue;
      }

      final id = '$coinId-${current.timestampMs}';
      final type =
          delta > 0 ? TransactionTypeEnum.income : TransactionTypeEnum.expense;
      final occurredAt =
          DateTime.fromMillisecondsSinceEpoch(current.timestampMs, isUtc: true);

      transactions.add(
        TransactionEntity(
          id: id,
          description: _descriptionFor(coinId, type),
          amount: Money(cents),
          occurredAt: occurredAt,
          type: type,
          status: _statusFor(id),
          metadata: {
            'coinId': coinId,
            'price': current.price.toStringAsFixed(2),
          },
        ),
      );
    }

    return transactions.reversed.toList(growable: false);
  }

  /// Calcula o saldo disponível a partir do preço atual.
  ///
  /// Usa um holding fictício (padrão: 1 unidade da moeda) e converte para
  /// centavos, alinhado ao value object [Money].
  static Money balanceFromPrice(double price, {double holding = 1}) {
    return Money((price * holding * 100).round());
  }

  static String _descriptionFor(String coinId, TransactionTypeEnum type) {
    final label = coinId.toUpperCase();
    return type == TransactionTypeEnum.income
        ? 'Valorização $label'
        : 'Desvalorização $label';
  }

  /// Status determinístico a partir do id (não vem da API).
  /// Serve para exercitar filtros de status na UI (pending/failed/refunded).
  static TransactionStatusEnum _statusFor(String id) {
    final hash = id.hashCode.abs();
    return switch (hash % 10) {
      0 => TransactionStatusEnum.pending,
      1 => TransactionStatusEnum.failed,
      2 => TransactionStatusEnum.refunded,
      _ => TransactionStatusEnum.completed,
    };
  }
}
