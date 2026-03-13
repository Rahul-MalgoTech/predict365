// lib/Repository/ActivityRepository.dart

import 'package:flutter/foundation.dart';
import 'package:predict365/APIService/Remote/network/NetworkApiService.dart';
import 'package:predict365/Models/ActivityModel.dart';

class ActivityRepository {
  final NetworkApiService _apiService = NetworkApiService();

  /// GET /events/:eventId/transactions?page=1&limit=50
  Future<ActivitiesResponseModel> getEventActivities({
    required String eventId,
    int page  = 1,
    int limit = 50,
  }) async {
    final response = await _apiService.getResponse(
      '/events/$eventId/transactions?page=$page&limit=$limit',
    );

    if (kDebugMode) {
      debugPrint('=== GET ACTIVITIES (event: $eventId, page: $page) ===');
      debugPrint('  keys      : ${response.keys.toList()}');
      final raw = response['activities'];
      debugPrint('  activities: ${raw?.runtimeType}, count: ${raw is List ? raw.length : 'n/a'}');
    }

    return ActivitiesResponseModel.fromJson(response);
  }
}