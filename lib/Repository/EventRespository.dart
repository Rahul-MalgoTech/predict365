// lib/Repository/EventRespository.dart

import 'package:flutter/foundation.dart';
import 'package:predict365/APIService/Remote/network/NetworkApiService.dart';
import 'package:predict365/Models/EventModel.dart';

class EventRepository {
  final NetworkApiService _apiService = NetworkApiService();

  Future<EventsResponseModel> getEvents() async {
    final response = await _apiService.getResponse('/event/events');
    return EventsResponseModel.fromJson(response);
  }

  Future<EventSingleResponseModel> getEventById(String eventId) async {
    final response = await _apiService.getResponse('/event/events/$eventId');

    // ── DEBUG: print raw response so we can see the exact shape ──
    if (kDebugMode) {
      final marketsRaw = response['markets'] ?? response['event']?['markets'];
      debugPrint('=== SINGLE EVENT RAW KEYS: ${response.keys.toList()}');
      debugPrint('=== markets field: $marketsRaw');
      debugPrint('=== event field keys: ${response['event']?.keys?.toList()}');
    }

    return EventSingleResponseModel.fromJson(response);
  }
}