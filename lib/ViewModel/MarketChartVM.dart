// lib/ViewModel/MarketDataVM.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/MarketChartModel.dart';
import 'package:predict365/Repository/MarketChartRepository.dart';


enum MarketDataStatus { idle, loading, success, error }

class MarketDataViewModel extends ChangeNotifier {
  final MarketDataRepository _repo = MarketDataRepository();

  MarketDataStatus      _status   = MarketDataStatus.idle;
  MarketDataResponse?   _data;
  String                _error    = '';
  String                _interval = '5-min';

  MarketDataStatus    get status   => _status;
  MarketDataResponse? get data     => _data;
  String              get error    => _error;
  String              get interval => _interval;
  bool                get isLoading => _status == MarketDataStatus.loading;

  // Interval → API param mapping
  static const Map<String, String> _intervalMap = {
    '1H':  '1-hour',
    '6H':  '6-hour',
    '1D':  '1-day',
    '1W':  '1-week',
    '1M':  '1-month',
    'ALL': '5-min',   // fallback for ALL
  };

  Future<void> fetchData(String eventId, {String timeRange = 'ALL'}) async {
    _status   = MarketDataStatus.loading;
    _interval = _intervalMap[timeRange] ?? '5-min';
    notifyListeners();

    try {
      _data   = await _repo.getMarketData(eventId, _interval);
      _status = MarketDataStatus.success;
    } catch (e) {
      _error  = 'Failed to load chart data.';
      _status = MarketDataStatus.error;
    }
    notifyListeners();
  }
}