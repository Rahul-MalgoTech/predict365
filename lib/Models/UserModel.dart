// lib/Models/UserModel.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final bool emailVerified;
  final String username;
  final String? bio;
  final String? profileImage;
  final String? theme;
  final String? language;
  final String? regionId;
  final bool emailReportOptIn;
  final bool twoFaEnabled;
  final double available;
  final double held;
  final double wallet;
  final double holdWallet;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.emailVerified,
    required this.username,
    this.bio,
    this.profileImage,
    this.theme,
    this.language,
    this.regionId,
    required this.emailReportOptIn,
    required this.twoFaEnabled,
    required this.available,
    required this.held,
    required this.wallet,
    required this.holdWallet,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:               json['_id']               as String? ?? '',
      name:             json['name']              as String? ?? '',
      email:            json['email']             as String? ?? '',
      emailVerified:    json['email_verified']    as bool?   ?? false,
      username:         json['username']          as String? ?? '',
      bio:              json['bio']               as String?,
      profileImage:     json['profile_image']     as String?,
      theme:            json['theme']             as String?,
      language:         json['language']          as String?,
      regionId:         json['regionId']          as String?,
      emailReportOptIn: json['email_report_opt_in'] as bool? ?? true,
      twoFaEnabled:     json['twoFA_enabled']     as bool?   ?? false,
      available:        (json['available'] as num? ?? 0).toDouble(),
      held:             (json['held']      as num? ?? 0).toDouble(),
      wallet:           (json['wallet']    as num? ?? 0).toDouble(),
      holdWallet:       (json['hold_wallet'] as num? ?? 0).toDouble(),
    );
  }

  /// Display name — prefer username, fallback to email prefix
  String get displayName =>
      username.isNotEmpty ? username : email.split('@').first;

  /// Total balance shown in top bar
  double get totalBalance => wallet;

  /// Formatted balance string
  String get balanceFormatted => '\$${totalBalance.toStringAsFixed(2)}';
}

class UserResponseModel {
  final bool    success;
  final String  message;
  final UserModel? user;

  UserResponseModel({
    required this.success,
    required this.message,
    this.user,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      user: json['data'] != null
          ? UserModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}