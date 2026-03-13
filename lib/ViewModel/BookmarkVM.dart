// lib/ViewModel/BookmarkVM.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/BookmarkmodelSeeder.dart';
import 'package:predict365/Repository/BookmarkRepository.dart';

class BookmarkViewModel extends ChangeNotifier implements BookmarkViewModelSeeder {
  final BookmarkRepository _repo = BookmarkRepository();

  final Set<String> _bookmarked = {};
  final Set<String> _pending    = {};

  BookmarkViewModel() {
    _init();
  }

  /// Called once on creation — silently loads bookmark IDs from API
  Future<void> _init() async {
    try {
      final ids = await _repo.fetchBookmarkIds();
      _bookmarked.addAll(ids);
      notifyListeners();
    } catch (_) {
      // Fail silently — stars just won't be pre-filled if offline
    }
  }

  bool isBookmarked(String eventId) => _bookmarked.contains(eventId);
  bool isPending(String eventId)    => _pending.contains(eventId);

  /// Pre-seed known bookmarks (call from your bookmarks list screen if needed)
  void setBookmarks(List<String> eventIds) {
    _bookmarked
      ..clear()
      ..addAll(eventIds);
    notifyListeners();
  }

  /// Toggle bookmark — optimistic UI, rolls back on error
  Future<void> toggleBookmark(String eventId) async {
    if (_pending.contains(eventId)) return; // already in flight

    final wasBookmarked = _bookmarked.contains(eventId);

    // Optimistic update
    _pending.add(eventId);
    if (wasBookmarked) {
      _bookmarked.remove(eventId);
    } else {
      _bookmarked.add(eventId);
    }
    notifyListeners();

    try {
      final nowBookmarked = await _repo.toggleBookmark(eventId);
      // Sync with server response
      if (nowBookmarked) {
        _bookmarked.add(eventId);
      } else {
        _bookmarked.remove(eventId);
      }
    } catch (_) {
      // Roll back on error
      if (wasBookmarked) {
        _bookmarked.add(eventId);
      } else {
        _bookmarked.remove(eventId);
      }
    }

    _pending.remove(eventId);
    notifyListeners();
  }
}