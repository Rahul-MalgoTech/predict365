// lib/ViewModel/WatchlistVM.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/BookmarkmodelSeeder.dart';
import 'package:predict365/Models/EventModel.dart';
import 'package:predict365/Repository/BookmarkRepository.dart';
import 'package:predict365/Repository/WatchlistRepository.dart';

enum WatchlistStatus { idle, loading, success, error }

class WatchlistViewModel extends ChangeNotifier {
  final WatchlistRepository _repo    = WatchlistRepository();
  final BookmarkRepository  _bmRepo  = BookmarkRepository();

  WatchlistStatus     _status = WatchlistStatus.idle;
  String              _error  = '';
  List<EventModel>    _events = [];

  WatchlistStatus  get status   => _status;
  String           get error    => _error;
  List<EventModel> get events   => List.unmodifiable(_events);
  bool get isLoading => _status == WatchlistStatus.loading;
  bool get isEmpty   => _events.isEmpty && _status == WatchlistStatus.success;

  Future<void> fetchBookmarks({BookmarkViewModelSeeder? seeder}) async {
    _status = WatchlistStatus.loading;
    _error  = '';
    notifyListeners();

    try {
      _events = await _repo.getBookmarkedEvents();
      _status = WatchlistStatus.success;

      // Seed BookmarkViewModel so stars on HomeScreen reflect current state
      seeder?.setBookmarks(_events.map((e) => e.id).toList());
    } catch (e) {
      _status = WatchlistStatus.error;
      _error  = _parseError(e.toString());
    }
    notifyListeners();
  }

  /// Remove an event locally after unbookmarking (optimistic)
  void removeEvent(String eventId) {
    _events = _events.where((e) => e.id != eventId).toList();
    notifyListeners();
  }

  Future<void> refresh({BookmarkViewModelSeeder? seeder}) =>
      fetchBookmarks(seeder: seeder);

  String _parseError(String e) {
    if (e.contains('SocketException') || e.contains('No Internet'))
      return 'No internet connection.';
    if (e.contains('401')) return 'Session expired. Please login again.';
    if (e.contains('404')) return 'No bookmarks found.';
    if (e.contains('500')) return 'Server error. Try again later.';
    return 'Something went wrong.';
  }
}