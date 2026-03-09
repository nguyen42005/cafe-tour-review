import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import 'package:flutter/foundation.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'categories';

  // Lấy stream danh sách category
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _db
        .collection(_collection)
        .orderBy('sortOrder')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  // Lấy danh sách 1 lần
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _db
          .collection(_collection)
          .orderBy('sortOrder')
          .get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  // Thêm mới category
  Future<void> addCategory(CategoryModel category) async {
    try {
      await _db.collection(_collection).add(category.toJson());
    } catch (e) {
      debugPrint('Error adding category: $e');
      throw Exception('Không thể thêm danh mục');
    }
  }

  // Cập nhật category
  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection(_collection).doc(id).update(data);
    } catch (e) {
      debugPrint('Error updating category: $e');
      throw Exception('Không thể cập nhật danh mục');
    }
  }

  // Xóa category
  Future<void> deleteCategory(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting category: $e');
      throw Exception('Không thể xóa danh mục');
    }
  }
}
