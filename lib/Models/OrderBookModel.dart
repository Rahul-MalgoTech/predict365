// lib/Models/OrderBookModel.dart

class OrderBookLevel {
  final double price;   // e.g. 0.51 → displayed as 51¢
  final double shares;
  final double total;   // price * shares in USD

  const OrderBookLevel({
    required this.price,
    required this.shares,
    required this.total,
  });

  String get priceLabel {
    final cents = (price * 100).round();
    return '$cents¢';
  }

  String get totalLabel => '\$${total.toStringAsFixed(2)}';
}

class OrderBook {
  final List<OrderBookLevel> asks; // sorted ascending  (lowest ask first → top of book)
  final List<OrderBookLevel> bids; // sorted descending (highest bid first → top of book)
  final double? bestBid;
  final double? bestAsk;
  final double? ltp;

  const OrderBook({
    required this.asks,
    required this.bids,
    this.bestBid,
    this.bestAsk,
    this.ltp,
  });

  double? get spread =>
      (bestBid != null && bestAsk != null) ? bestAsk! - bestBid! : null;

  String get spreadLabel {
    if (spread == null) return '-';
    return '${(spread! * 100).round()}¢';
  }

  String get ltpLabel =>
      ltp != null ? '${(ltp! * 100).round()}¢' : '-';

  static OrderBook empty() =>
      const OrderBook(asks: [], bids: [], bestBid: null, bestAsk: null);

  /// Build from raw snapshot maps  { "0.51": 9, "0.52": 10, … }
  static OrderBook fromMaps({
    required Map<String, double> bidsMap,
    required Map<String, double> asksMap,
    double? bestBid,
    double? bestAsk,
    double? ltp,
  }) {
    final bids = bidsMap.entries
        .map((e) {
      final p = double.tryParse(e.key) ?? 0;
      return OrderBookLevel(price: p, shares: e.value, total: p * e.value);
    })
        .where((l) => l.shares > 0)
        .toList()
      ..sort((a, b) => b.price.compareTo(a.price)); // highest first

    final asks = asksMap.entries
        .map((e) {
      final p = double.tryParse(e.key) ?? 0;
      return OrderBookLevel(price: p, shares: e.value, total: p * e.value);
    })
        .where((l) => l.shares > 0)
        .toList()
      ..sort((a, b) => b.price.compareTo(a.price)); // highest first → shown top-down

    return OrderBook(
      bids: bids,
      asks: asks,
      bestBid: bestBid,
      bestAsk: bestAsk,
      ltp: ltp,
    );
  }
}