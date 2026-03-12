// lib/PredictScreens/AuthScreens/Model/auth_model.dart

// ── Register ──────────────────────────────────────────────────────
class RegisterRequestModel {
  final String email;
  final String username;
  final String password;

  RegisterRequestModel({
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'username': username,
    'password': password,
  };
}

class RegisterResponseModel {
  final bool success;
  final String message;

  RegisterResponseModel({required this.success, required this.message});

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      RegisterResponseModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
      );
}

// ── Verify Account ────────────────────────────────────────────────
class VerifyAccountRequestModel {
  final String email;
  final String otp;

  VerifyAccountRequestModel({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}

class VerifyAccountResponseModel {
  final bool success;
  final String message;

  VerifyAccountResponseModel({required this.success, required this.message});

  factory VerifyAccountResponseModel.fromJson(Map<String, dynamic> json) =>
      VerifyAccountResponseModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
      );
}

// ── Login ─────────────────────────────────────────────────────────
class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class LoginUserModel {
  final String id;
  final String email;
  final String username;
  final String name;
  final String? bio;
  final String? profileImage;
  final double wallet;
  final bool emailVerified;
  final bool isActive;
  final bool isBlocked;

  LoginUserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    this.bio,
    this.profileImage,
    required this.wallet,
    required this.emailVerified,
    required this.isActive,
    required this.isBlocked,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) => LoginUserModel(
    id:           json['id'] ?? '',
    email:        json['email'] ?? '',
    username:     json['username'] ?? '',
    name:         json['name'] ?? '',
    bio:          json['bio'],
    profileImage: json['profile_image'],
    wallet:       (json['wallet'] ?? 0).toDouble(),
    emailVerified: json['email_verified'] ?? false,
    isActive:     json['is_active'] ?? false,
    isBlocked:    json['is_blocked'] ?? false,
  );
}

class LoginResponseModel {
  final bool success;
  final String message;
  final String? token;
  final LoginUserModel? user;

  LoginResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token:   data?['token'],
      user: data?['user'] != null
          ? LoginUserModel.fromJson(data!['user'] as Map<String, dynamic>)
          : null,
    );
  }
}