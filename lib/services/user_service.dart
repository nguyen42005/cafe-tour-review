import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';
import 'gamification_service.dart';
import 'activity_service.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';
  final ActivityService _activityService = ActivityService();

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

  Future<void> toggleSavedPlace(
    String uid,
    String placeId,
    bool shouldSave,
  ) async {
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

  Future<bool> isPostSaved(String uid, String postId) async {
    try {
      final doc = await _db.collection(_collection).doc(uid).get();
      final data = doc.data();
      if (data == null) return false;
      final saved = List<String>.from(data['savedPostIds'] ?? const []);
      return saved.contains(postId);
    } catch (e) {
      print('IsPostSaved Error: $e');
      return false;
    }
  }

  Future<void> toggleSavedPost(
    String uid,
    String postId,
    bool shouldSave,
  ) async {
    try {
      await _db.collection(_collection).doc(uid).set({
        'savedPostIds': shouldSave
            ? FieldValue.arrayUnion([postId])
            : FieldValue.arrayRemove([postId]),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('ToggleSavedPost Error: $e');
      throw Exception('Không thể cập nhật bài viết đã lưu');
    }
  }

  // --- Follow / Unfollow Logic ---

  Future<bool> isFollowing(String currentUid, String targetUid) async {
    try {
      final doc = await _db
          .collection(_collection)
          .doc(currentUid)
          .collection('following')
          .doc(targetUid)
          .get();
      return doc.exists;
    } catch (e) {
      print('IsFollowing Error: $e');
      return false;
    }
  }

  Future<void> followUser(UserModel follower, String targetUid) async {
    final String currentUid = follower.id;
    if (currentUid == targetUid) return;

    final batch = _db.batch();

    // 1. Add targetUid to currentUid's following collection
    batch.set(
      _db
          .collection(_collection)
          .doc(currentUid)
          .collection('following')
          .doc(targetUid),
      {'uid': targetUid, 'createdAt': FieldValue.serverTimestamp()},
    );

    // 2. Add currentUid to targetUid's followers collection
    batch.set(
      _db
          .collection(_collection)
          .doc(targetUid)
          .collection('followers')
          .doc(currentUid),
      {'uid': currentUid, 'createdAt': FieldValue.serverTimestamp()},
    );

    // 3. Update counts
    batch.update(_db.collection(_collection).doc(currentUid), {
      'following': FieldValue.increment(1),
    });
    batch.update(_db.collection(_collection).doc(targetUid), {
      'followers': FieldValue.increment(1),
    });

    await batch.commit();

    // 4. Thưởng EXP & Log Activity
    try {
      await addExp(targetUid, GamificationService.expGainFollower);

      await _activityService.logActivity(
        ownerId: targetUid,
        activity: ActivityModel(
          id: '',
          type: 'follow',
          fromUserId: currentUid,
          fromUserName: follower.displayName,
          fromUserPhoto: follower.photoUrl,
          targetId: currentUid,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      print('Follow Activity/EXP Error: $e');
    }
  }

  Future<void> unfollowUser(String currentUid, String targetUid) async {
    final batch = _db.batch();

    // 1. Remove targetUid from currentUid's following collection
    batch.delete(
      _db
          .collection(_collection)
          .doc(currentUid)
          .collection('following')
          .doc(targetUid),
    );

    // 2. Remove currentUid from targetUid's followers collection
    batch.delete(
      _db
          .collection(_collection)
          .doc(targetUid)
          .collection('followers')
          .doc(currentUid),
    );

    // 3. Update counts
    batch.update(_db.collection(_collection).doc(currentUid), {
      'following': FieldValue.increment(-1),
    });
    batch.update(_db.collection(_collection).doc(targetUid), {
      'followers': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  // --- Gamification Logic ---

  Future<void> addExp(String uid, int amount) async {
    try {
      final userDoc = await _db.collection(_collection).doc(uid).get();
      if (!userDoc.exists) return;

      final data = userDoc.data()!;
      final int currentExp = data['exp'] ?? 0;
      final String currentTitle = data['title'] ?? 'Tân Binh';

      final int newExp = currentExp + amount;
      final String newTitle = GamificationService.getTitleForExp(newExp);

      final Map<String, dynamic> updates = {
        'exp': newExp,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (newTitle != currentTitle) {
        updates['title'] = newTitle;
      }

      await _db.collection(_collection).doc(uid).update(updates);
    } catch (e) {
      print('AddExp Error: $e');
    }
  }
}
