// lib/Repository/ThoughtRepository.dart

import 'package:flutter/foundation.dart';
import 'package:predict365/APIService/Remote/network/NetworkApiService.dart';
import 'package:predict365/Models/ThoughtsModel.dart';

class ThoughtRepository {
  final NetworkApiService _apiService = NetworkApiService();

  // ── GET /events/:eventId/thoughts?page=1&limit=25 ─────────────
  Future<ThoughtsResponseModel> getThoughts({
    required String eventId,
    int page  = 1,
    int limit = 25,
  }) async {
    final response = await _apiService.getResponse(
      '/events/$eventId/thoughts?page=$page&limit=$limit',
    );

    if (kDebugMode) {
      final data = response['data'];
      debugPrint('=== GET THOUGHTS (event: $eventId, page: $page) ===');
      debugPrint('  top-level keys: ${response.keys.toList()}');
      if (data is Map) {
        debugPrint('  data keys     : ${(data as Map).keys.toList()}');
        final t = data['thoughts'];
        debugPrint('  thoughts count: ${t is List ? t.length : 'n/a'}');
      }
    }

    return ThoughtsResponseModel.fromJson(response);
  }

  // ── POST /thoughts ─────────────────────────────────────────────
  // Body: { "eventId": "...", "content": "..." }
  // Response: { "success": true, "message": "Thought created", "data": { "thought": {...} } }
  Future<PostThoughtResponseModel> postThought({
    required String eventId,
    required String content,
  }) async {
    final response = await _apiService.postResponse(
      '/thoughts',
      body: {
        'eventId': eventId,
        'content': content,
      },
    );

    if (kDebugMode) {
      debugPrint('=== POST THOUGHT ===');
      debugPrint('  success : ${response['success']}');
      debugPrint('  message : ${response['message']}');
    }

    return PostThoughtResponseModel.fromJson(response);
  }
}