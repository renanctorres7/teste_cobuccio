final class MarketChartModel {
  const MarketChartModel({required this.prices});

  factory MarketChartModel.fromJson(Map<String, dynamic> json) {
    final rawPrices = json['prices'] as List<dynamic>? ?? const [];
    final prices = <MarketChartPointModel>[];

    for (final item in rawPrices) {
      if (item is! List || item.length < 2) {
        continue;
      }
      final timestamp = item[0];
      final price = item[1];
      if (timestamp is! num || price is! num) {
        continue;
      }
      prices.add(
        MarketChartPointModel(
          timestampMs: timestamp.toInt(),
          price: price.toDouble(),
        ),
      );
    }

    return MarketChartModel(prices: prices);
  }

  final List<MarketChartPointModel> prices;

  Map<String, dynamic> toJson() {
    return {
      'prices': prices
          .map((point) => [point.timestampMs, point.price])
          .toList(growable: false),
    };
  }
}

final class MarketChartPointModel {
  const MarketChartPointModel({
    required this.timestampMs,
    required this.price,
  });

  final int timestampMs;
  final double price;
}
