class CategoryModel {
  final String id;
  final String name;
  final String icon; // Icon name e.g 'coffee' or image url
  final int sortOrder;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json, String documentId) {
    return CategoryModel(
      id: documentId,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
