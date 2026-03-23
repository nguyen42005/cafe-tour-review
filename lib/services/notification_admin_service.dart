import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';

class NotificationAdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'announcements';

  // Gửi thông báo hệ thống mới
  Future<void> sendAnnouncement(AnnouncementModel announcement) async {
    try {
      await _db.collection(_collection).add(announcement.toJson());
    } catch (e) {
      print('SendAnnouncement Error: $e');
      throw Exception('Không thể gửi thông báo');
    }
  }

  // Lấy danh sách thông báo đã gửi
  Stream<List<AnnouncementModel>> getAnnouncementsStream() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AnnouncementModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  // Xóa thông báo
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } catch (e) {
      print('DeleteAnnouncement Error: $e');
      throw Exception('Không thể xóa thông báo');
    }
  }
}
