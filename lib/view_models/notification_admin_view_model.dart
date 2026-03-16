import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/notification_admin_service.dart';

class NotificationAdminViewModel extends ChangeNotifier {
  final NotificationAdminService _service = NotificationAdminService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<AnnouncementModel>> get announcementsStream =>
      _service.getAnnouncementsStream();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> sendAnnouncement({
    required String title,
    required String content,
    required String type,
    required String adminId,
  }) async {
    _setLoading(true);
    try {
      final announcement = AnnouncementModel(
        id: '',
        title: title,
        content: content,
        type: type,
        createdAt: DateTime.now(),
        createdBy: adminId,
      );
      await _service.sendAnnouncement(announcement);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await _service.deleteAnnouncement(id);
    } catch (e) {
      debugPrint('Delete Error: $e');
    }
  }
}
