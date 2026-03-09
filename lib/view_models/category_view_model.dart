import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Stream toàn bộ Categories realtime
  Stream<List<CategoryModel>> get categoriesStream =>
      _categoryService.getCategoriesStream();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> addCategory(
    String name,
    String icon,
    int sortOrder,
    bool isActive,
  ) async {
    if (name.isEmpty) {
      _errorMessage = 'Tên danh mục không được để trống';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final newCategory = CategoryModel(
        id: '', // Firestore sẽ tự tạo
        name: name,
        icon: icon,
        sortOrder: sortOrder,
        isActive: isActive,
      );
      await _categoryService.addCategory(newCategory);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCategoryStatus(String id, bool isActive) async {
    try {
      await _categoryService.updateCategory(id, {'isActive': isActive});
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(
    String id,
    String name,
    String icon,
    int sortOrder,
    bool isActive,
  ) async {
    if (name.isEmpty) {
      _errorMessage = 'Tên danh mục không được để trống';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      await _categoryService.updateCategory(id, {
        'name': name,
        'icon': icon,
        'sortOrder': sortOrder,
        'isActive': isActive,
      });
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _categoryService.deleteCategory(id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
