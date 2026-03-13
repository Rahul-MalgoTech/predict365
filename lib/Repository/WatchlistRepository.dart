// lib/Repository/WatchlistRepository.dart

import 'package:flutter/foundation.dart';
import 'package:predict365/APIService/Remote/network/NetworkApiService.dart';
import 'package:predict365/Models/EventModel.dart';
import 'package:predict365/Repository/EventRespository.dart';

class WatchlistRepository {
  final NetworkApiService _apiService    = NetworkApiService();
  final EventRepository   _eventRepo     = EventRepository();

  /// GET /bookmarks/events
  /// Returns list of bookmarked event IDs, then fetches full EventModel for each.
  Future<List<EventModel>> getBookmarkedEvents() async {
    final response = await _apiService.getResponse('/bookmarks/events');

    if (kDebugMode) {
      debugPrint('=== GET BOOKMARKS ===');
      debugPrint('  top-level keys: ${response.keys.toList()}');
      final data = response['data'];
      if (data is Map) {
        debugPrint('  data keys     : ${(data as Map).keys.toList()}');
        debugPrint('  events        : ${data['events']}');
      }
    }

    final data      = response['data'] as Map<String, dynamic>?;
    final rawIds    = data?['events'] as List<dynamic>? ?? [];
    final eventIds  = rawIds.map((e) => e.toString()).toList();

    if (eventIds.isEmpty) return [];

    // Fetch full event details in parallel
    final results = await Future.wait(
      eventIds.map((id) async {
        try {
          final res = await _eventRepo.getEventById(id);
          return res.event;
        } catch (_) {
          return null;
        }
      }),
    );

    return results.whereType<EventModel>().toList();
  }
}