// lib/Models/ThoughtModel.dart

DateTime? _parseThoughtDate(dynamic v) {
  if (v == null) return null;
  if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
  return null;
}

class ThoughtUser {
  final String  id;
  final String  name;
  final String  username;
  final String? profileImage;

  ThoughtUser({required this.id, required this.name, required this.username, this.profileImage});

  factory ThoughtUser.fromJson(Map<String, dynamic> j) => ThoughtUser(
    id:           j['_id'] ?? j['id'] ?? '',
    name:         j['name']     ?? '',
    username:     j['username'] ?? '',
    profileImage: j['profile_image'],
  );

  String get displayName => name.trim().isNotEmpty ? name.trim() : username.trim();
  String get initial => displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
}

class ThoughtModel {
  final String             id;
  final ThoughtUser        user;
  final String             eventId;
  final String             content;
  final String?            parent;
  final int                likes;
  final int                replyCount;
  final List<String>       likedBy;
  final bool               isMarketIdea;
  final DateTime?          createdAt;
  final DateTime?          updatedAt;
  final List<ThoughtModel> replies;

  ThoughtModel({
    required this.id, required this.user, required this.eventId,
    required this.content, this.parent, required this.likes,
    required this.replyCount, required this.likedBy,
    required this.isMarketIdea, this.createdAt, this.updatedAt,
    this.replies = const [],
  });

  factory ThoughtModel.fromJson(Map<String, dynamic> j) {
    final rawUser = j['user'];
    final user = rawUser is Map<String, dynamic>
        ? ThoughtUser.fromJson(rawUser)
        : ThoughtUser(id: '', name: '', username: 'User');

    return ThoughtModel(
      id:           j['_id']            ?? j['id'] ?? '',
      user:         user,
      eventId:      j['event']?.toString() ?? '',
      content:      j['content']           ?? '',
      parent:       j['parent']?.toString(),
      likes:        (j['likes'] as num?)?.toInt() ?? 0,
      replyCount:   (j['replyCount'] as num?)?.toInt() ?? 0,
      likedBy:      (j['likedBy'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      isMarketIdea: j['is_market_idea'] ?? false,
      createdAt:    _parseThoughtDate(j['createdAt']),
      updatedAt:    _parseThoughtDate(j['updatedAt']),
      replies:      (j['replies'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((r) => ThoughtModel.fromJson(r))
          .toList(),
    );
  }

  bool isLikedBy(String userId) => likedBy.contains(userId);

  String get timeAgo {
    if (createdAt == null) return '';
    final d = DateTime.now().difference(createdAt!);
    if (d.inSeconds < 60) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours   < 24) return '${d.inHours}h ago';
    if (d.inDays    < 30) return '${d.inDays}d ago';
    return '${(d.inDays / 30).floor()}mo ago';
  }

  ThoughtModel withLikeToggled(String userId) {
    final already = likedBy.contains(userId);
    return ThoughtModel(
      id: id, user: user, eventId: eventId, content: content, parent: parent,
      likes:        already ? likes - 1 : likes + 1,
      replyCount:   replyCount,
      likedBy:      already
          ? (List<String>.from(likedBy)..remove(userId))
          : (List<String>.from(likedBy)..add(userId)),
      isMarketIdea: isMarketIdea, createdAt: createdAt,
      updatedAt: updatedAt, replies: replies,
    );
  }
}

// GET /events/:id/thoughts?page=1&limit=25
// { "success": true, "data": { "thoughts": [...], "pagination": { "page": 1, "limit": 25 } } }
class ThoughtsResponseModel {
  final bool               success;
  final List<ThoughtModel> thoughts;
  final int                page;
  final int                limit;

  ThoughtsResponseModel({required this.success, required this.thoughts, required this.page, required this.limit});

  factory ThoughtsResponseModel.fromJson(Map<String, dynamic> json) {
    final data       = json['data'] as Map<String, dynamic>?;
    final rawList    = data?['thoughts'] ?? json['thoughts'] ?? [];
    final pagination = data?['pagination'] as Map<String, dynamic>?;

    final List<ThoughtModel> parsed = [];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          try { parsed.add(ThoughtModel.fromJson(item)); } catch (_) {}
        }
      }
    }

    return ThoughtsResponseModel(
      success:  json['success'] ?? true,
      thoughts: parsed,
      page:     (pagination?['page']  as num?)?.toInt() ?? 1,
      limit:    (pagination?['limit'] as num?)?.toInt() ?? 25,
    );
  }
}

// POST /thoughts
// { "success": true, "message": "Thought created", "data": { "thought": {...} } }
class PostThoughtResponseModel {
  final bool          success;
  final String        message;
  final ThoughtModel? thought;

  PostThoughtResponseModel({required this.success, required this.message, this.thought});

  factory PostThoughtResponseModel.fromJson(Map<String, dynamic> json) {
    final data       = json['data'] as Map<String, dynamic>?;
    final rawThought = data?['thought'];
    return PostThoughtResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      thought: rawThought is Map<String, dynamic> ? ThoughtModel.fromJson(rawThought) : null,
    );
  }
}