// lib/ViewModel/UserVM.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/UserModel.dart';
import 'package:predict365/Repository/UserRepository.dart';

enum UserStatus { idle, loading, success, error }

class UserViewModel extends ChangeNotifier {
  final UserRepository _repository = UserRepository();

  UserStatus _status  = UserStatus.idle;
  String     _error   = '';
  UserModel? _user;

  UserStatus get status    => _status;
  String     get error     => _error;
  UserModel? get user      => _user;
  bool       get isLoading => _status == UserStatus.loading;

  Future<void> fetchMe() async {
    _status = UserStatus.loading;
    _error  = '';
    notifyListeners();

    try {
      final response = await _repository.getMe();
      if (response.success && response.user != null) {
        _user   = response.user;
        _status = UserStatus.success;
      } else {
        _status = UserStatus.error;
        _error  = response.message.isNotEmpty
            ? response.message
            : 'Failed to load user.';
      }
    } catch (e) {
      _status = UserStatus.error;
      _error  = _parseError(e.toString());
    }
    notifyListeners();
  }

  void clearUser() {
    _user   = null;
    _status = UserStatus.idle;
    notifyListeners();
  }

  String _parseError(String e) {
    if (e.contains('401')) return 'Session expired. Please login again.';
    if (e.contains('403')) return 'Access denied.';
    if (e.contains('500')) return 'Server error. Try again later.';
    return 'Something went wrong.';
  }
}