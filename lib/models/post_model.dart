import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String venueId; // ID của quán cà phê/địa điểm
  final String venueName;
  final String content;
  final double rating;
  final List<String> images;
  final List<String> hashtags;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.venueId,
    required this.venueName,
    required this.content,
    required this.rating,
    required this.images,
    this.hashtags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json, String documentId) {
    return PostModel(
      id: documentId,
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Người dùng',
      userPhotoUrl: json['userPhotoUrl'],
      venueId: json['venueId'] ?? '',
      venueName: json['venueName'] ?? '',
      content: json['content'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      hashtags: List<String>.from(json['hashtags'] ?? []),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'venueId': venueId,
      'venueName': venueName,
      'content': content,
      'rating': rating,
      'images': images,
      'hashtags': hashtags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
