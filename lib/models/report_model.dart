import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String reporterId;
  final String reporterName;
  final String targetId; // ID của bài viết hoặc người dùng bị báo cáo
  final String targetType; // 'post' or 'user'
  final String reason;
  final String status; // 'pending', 'resolved', 'dismissed'
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.targetId,
    required this.targetType,
    required this.reason,
    this.status = 'pending',
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json, String id) {
    return ReportModel(
      id: id,
      reporterId: json['reporterId'] ?? '',
      reporterName: json['reporterName'] ?? '',
      targetId: json['targetId'] ?? '',
      targetType: json['targetType'] ?? 'post',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reporterId': reporterId,
      'reporterName': reporterName,
      'targetId': targetId,
      'targetType': targetType,
      'reason': reason,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
