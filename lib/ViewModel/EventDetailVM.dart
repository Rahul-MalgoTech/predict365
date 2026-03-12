// lib/ViewModel/EventDetailVM.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/EventModel.dart';
import 'package:predict365/Repository/EventRespository.dart';

enum EventDetailStatus { idle, loading, success, error }

class EventDetailViewModel extends ChangeNotifier {
  final EventRepository _repository = EventRepository();

  EventDetailStatus _status = EventDetailStatus.idle;
  String            _error  = '';
  EventModel?       _event;

  EventDetailStatus get status    => _status;
  String            get error     => _error;
  EventModel?       get event     => _event;
  bool              get isLoading => _status == EventDetailStatus.loading;

  Future<void> fetchEvent(String eventId) async {
    _status = EventDetailStatus.loading;
    _error  = '';
    notifyListeners();

    try {
      final response = await _repository.getEventById(eventId);
      if (response.success && response.event != null) {
        _event  = response.event;
        _status = EventDetailStatus.success;
      } else {
        _status = EventDetailStatus.error;
        _error  = 'Event not found.';
      }
    } catch (e) {
      _status = EventDetailStatus.error;
      _error  = 'Failed to load event.';
    }
    notifyListeners();
  }

  void clear() {
    _event  = null;
    _status = EventDetailStatus.idle;
    notifyListeners();
  }
}