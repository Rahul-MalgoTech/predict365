// lib/ViewModel/CategoryViewModel.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/CategoryModel.dart';
import 'package:predict365/Repository/CategoryRepository.dart';

enum CategoryStatus { idle, loading, success, error }

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();

  CategoryStatus        _status     = CategoryStatus.idle;
  String                _error      = '';
  List<CategoryModel>   _categories = [];

  CategoryStatus      get status     => _status;
  String              get error      => _error;
  List<CategoryModel> get categories => _categories;
  bool                get isLoading  => _status == CategoryStatus.loading;

  // "Trending" + "All" are local tabs prepended before API categories
  // Both show all events (no filter), API categories filter by id
  List<String> get categoryNames =>
      ['Trending', 'All', ..._categories.map((c) => c.name)];

  Future<void> fetchCategories() async {
    _status = CategoryStatus.loading;
    _error  = '';
    notifyListeners();

    try {
      final response = await _repository.getCategories();
      if (response.success) {
        _categories = response.categories;
        _status     = CategoryStatus.success;
      } else {
        _status = CategoryStatus.error;
        _error  = response.message.isNotEmpty
            ? response.message
            : 'Failed to load categories.';
      }
    } catch (e) {
      _status = CategoryStatus.error;
      _error  = _parseError(e.toString());
    }
    notifyListeners();
  }

  String _parseError(String e) {
    if (e.contains('No Internet')) return 'No internet connection.';
    if (e.contains('500'))         return 'Server error. Try again later.';
    return 'Something went wrong.';
  }
}