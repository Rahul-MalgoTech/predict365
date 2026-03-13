// lib/Models/OrderModel.dart

import 'dart:math';

class OrderRequest {
  final String clientOrderId;
  final String marketId;
  final String side;        // "BUY" | "SELL"
  final String outcome;     // "YES" | "NO"
  final String orderType;   // "MARKET" | "LIMIT"
  final double price;
  final String shares;
  final String timeInForce; // "GTC" | "DAY" | "IOC" | "GTW"

  OrderRequest({
    required this.clientOrderId,
    required this.marketId,
    required this.side,
    required this.outcome,
    required this.orderType,
    required this.price,
    required this.shares,
    required this.timeInForce,
  });

  Map<String, dynamic> toJson() => {
    'clientOrderId': clientOrderId,
    'marketId':      marketId,
    'side':          side,
    'outcome':       outcome,
    'orderType':     orderType,
    'price':         price,
    'shares':        shares,
    'timeInForce':   timeInForce,
  };

  /// Dart equivalent of:
  ///   const makeClientOrderId = () =>
  ///     `cid-${Date.now()}-${Math.random().toString(16).slice(2, 8)}`;
  static String generateClientOrderId() {
    final ts  = DateTime.now().millisecondsSinceEpoch;        // Date.now()
    final hex = Random().nextInt(0xFFFFFF)                    // Math.random() fractional hex
        .toRadixString(16)
        .padLeft(6, '0');                                     // always 6 chars
    return 'cid-$ts-$hex';
  }
}

// ── Response ────────────────────────────────────────────────────
class OrderResponse {
  final bool         success;
  final String       message;
  final OrderResult? order;

  OrderResponse({
    required this.success,
    required this.message,
    this.order,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) => OrderResponse(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    order:   json['order'] != null
        ? OrderResult.fromJson(json['order'] as Map<String, dynamic>)
        : null,
  );
}

class OrderResult {
  final String orderId;
  final String clientOrderId;
  final String marketId;
  final String userId;
  final String side;           // "YES" | "NO"
  final String action;         // "BUY" | "SELL"
  final double price;
  final int    shares;
  final int    remaining;
  final String orderType;
  final String timeInForce;
  final String status;         // "ACKED" | "FILLED" | "CANCELLED"
  final double commissionHeld;

  OrderResult({
    required this.orderId,
    required this.clientOrderId,
    required this.marketId,
    required this.userId,
    required this.side,
    required this.action,
    required this.price,
    required this.shares,
    required this.remaining,
    required this.orderType,
    required this.timeInForce,
    required this.status,
    required this.commissionHeld,
  });

  factory OrderResult.fromJson(Map<String, dynamic> j) => OrderResult(
    orderId:        j['orderId']        ?? '',
    clientOrderId:  j['clientOrderId']  ?? '',
    marketId:       j['marketId']       ?? '',
    userId:         j['userId']         ?? '',
    side:           j['side']           ?? '',
    action:         j['action']         ?? '',
    price:          (j['price']         as num?)?.toDouble()  ?? 0,
    shares:         (j['shares']        as num?)?.toInt()     ?? 0,
    remaining:      (j['remaining']     as num?)?.toInt()     ?? 0,
    orderType:      j['orderType']      ?? '',
    timeInForce:    j['timeInForce']    ?? '',
    status:         j['status']         ?? '',
    commissionHeld: (j['commissionHeld'] as num?)?.toDouble() ?? 0,
  );
}