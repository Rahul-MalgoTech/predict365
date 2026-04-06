// lib/Repository/EventRespository.dart

import 'package:flutter/foundation.dart';
import 'package:predict365/APIService/Remote/network/NetworkApiService.dart';
import 'package:predict365/Models/EventModel.dart';

class EventRepository {
  final NetworkApiService _apiService = NetworkApiService();

  /// GET https://staging-api.predict365.com/api/events
  Future<EventsResponseModel> getEvents() async {
    final response = await _apiService.getResponse('events/home');

    if (kDebugMode) {
      final eventsRaw = response['events'];
      debugPrint('=== GET EVENTS ===');
      debugPrint('  top-level keys  : ${response.keys.toList()}');
      debugPrint('  events runtimeType: ${eventsRaw.runtimeType}');
      if (eventsRaw is Map) {
        debugPrint('  events count (map): ${eventsRaw.length}');
      } else if (eventsRaw is List) {
        debugPrint('  events count (list): ${eventsRaw.length}');
      }
    }

    return EventsResponseModel.fromJson(response);
  }

  /// GET https://staging-api.predict365.com/api/events/:id
  Future<EventSingleResponseModel> getEventById(String eventId) async {
    final response = await _apiService.getResponse('event/events/$eventId');

    if (kDebugMode) {
      debugPrint('=== GET SINGLE EVENT ($eventId) ===');
      debugPrint('  top-level keys: ${response.keys.toList()}');

      final eventRaw = response['event'] ?? response;
      if (eventRaw is Map) {
        debugPrint('  event keys: ${(eventRaw as Map).keys.toList()}');
        final marketsRaw = eventRaw['markets'] ?? eventRaw['sub_markets'];
        debugPrint('  markets runtimeType: ${marketsRaw?.runtimeType}');
        if (marketsRaw is Map) {
          debugPrint('  markets count (map): ${marketsRaw.length}');
          debugPrint('  first market keys: ${marketsRaw.values.isNotEmpty ? (marketsRaw.values.first as Map?)?.keys.toList() : 'none'}');
        } else if (marketsRaw is List) {
          debugPrint('  markets count (list): ${marketsRaw.length}');
        } else {
          debugPrint('  markets: null or unexpected shape');
        }
      }
    }

    return EventSingleResponseModel.fromJson(response);
  }
}