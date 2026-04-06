// lib/Repository/CancelOrderRepository.dart

import 'package:flutter/foundation.dart';
import 'package:predict365/APIService/Remote/network/NetworkApiService.dart';
import 'package:predict365/Models/CancelOrderModel.dart';

class CancelOrderRepository {
  final NetworkApiService _apiService = NetworkApiService();

  /// POST https://staging-api.predict365.com/api/event/orders/:orderId/cancel
  ///
  /// Body: { "marketId": "...", "outcome": "YES" | "NO" }
  Future<CancelOrderResponse> cancelOrder({
    required String orderId,
    required String marketId,
    required String outcome,
  }) async {
    final request = CancelOrderRequest(marketId: marketId, outcome: outcome);

    if (kDebugMode) {
      debugPrint('=== CANCEL ORDER ===');
      debugPrint('  orderId  : $orderId');
      debugPrint('  marketId : $marketId');
      debugPrint('  outcome  : $outcome');
    }

    final response = await _apiService.postResponse(
      'event/orders/$orderId/cancel',
      body: request.toJson(),
    );

    if (kDebugMode) {
      debugPrint('  response : $response');
    }

    return CancelOrderResponse.fromJson(response);
  }
}