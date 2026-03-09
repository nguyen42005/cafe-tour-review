import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Lấy thông tin user hiện tại
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _db.collection(_collection).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('GetUser Error: $e');
      return null;
    }
  }

  // Tạo hoặc cập nhật user
  Future<void> saveUser(UserModel user) async {
    try {
      await _db
          .collection(_collection)
          .doc(user.id)
          .set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('SaveUser Error: $e');
      throw Exception('Không thể lưu thông tin người dùng');
    }
  }

  // Cập nhật 1 vài trường cụ thể (ví dụ: đổi tên, đổi ảnh)
  Future<void> updatePartialUser(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection(_collection).doc(uid).update(data);
    } catch (e) {
      print('UpdateUser Error: $e');
      throw Exception('Không thể cập nhật thông tin');
    }
  }

  // Lấy stream danh sách tất cả user (Admin)
  Stream<List<UserModel>> getAllUsersStream() {
    return _db
        .collection(_collection)
        .orderBy('displayName')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  // Cập nhật vai trò người dùng
  Future<void> updateRole(String uid, String newRole) async {
    try {
      await _db.collection(_collection).doc(uid).update({'role': newRole});
    } catch (e) {
      print('UpdateRole Error: $e');
      throw Exception('Không thể cập nhật vai trò');
    }
  }

  // Cập nhật trạng thái người dùng (ví dụ: thêm trường isBlocked nếu cần)
  Future<void> toggleUserBlock(String uid, bool isBlocked) async {
    try {
      await _db.collection(_collection).doc(uid).update({
        'isBlocked': isBlocked,
      });
    } catch (e) {
      print('ToggleBlock Error: $e');
      throw Exception('Không thể cập nhật trạng thái');
    }
  }

  Future<bool> isPlaceSaved(String uid, String placeId) async {
    try {
      final doc = await _db.collection(_collection).doc(uid).get();
      final data = doc.data();
      if (data == null) return false;
      final saved = List<String>.from(data['savedPlaceIds'] ?? const []);
      return saved.contains(placeId);
    } catch (e) {
      print('IsPlaceSaved Error: $e');
      return false;
    }
  }

  Future<void> toggleSavedPlace(String uid, String placeId, bool shouldSave) async {
    try {
      await _db.collection(_collection).doc(uid).set({
        'savedPlaceIds': shouldSave
            ? FieldValue.arrayUnion([placeId])
            : FieldValue.arrayRemove([placeId]),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('ToggleSavedPlace Error: $e');
      throw Exception('Không thể cập nhật danh sách địa điểm đã lưu');
    }
  }
}
