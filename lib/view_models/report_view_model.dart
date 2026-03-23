import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportService _reportService = ReportService();
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Stream báo cáo realtime
  Stream<List<ReportModel>> get reportsStream =>
      _reportService.getReportsStream();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> submitReport(ReportModel report) async {
    _setLoading(true);
    try {
      await _reportService.submitReport(report);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resolveReport(String reportId, String status) async {
    _setLoading(true);
    try {
      await _reportService.updateReportStatus(reportId, status);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Lấy dữ liệu mục tiêu để hiển thị preview
  Future<dynamic> getTargetPreview(String targetId, String targetType) async {
    try {
      if (targetType == 'post') {
        return await _postService.getPost(targetId);
      } else if (targetType == 'user') {
        return await _userService.getUser(targetId);
      }
    } catch (e) {
      debugPrint('GetTargetPreview Error: $e');
    }
    return null;
  }

  // Thực hiện hành động điều phối (Moderation)
  Future<bool> takeModerationAction({
    required String reportId,
    required String targetId,
    required String targetType,
    required String action, // 'hide', 'delete', 'block', 'dismiss'
  }) async {
    _setLoading(true);
    try {
      if (action == 'hide' && targetType == 'post') {
        await _postService.toggleHidePost(targetId, true);
      } else if (action == 'delete' && targetType == 'post') {
        final post = await _postService.getPost(targetId);
        if (post != null) {
          await _postService.deletePost(targetId, post.userId);
        }
      } else if (action == 'block' && targetType == 'user') {
        await _userService.toggleUserBlock(targetId, true);
      }

      // Sau khi thực hiện hành động, đánh dấu report là đã xử lý (resolved) hoặc bỏ qua (dismissed)
      final finalStatus = action == 'dismiss' ? 'dismissed' : 'resolved';
      await _reportService.updateReportStatus(reportId, finalStatus);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
