// lib/Repository/EventRespository.dart

import 'package:predict365/APIService/Remote/network/NetworkApiService.dart';
import 'package:predict365/Models/EventModel.dart';

class EventRepository {
  final NetworkApiService _apiService = NetworkApiService();

  Future<EventsResponseModel> getEvents() async {
    final response = await _apiService.getResponse('/event/events');
    return EventsResponseModel.fromJson(response);
  }

  Future<EventSingleResponseModel> getEventById(String eventId) async {
    final response = await _apiService.getResponse('/event/events/$eventId');
    return EventSingleResponseModel.fromJson(response);
  }
}