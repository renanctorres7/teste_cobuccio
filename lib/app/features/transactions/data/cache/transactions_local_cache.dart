import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_cobuccio/app/features/transactions/infra/models/market_chart_model.dart';

final class TransactionsLocalCache {
  TransactionsLocalCache(this._prefs);

  static const _chartKey = 'cached_market_chart_v1';
  static const _priceKey = 'cached_coin_price_v1';

  final SharedPreferences _prefs;

  Future<void> save({
    required MarketChartModel chart,
    required double price,
  }) async {
    await _prefs.setString(_chartKey, jsonEncode(chart.toJson()));
    await _prefs.setDouble(_priceKey, price);
  }

  CachedMarketData? read() {
    final chartRaw = _prefs.getString(_chartKey);
    final price = _prefs.getDouble(_priceKey);
    if (chartRaw == null || price == null) {
      return null;
    }

    final decoded = jsonDecode(chartRaw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return CachedMarketData(
      chart: MarketChartModel.fromJson(decoded),
      price: price,
    );
  }
}

final class CachedMarketData {
  const CachedMarketData({
    required this.chart,
    required this.price,
  });

  final MarketChartModel chart;
  final double price;
}
