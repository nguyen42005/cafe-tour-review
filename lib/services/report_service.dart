import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'reports';

  // Gửi báo cáo mới
  Future<void> submitReport(ReportModel report) async {
    try {
      await _db.collection(_collection).add(report.toJson());
    } catch (e) {
      print('SubmitReport Error: $e');
      throw Exception('Không thể gửi báo cáo');
    }
  }

  // Lấy stream danh sách báo cáo (Admin)
  Stream<List<ReportModel>> getReportsStream({String? status}) {
    Query query = _db
        .collection(_collection)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReportModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Cập nhật trạng thái báo cáo
  Future<void> updateReportStatus(String reportId, String status) async {
    try {
      await _db.collection(_collection).doc(reportId).update({
        'status': status,
      });
    } catch (e) {
      print('UpdateReportStatus Error: $e');
      throw Exception('Không thể cập nhật trạng thái báo cáo');
    }
  }
}
