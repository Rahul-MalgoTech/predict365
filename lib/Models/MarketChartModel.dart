// lib/Models/MarketDataModel.dart

class CandleData {
  final String   marketId;
  final DateTime intervalStart;
  final double   open;
  final double   high;
  final double   low;
  final double   close;
  final double   volume;

  CandleData({
    required this.marketId,
    required this.intervalStart,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory CandleData.fromJson(Map<String, dynamic> json) {
    return CandleData(
      marketId:      json['marketId']      ?? '',
      intervalStart: DateTime.parse(json['intervalStart']),
      open:          (json['open']   as num).toDouble(),
      high:          (json['high']   as num).toDouble(),
      low:           (json['low']    as num).toDouble(),
      close:         (json['close']  as num).toDouble(),
      volume:        (json['volume'] as num).toDouble(),
    );
  }
}

class MarketDataResponse {
  final bool                          success;
  final String                        eventId;
  // marketId → list of candles
  final Map<String, List<CandleData>> candlesByMarket;

  MarketDataResponse({
    required this.success,
    required this.eventId,
    required this.candlesByMarket,
  });

  factory MarketDataResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['candlesByMarket'] as Map<String, dynamic>? ?? {};
    final candles = raw.map((key, value) {
      final list = (value as List<dynamic>)
          .map((e) => CandleData.fromJson(e as Map<String, dynamic>))
          .toList();
      return MapEntry(key, list);
    });
    return MarketDataResponse(
      success:         json['success'] ?? false,
      eventId:         json['eventId'] ?? '',
      candlesByMarket: candles,
    );
  }

  /// All candles merged & sorted by time (for single-market view)
  List<CandleData> get allCandles {
    final all = candlesByMarket.values.expand((c) => c).toList()
      ..sort((a, b) => a.intervalStart.compareTo(b.intervalStart));
    return all;
  }

  /// Candles for a specific marketId
  List<CandleData> candlesFor(String marketId) =>
      candlesByMarket[marketId] ?? [];
}