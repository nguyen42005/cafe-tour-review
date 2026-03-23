import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType { like, comment, follow }

class ActivityModel {
  final String id;
  final String type; // 'like', 'comment', 'follow'
  final String fromUserId;
  final String fromUserName;
  final String fromUserPhoto;
  final String targetId; // Post ID or User ID
  final String content; // Optional: comment snippet
  final DateTime createdAt;
  final bool isRead;

  ActivityModel({
    required this.id,
    required this.type,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserPhoto,
    required this.targetId,
    this.content = '',
    required this.createdAt,
    this.isRead = false,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json, String documentId) {
    return ActivityModel(
      id: documentId,
      type: json['type'] ?? 'like',
      fromUserId: json['fromUserId'] ?? '',
      fromUserName: json['fromUserName'] ?? '',
      fromUserPhoto: json['fromUserPhoto'] ?? '',
      targetId: json['targetId'] ?? '',
      content: json['content'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserPhoto': fromUserPhoto,
      'targetId': targetId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}
