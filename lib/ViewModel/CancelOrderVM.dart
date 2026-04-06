// lib/ViewModel/CancelOrderVM.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/CancelOrderModel.dart';
import 'package:predict365/Repository/CancelOrderRepository.dart';

enum CancelOrderStatus { idle, loading, success, error }

class CancelOrderViewModel extends ChangeNotifier {
  final CancelOrderRepository _repository = CancelOrderRepository();

  CancelOrderStatus _status       = CancelOrderStatus.idle;
  String            _errorMessage = '';
  String?           _cancelledOrderId;

  CancelOrderStatus get status           => _status;
  String            get errorMessage     => _errorMessage;
  String?           get cancelledOrderId => _cancelledOrderId;
  bool              get isLoading        => _status == CancelOrderStatus.loading;
  bool              get isSuccess        => _status == CancelOrderStatus.success;

  /// Cancel a pending order.
  ///
  /// [orderId]  — e.g. "o-1773813736870-1"
  /// [marketId] — the market's _id
  /// [outcome]  — "YES" or "NO"
  Future<bool> cancelOrder({
    required String orderId,
    required String marketId,
    required String outcome,
  }) async {
    _status       = CancelOrderStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _repository.cancelOrder(
        orderId:  orderId,
        marketId: marketId,
        outcome:  outcome,
      );

      if (response.success && response.reply.ok) {
        _cancelledOrderId = response.cancelledOrderId;
        _status           = CancelOrderStatus.success;
        notifyListeners();
        return true;
      } else {
        _status       = CancelOrderStatus.error;
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Cancel request failed.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status       = CancelOrderStatus.error;
      _errorMessage = _parseError(e.toString());
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status           = CancelOrderStatus.idle;
    _errorMessage     = '';
    _cancelledOrderId = null;
    notifyListeners();
  }

  String _parseError(String e) {
    if (e.contains('No Internet'))  return 'No internet connection.';
    if (e.contains('401'))          return 'Session expired. Please login again.';
    if (e.contains('403'))          return 'You are not authorised to cancel this order.';
    if (e.contains('404'))          return 'Order not found.';
    if (e.contains('500'))          return 'Server error. Please try again later.';
    return 'Something went wrong. Please try again.';
  }
}