// lib/Repository/CategoryRepository.dart

import 'package:predict365/APIService/Remote/network/NetworkApiService.dart';
import 'package:predict365/Models/CategoryModel.dart';

class CategoryRepository {
  final NetworkApiService _apiService = NetworkApiService();

  Future<CategoryListResponseModel> getCategories() async {
    final response = await _apiService.getResponse('/categories');
    return CategoryListResponseModel.fromJson(response);
  }
}