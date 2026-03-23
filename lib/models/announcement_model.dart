import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String type; // 'info', 'warning', 'promotion'
  final DateTime createdAt;
  final String createdBy;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.type = 'info',
    required this.createdAt,
    required this.createdBy,
  });

  factory AnnouncementModel.fromJson(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return AnnouncementModel(
      id: documentId,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'info',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }
}
