// lib/Repository/BookmarkRepository.dart

import 'package:flutter/foundation.dart';
import 'package:predict365/APIService/Remote/network/NetworkApiService.dart';

class BookmarkRepository {
  final NetworkApiService _apiService = NetworkApiService();

  /// GET /bookmarks/events — returns just the IDs (fast, no full event fetch)
  Future<List<String>> fetchBookmarkIds() async {
    final response = await _apiService.getResponse('/bookmarks/events');
    final data   = response['data'] as Map<String, dynamic>?;
    final rawIds = data?['events'] as List<dynamic>? ?? [];
    return rawIds.map((e) => e.toString()).toList();
  }

  /// POST /bookmarks
  /// Body: { "type": "event", "content_id": "<eventId>" }
  /// Response: { "success": true, "data": { "bookmarked": true|false } }
  Future<bool> toggleBookmark(String eventId) async {
    final response = await _apiService.postResponse(
      '/bookmarks',
      body: {
        'type':       'event',
        'content_id': eventId,
      },
    );

    if (kDebugMode) {
      debugPrint('=== BOOKMARK TOGGLE (event: $eventId) ===');
      debugPrint('  success    : ${response['success']}');
      debugPrint('  message    : ${response['message']}');
      debugPrint('  bookmarked : ${response['data']?['bookmarked']}');
    }

    final data = response['data'] as Map<String, dynamic>?;
    return data?['bookmarked'] as bool? ?? false;
  }
}