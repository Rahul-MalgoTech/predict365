// lib/ViewModel/EventVM.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/EventModel.dart';
import 'package:predict365/Repository/EventRespository.dart';

enum EventStatus { idle, loading, success, error }

class EventViewModel extends ChangeNotifier {
  final EventRepository _repository = EventRepository();

  EventStatus      _status          = EventStatus.idle;
  String           _errorMessage    = '';
  List<EventModel> _allEvents       = []; // full unfiltered list from API
  String?          _activeCategoryId;     // null = Trending = show all

  EventStatus      get status           => _status;
  String           get errorMessage     => _errorMessage;
  String?          get activeCategoryId => _activeCategoryId;
  bool             get isLoading        => _status == EventStatus.loading;

  // Full unfiltered list — used by search screen
  List<EventModel> get allEvents => List.unmodifiable(_allEvents);

  // Filtered list — what the UI actually reads
  List<EventModel> get events {
    if (_activeCategoryId == null || _activeCategoryId!.isEmpty) {
      return _allEvents;
    }
    return _allEvents
        .where((e) => e.category == _activeCategoryId)
        .toList();
  }

  // ── Fetch all events from API (called once on init) ───────────
  Future<void> fetchEvents() async {
    _status       = EventStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _repository.getEvents();
      if (response.success) {
        _allEvents = response.events;
        _status    = EventStatus.success;
      } else {
        _status       = EventStatus.error;
        _errorMessage = 'Failed to load events.';
      }
    } catch (e) {
      _status       = EventStatus.error;
      _errorMessage = _parseError(e.toString());
    }
    notifyListeners();
  }

  // ── Called when user taps a category tab ─────────────────────
  // null = Trending (show all), otherwise filter by category _id
  void filterByCategory(String? categoryId) {
    _activeCategoryId = categoryId;
    notifyListeners(); // no API call — just re-filters the cached list
  }

  // ── Refresh ───────────────────────────────────────────────────
  Future<void> refresh() => fetchEvents();

  void clearError() {
    _errorMessage = '';
    _status       = EventStatus.idle;
    notifyListeners();
  }

  String _parseError(String e) {
    if (e.contains('No Internet')) return 'No internet connection.';
    if (e.contains('401'))         return 'Session expired. Please login again.';
    if (e.contains('403'))         return 'Access denied.';
    if (e.contains('404'))         return 'Events not found.';
    if (e.contains('500'))         return 'Server error. Try again later.';
    return 'Something went wrong. Please try again.';
  }
}