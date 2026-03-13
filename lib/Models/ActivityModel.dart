// lib/Models/ActivityModel.dart

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

class ActivityModel {
  final String    id;
  final String    username;
  final String?   profileImage;
  final int       shares;
  final String    side;       // "YES" | "NO"
  final String    action;     // "BUY" | "SELL"
  final DateTime? updatedAt;
  final double    price;
  final String    marketName;

  ActivityModel({
    required this.id,
    required this.username,
    this.profileImage,
    required this.shares,
    required this.side,
    required this.action,
    this.updatedAt,
    required this.price,
    required this.marketName,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id:           json['id']            ?? '',
      username:     json['username']      ?? 'User',
      profileImage: json['profile_image'],
      shares:       (json['shares'] as num?)?.toInt() ?? 0,
      side:         json['side']          ?? 'YES',
      action:       json['action']        ?? 'BUY',
      updatedAt:    _parseDate(json['updated_at']),
      price:        (json['price'] as num?)?.toDouble() ?? 0.0,
      marketName:   json['marketName']    ?? '',
    );
  }

  bool get isBuy  => action.toUpperCase() == 'BUY';
  bool get isYes  => side.toUpperCase()   == 'YES';

  /// Total cost = shares × price  →  "$2.55"
  String get totalLabel {
    final total = shares * price;
    return '\$${total.toStringAsFixed(2)}';
  }

  /// e.g. "2h ago", "3d ago"
  String get timeAgo {
    if (updatedAt == null) return '';
    final diff = DateTime.now().difference(updatedAt!);
    if (diff.inSeconds < 60)  return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24)  return '${diff.inHours}h ago';
    if (diff.inDays    < 30)  return '${diff.inDays}d ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}

// ── API Response ──────────────────────────────────────────────────
class ActivitiesResponseModel {
  final bool                success;
  final List<ActivityModel> activities;
  final int                 currentPage;
  final int                 limit;

  ActivitiesResponseModel({
    required this.success,
    required this.activities,
    required this.currentPage,
    required this.limit,
  });

  factory ActivitiesResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['activities'];
    final List<ActivityModel> parsed = [];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          parsed.add(ActivityModel.fromJson(item));
        }
      }
    }

    final pagination = json['pagination'] as Map<String, dynamic>?;
    return ActivitiesResponseModel(
      success:     json['success'] ?? true,
      activities:  parsed,
      currentPage: (pagination?['currentPage'] as num?)?.toInt() ?? 1,
      limit:       (pagination?['limit']       as num?)?.toInt() ?? 50,
    );
  }
}