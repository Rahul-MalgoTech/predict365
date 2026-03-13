// lib/ViewModel/ActivityVM.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/ActivityModel.dart';
import 'package:predict365/Repository/ActivityRepository.dart';

enum ActivityStatus { idle, loading, loadingMore, success, error }

class ActivityViewModel extends ChangeNotifier {
  final ActivityRepository _repository = ActivityRepository();

  ActivityStatus         _status      = ActivityStatus.idle;
  String                 _error       = '';
  List<ActivityModel>    _activities  = [];
  int                    _currentPage = 1;
  bool                   _hasMore     = true;
  String                 _eventId     = '';

  ActivityStatus      get status      => _status;
  String              get error       => _error;
  List<ActivityModel> get activities  => List.unmodifiable(_activities);
  bool get isLoading     => _status == ActivityStatus.loading;
  bool get isLoadingMore => _status == ActivityStatus.loadingMore;
  bool get hasMore       => _hasMore;
  bool get isEmpty       => _activities.isEmpty && _status == ActivityStatus.success;

  // ── Initial fetch ─────────────────────────────────────────────
  Future<void> fetchActivities(String eventId) async {
    if (_eventId == eventId && _status == ActivityStatus.success) return; // already loaded

    _eventId     = eventId;
    _currentPage = 1;
    _activities  = [];
    _hasMore     = true;
    _status      = ActivityStatus.loading;
    _error       = '';
    notifyListeners();

    try {
      final res = await _repository.getEventActivities(
        eventId: eventId,
        page:    1,
      );
      _activities  = res.activities;
      // API doesn't return totalPages — treat as no more if fewer than limit returned
      _hasMore     = res.activities.length >= res.limit;
      _currentPage = 1;
      _status      = ActivityStatus.success;
    } catch (e) {
      _status = ActivityStatus.error;
      _error  = _parseError(e.toString());
    }
    notifyListeners();
  }

  // ── Load next page ────────────────────────────────────────────
  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore || isLoading) return;

    _status = ActivityStatus.loadingMore;
    notifyListeners();

    try {
      final res = await _repository.getEventActivities(
        eventId: _eventId,
        page:    _currentPage + 1,
      );
      _activities.addAll(res.activities);
      _currentPage++;
      _hasMore = res.activities.length >= res.limit;
      _status  = ActivityStatus.success;
    } catch (_) {
      _status = ActivityStatus.success; // keep existing data visible
    }
    notifyListeners();
  }

  Future<void> refresh() {
    _eventId = ''; // force re-fetch
    return fetchActivities(_eventId);
  }

  String _parseError(String e) {
    if (e.contains('No Internet')) return 'No internet connection.';
    if (e.contains('401'))         return 'Session expired.';
    if (e.contains('404'))         return 'No activity found.';
    if (e.contains('500'))         return 'Server error. Try again later.';
    return 'Something went wrong.';
  }
}