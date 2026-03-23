import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';

class ActivityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _usersCollection = 'users';
  final String _activitiesCollection = 'activities';

  Future<void> logActivity({
    required String ownerId,
    required ActivityModel activity,
  }) async {
    if (ownerId == activity.fromUserId) return; // Don't log self-activity

    try {
      await _db
          .collection(_usersCollection)
          .doc(ownerId)
          .collection(_activitiesCollection)
          .add(activity.toJson());
    } catch (e) {
      print('LogActivity Error: $e');
    }
  }

  Stream<List<ActivityModel>> getActivitiesStream(String uid) {
    return _db
        .collection(_usersCollection)
        .doc(uid)
        .collection(_activitiesCollection)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ActivityModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> markAsRead(String uid, String activityId) async {
    try {
      await _db
          .collection(_usersCollection)
          .doc(uid)
          .collection(_activitiesCollection)
          .doc(activityId)
          .update({'isRead': true});
    } catch (e) {
      print('MarkAsRead Error: $e');
    }
  }
}
