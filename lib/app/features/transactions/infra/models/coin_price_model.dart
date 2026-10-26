final class CoinPriceModel {
  const CoinPriceModel({
    required this.coinId,
    required this.price,
  });

  factory CoinPriceModel.fromSimplePriceJson(
    Map<String, dynamic> json, {
    required String coinId,
    required String vsCurrency,
  }) {
    final coin = json[coinId];
    if (coin is! Map) {
      throw const FormatException('Missing coin price payload');
    }
    final value = coin[vsCurrency];
    if (value is! num) {
      throw const FormatException('Missing currency price');
    }
    return CoinPriceModel(coinId: coinId, price: value.toDouble());
  }

  final String coinId;
  final double price;
}
