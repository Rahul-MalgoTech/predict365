// lib/PredictScreens/AuthScreens/ViewModel/auth_view_model.dart

import 'package:flutter/material.dart';
import 'package:predict365/AuthStorage/authStorage.dart';
import 'package:predict365/AuthStorage/magicAuthService.dart';
import 'package:predict365/Models/AuthModel.dart';
import 'package:predict365/Repository/authRepository.dart';


enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  AuthStatus      _status         = AuthStatus.idle;
  String          _errorMessage   = '';
  String          _successMessage = '';
  LoginUserModel? _currentUser;
  bool            _passwordVisible        = false;
  bool            _confirmPasswordVisible = false;

  AuthStatus      get status            => _status;
  String          get errorMessage      => _errorMessage;
  String          get successMessage    => _successMessage;
  bool            get isLoading         => _status == AuthStatus.loading;
  LoginUserModel? get currentUser       => _currentUser;
  bool            get passwordVisible        => _passwordVisible;
  bool            get confirmPasswordVisible => _confirmPasswordVisible;

  void togglePasswordVisibility() { _passwordVisible = !_passwordVisible; notifyListeners(); }
  void toggleConfirmPasswordVisibility() { _confirmPasswordVisible = !_confirmPasswordVisible; notifyListeners(); }
  void clearStatus() { _status = AuthStatus.idle; _errorMessage = ''; _successMessage = ''; notifyListeners(); }

  // ── Register ──────────────────────────────────────────────────
  Future<bool> register({ required String email, required String username, required String password }) async {
    _setLoading();
    try {
      final response = await _repository.register(RegisterRequestModel(
          email: email.trim(), username: username.trim(), password: password));
      if (response.success) { _setSuccess(response.message); return true; }
      _setError(response.message.isNotEmpty ? response.message : 'Registration failed.');
      return false;
    } catch (e) { _setError(_parseError(e.toString())); return false; }
  }

  // ── Verify Account ────────────────────────────────────────────
  Future<bool> verifyAccount({ required String email, required String otp }) async {
    _setLoading();
    try {
      final response = await _repository.verifyAccount(
          VerifyAccountRequestModel(email: email.trim(), otp: otp.trim()));
      if (response.success) { _setSuccess(response.message); return true; }
      _setError(response.message.isNotEmpty ? response.message : 'Verification failed.');
      return false;
    } catch (e) { _setError(_parseError(e.toString())); return false; }
  }

  // ── Email + Password Login ────────────────────────────────────
  Future<bool> login({ required String email, required String password }) async {
    _setLoading();
    try {
      final response = await _repository.login(
          LoginRequestModel(email: email.trim(), password: password));
      if (response.success && response.token != null) {
        await _saveSession(response); return true;
      }
      _setError(response.message.isNotEmpty ? response.message : 'Login failed.');
      return false;
    } catch (e) { _setError(_parseError(e.toString())); return false; }
  }

  // ── Google Login ──────────────────────────────────────────────
  // Future<bool> loginWithGoogle() async {
  //   _setLoading();
  //   try {
  //     // Step 1: Get Google ID token
  //     final idToken = await GoogleAuthService.instance.signIn();
  //
  //     if (idToken == null || idToken.isEmpty) {
  //       _setError('Google sign-in was cancelled.');
  //       return false;
  //     }
  //
  //     print("✅ Got idToken, sending to backend...");
  //     print("🔵 Token (first 40 chars): ${idToken.substring(0, 40)}...");
  //
  //     // Step 2: Send to backend POST /auth/google-login { "didToken": idToken }
  //     final response = await _repository.googleLogin(idToken);
  //
  //     print("🔵 Backend response: success=${response.success}, message=${response.message}");
  //
  //     if (response.success && response.token != null) {
  //       await _saveSession(response);
  //       return true;
  //     }
  //
  //     _setError(response.message.isNotEmpty ? response.message : 'Google login failed.');
  //     return false;
  //   } catch (e) {
  //     print("🔴 loginWithGoogle error: $e");
  //     _setError(_parseError(e.toString()));
  //     return false;
  //   }
  // }

  // ── Logout ────────────────────────────────────────────────────
  Future<void> logout() async {
    await AuthStorage.instance.clearSession();
    // await GoogleAuthService.instance.signOut();
    _currentUser = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  Future<void> _saveSession(LoginResponseModel response) async {
    await AuthStorage.instance.saveSession(
      token:    response.token!,
      userId:   response.user?.id ?? '',
      username: response.user?.username ?? '',
      email:    response.user?.email ?? '',
    );
    _currentUser = response.user;
    _setSuccess(response.message);
  }

  // ── Validation ────────────────────────────────────────────────
  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }
  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password is too short';
    return null;
  }
  String? validateRegisterPassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'At least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Must contain uppercase letter';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Must contain a number';
    if (!v.contains(RegExp(r'[!@#\$&*~._]'))) return 'Must contain special character';
    return null;
  }
  String? validateUsername(String? v) {
    if (v == null || v.trim().isEmpty) return 'Username is required';
    if (v.trim().length < 3) return 'At least 3 characters';
    if (v.trim().length > 20) return 'Max 20 characters';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) return 'Letters, numbers, underscores only';
    return null;
  }
  String? validateConfirmPassword(String? v, String password) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != password) return 'Passwords do not match';
    return null;
  }

  void _setLoading() { _status = AuthStatus.loading; _errorMessage = ''; _successMessage = ''; notifyListeners(); }
  void _setSuccess(String m) { _status = AuthStatus.success; _successMessage = m; notifyListeners(); }
  void _setError(String m) { _status = AuthStatus.error; _errorMessage = m; notifyListeners(); }

  String _parseError(String e) {
    if (e.contains('No Internet')) return 'No internet connection.';
    if (e.contains('400')) return 'Invalid request. Please try again.';
    if (e.contains('401')) return 'Incorrect email or password.';
    if (e.contains('403')) return 'Account not verified. Check your email.';
    if (e.contains('404')) return 'Account not found. Please register.';
    if (e.contains('409')) return 'Email or username already exists.';
    if (e.contains('500')) return 'Server error. Try again later.';
    if (e.contains('cancelled')) return 'Sign-in was cancelled.';
    if (e.contains('idToken is null')) return 'Google setup incomplete. Missing SHA-1 fingerprint.';
    return 'Something went wrong. Please try again.';
  }
}