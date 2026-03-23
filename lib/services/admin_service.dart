import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Lấy thống kê tổng quan
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final results = await Future.wait([
        _db.collection('users').count().get(),
        _db.collection('posts').count().get(),
        _db.collection('places').count().get(),
        _db
            .collection('reports')
            .where('status', isEqualTo: 'pending')
            .count()
            .get(),
      ]);

      return {
        'totalUsers': results[0].count ?? 0,
        'totalPosts': results[1].count ?? 0,
        'totalPlaces': results[2].count ?? 0,
        'pendingReports': results[3].count ?? 0,
      };
    } catch (e) {
      print('GetDashboardStats Error: $e');
      return {
        'totalUsers': 0,
        'totalPosts': 0,
        'totalPlaces': 0,
        'pendingReports': 0,
      };
    }
  }

  // Lấy danh sách người dùng tiềm năng (ví dụ: top EXP)
  Future<List<Map<String, dynamic>>> getTopContributors() async {
    try {
      final snapshot = await _db
          .collection('users')
          .orderBy('exp', descending: true)
          .limit(5)
          .get();

      return snapshot.docs
          .map(
            (doc) => {
              'id': doc.id,
              'displayName': doc.data()['displayName'] ?? 'Unknown',
              'photoUrl': doc.data()['photoUrl'] ?? '',
              'exp': doc.data()['exp'] ?? 0,
            },
          )
          .toList();
    } catch (e) {
      print('GetTopContributors Error: $e');
      return [];
    }
  }
}
