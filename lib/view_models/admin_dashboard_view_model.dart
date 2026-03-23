import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _totalUsers = 0;
  int get totalUsers => _totalUsers;

  int _totalPosts = 0;
  int get totalPosts => _totalPosts;

  int _totalPlaces = 0;
  int get totalPlaces => _totalPlaces;

  int _pendingReports = 0;
  int get pendingReports => _pendingReports;

  List<Map<String, dynamic>> _topContributors = [];
  List<Map<String, dynamic>> get topContributors => _topContributors;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final stats = await _adminService.getDashboardStats();
      _totalUsers = stats['totalUsers'] ?? 0;
      _totalPosts = stats['totalPosts'] ?? 0;
      _totalPlaces = stats['totalPlaces'] ?? 0;
      _pendingReports = stats['pendingReports'] ?? 0;

      _topContributors = await _adminService.getTopContributors();
    } catch (e) {
      print('LoadDashboardData Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
