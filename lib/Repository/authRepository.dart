// lib/PredictScreens/AuthScreens/Repository/auth_repository.dart

import 'package:predict365/APIService/Remote/network/NetworkApiService.dart';
import 'package:predict365/Models/AuthModel.dart';

class AuthRepository {
  final NetworkApiService _apiService = NetworkApiService();

  // ── Register ──────────────────────────────────────────────────
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    final response = await _apiService.postResponseV2(
      '/auth/register',
      body: request.toJson(),
    );
    return RegisterResponseModel.fromJson(response);
  }

  // ── Verify Account ────────────────────────────────────────────
  Future<VerifyAccountResponseModel> verifyAccount(
      VerifyAccountRequestModel request) async {
    final response = await _apiService.postResponseV2(
      '/auth/verify-account',
      body: request.toJson(),
    );
    return VerifyAccountResponseModel.fromJson(response);
  }

  // ── Email + Password Login ────────────────────────────────────
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await _apiService.postResponseV2(
      '/auth/login',
      body: request.toJson(),
    );
    return LoginResponseModel.fromJson(response);
  }

  // ── Google Login via Magic DID token ──────────────────────────
  Future<LoginResponseModel> googleLogin(String didToken) async {
    final response = await _apiService.postResponseV2(
      '/auth/google-login',
      body: {'didToken': didToken},
    );
    return LoginResponseModel.fromJson(response);
  }
}