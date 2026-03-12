// lib/PredictScreens/AuthScreens/Service/auth_storage.dart
//
// Saves / reads / clears the JWT token from shared_preferences.
// Add to pubspec.yaml:  shared_preferences: ^2.2.3

import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  AuthStorage._();
  static final AuthStorage instance = AuthStorage._();

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _usernameKey = 'username';
  static const _emailKey = 'user_email';

  // ── Save after login ──────────────────────────────────────────
  Future<void> saveSession({
    required String token,
    required String userId,
    required String username,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey,    token);
    await prefs.setString(_userIdKey,   userId);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_emailKey,    email);
  }

  // ── Getters ───────────────────────────────────────────────────
  Future<String?> getToken()    async => (await SharedPreferences.getInstance()).getString(_tokenKey);
  Future<String?> getUserId()   async => (await SharedPreferences.getInstance()).getString(_userIdKey);
  Future<String?> getUsername() async => (await SharedPreferences.getInstance()).getString(_usernameKey);
  Future<String?> getEmail()    async => (await SharedPreferences.getInstance()).getString(_emailKey);

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    print("token : $token");
    return token != null && token.isNotEmpty;
  }

  // ── Clear on logout ───────────────────────────────────────────
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
  }
}