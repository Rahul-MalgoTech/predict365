// lib/ViewModel/ThoughtVM.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/ThoughtsModel.dart';
import 'package:predict365/Repository/ThoughtsRepository.dart';


enum ThoughtStatus { idle, loading, loadingMore, success, error }

class ThoughtViewModel extends ChangeNotifier {
  final ThoughtRepository _repo = ThoughtRepository();

  ThoughtStatus         _status    = ThoughtStatus.idle;
  String                _error     = '';
  List<ThoughtModel>    _thoughts  = [];
  int                   _page      = 1;
  bool                  _hasMore   = true;
  bool                  _posting   = false;
  String                _postError = '';
  String                _eventId   = '';

  ThoughtStatus      get status    => _status;
  String             get error     => _error;
  List<ThoughtModel> get thoughts  => List.unmodifiable(_thoughts);
  bool get isLoading     => _status == ThoughtStatus.loading;
  bool get isLoadingMore => _status == ThoughtStatus.loadingMore;
  bool get hasMore       => _hasMore;
  bool get isPosting     => _posting;
  String get postError   => _postError;
  bool get isEmpty       => _thoughts.isEmpty && _status == ThoughtStatus.success;

  // ── Initial fetch ─────────────────────────────────────────────
  Future<void> fetchThoughts(String eventId) async {
    if (_eventId == eventId && _status == ThoughtStatus.success) return;

    _eventId  = eventId;
    _page     = 1;
    _thoughts = [];
    _hasMore  = true;
    _status   = ThoughtStatus.loading;
    _error    = '';
    _postError = '';
    notifyListeners();

    try {
      final res = await _repo.getThoughts(eventId: eventId, page: 1);
      _thoughts = res.thoughts;
      _hasMore  = res.thoughts.length >= res.limit;
      _status   = ThoughtStatus.success;
    } catch (e) {
      _status = ThoughtStatus.error;
      _error  = _parseError(e.toString());
    }
    notifyListeners();
  }

  // ── Load more pages ───────────────────────────────────────────
  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore || isLoading) return;
    _status = ThoughtStatus.loadingMore;
    notifyListeners();

    try {
      final res = await _repo.getThoughts(eventId: _eventId, page: _page + 1);
      _thoughts.addAll(res.thoughts);
      _page++;
      _hasMore = res.thoughts.length >= res.limit;
    } catch (_) {
      // silently keep existing data
    }
    _status = ThoughtStatus.success;
    notifyListeners();
  }

  // ── Post a new thought ────────────────────────────────────────
  Future<bool> postThought(String content) async {
    if (content.trim().isEmpty) return false;
    if (_eventId.isEmpty) return false;

    _posting   = true;
    _postError = '';
    notifyListeners();

    try {
      final res = await _repo.postThought(
        eventId: _eventId,
        content: content.trim(),
      );

      if (res.success && res.thought != null) {
        // Prepend optimistically — newest first
        _thoughts = [res.thought!, ..._thoughts];
        _posting  = false;
        notifyListeners();
        return true;
      } else {
        _postError = res.message.isNotEmpty
            ? res.message
            : 'Failed to post. Please try again.';
        _posting   = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _postError = _parseError(e.toString());
      _posting   = false;
      notifyListeners();
      return false;
    }
  }

  // ── Optimistic like toggle (UI only — wire like API separately) ─
  void toggleLike(String thoughtId, String currentUserId) {
    final idx = _thoughts.indexWhere((t) => t.id == thoughtId);
    if (idx == -1) return;
    _thoughts[idx] = _thoughts[idx].withLikeToggled(currentUserId);
    notifyListeners();
  }

  void clearPostError() {
    _postError = '';
    notifyListeners();
  }

  Future<void> refresh() async {
    _eventId = '';
    await fetchThoughts(_eventId);
  }

  String _parseError(String e) {
    if (e.contains('No Internet') || e.contains('SocketException'))
      return 'No internet connection.';
    if (e.contains('401')) return 'Please login to comment.';
    if (e.contains('404')) return 'No comments found.';
    if (e.contains('500')) return 'Server error. Try again later.';
    return 'Something went wrong. Please try again.';
  }
}