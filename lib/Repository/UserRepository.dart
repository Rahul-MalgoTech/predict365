// lib/Repository/UserRepository.dart

import 'package:predict365/APIService/Remote/network/NetworkApiService.dart';
import 'package:predict365/Models/UserModel.dart';

class UserRepository {
  final NetworkApiService _apiService = NetworkApiService();

  Future<UserResponseModel> getMe() async {
    final response = await _apiService.getResponse('users/me');
    return UserResponseModel.fromJson(response);
  }
}