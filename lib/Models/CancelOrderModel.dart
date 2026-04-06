// lib/Models/CancelOrderModel.dart

// ── Request Model ─────────────────────────────────────────────────
class CancelOrderRequest {
  final String marketId;
  final String outcome;

  CancelOrderRequest({
    required this.marketId,
    required this.outcome,
  });

  Map<String, dynamic> toJson() => {
    'marketId': marketId,
    'outcome': outcome,
  };
}

// ── Response Models ───────────────────────────────────────────────
class CancelOrderResult {
  final String orderId;

  CancelOrderResult({required this.orderId});

  factory CancelOrderResult.fromJson(Map<String, dynamic> json) {
    return CancelOrderResult(
      orderId: json['orderId'] ?? '',
    );
  }
}

class CancelOrderReply {
  final bool   ok;
  final String requestId;
  final int    ts;
  final CancelOrderResult result;

  CancelOrderReply({
    required this.ok,
    required this.requestId,
    required this.ts,
    required this.result,
  });

  factory CancelOrderReply.fromJson(Map<String, dynamic> json) {
    return CancelOrderReply(
      ok:        json['ok']        ?? false,
      requestId: json['requestId'] ?? '',
      ts:        (json['ts'] as num?)?.toInt() ?? 0,
      result:    CancelOrderResult.fromJson(
        json['result'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class CancelOrderResponse {
  final bool             success;
  final String           message;
  final CancelOrderReply reply;

  CancelOrderResponse({
    required this.success,
    required this.message,
    required this.reply,
  });

  factory CancelOrderResponse.fromJson(Map<String, dynamic> json) {
    return CancelOrderResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      reply:   CancelOrderReply.fromJson(
        json['reply'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// Shortcut — the cancelled order id
  String get cancelledOrderId => reply.result.orderId;
}