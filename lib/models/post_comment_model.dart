import 'package:cloud_firestore/cloud_firestore.dart';

class PostCommentModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String content;
  final String parentId;
  final int likesCount;
  final DateTime createdAt;

  const PostCommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.content,
    this.parentId = '',
    this.likesCount = 0,
    required this.createdAt,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json, String id) {
    return PostCommentModel(
      id: id,
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Người dùng',
      userPhotoUrl: json['userPhotoUrl'] ?? '',
      content: json['content'] ?? '',
      parentId: json['parentId'] ?? '',
      likesCount: json['likesCount'] ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'parentId': parentId,
      'likesCount': likesCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
