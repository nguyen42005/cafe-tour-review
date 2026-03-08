import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserAdminViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Stream toàn bộ người dùng
  Stream<List<UserModel>> get usersStream => _userService.getAllUsersStream();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Cập nhật vai trò (admin/user)
  Future<bool> updateUserRole(String uid, String newRole) async {
    _setLoading(true);
    try {
      await _userService.updateRole(uid, newRole);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Khóa/Mở khóa người dùng
  Future<bool> toggleBlock(String uid, bool isBlocked) async {
    _setLoading(true);
    try {
      await _userService.toggleUserBlock(uid, isBlocked);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
