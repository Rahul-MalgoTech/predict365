// lib/Models/CategoryModel.dart

class CategoryModel {
  final String id;
  final String name;
  final String image;
  final String description;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.order,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id:          json['_id']         ?? '',
      name:        json['name']        ?? '',
      image:       json['image']       ?? '',
      description: json['description'] ?? '',
      order:       json['order']       ?? 0,
      createdAt:   _parseDate(json['createdAt']),
      updatedAt:   _parseDate(json['updatedAt']),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

class CategoryListResponseModel {
  final bool success;
  final String message;
  final List<CategoryModel> categories;

  CategoryListResponseModel({
    required this.success,
    required this.message,
    required this.categories,
  });

  factory CategoryListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final list = data['categories'] as List<dynamic>? ?? [];
    return CategoryListResponseModel(
      success:    json['success'] ?? false,
      message:    json['message'] ?? '',
      categories: list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.order.compareTo(a.order)), // sort by order desc
    );
  }
}