// lib/Repository/MarketDataRepository.dart

import 'package:predict365/APIService/Remote/network/NetworkApiService.dart';
import 'package:predict365/Models/MarketChartModel.dart';

class MarketDataRepository {
  final NetworkApiService _apiService = NetworkApiService();

  /// [interval] — '5-min' | '1-hour' | '1-day' etc.
  Future<MarketDataResponse> getMarketData(
      String eventId, String interval) async {
    final response =
    await _apiService.getResponse('/market-data/$eventId/$interval');
    return MarketDataResponse.fromJson(response);
  }
}