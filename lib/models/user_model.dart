import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  String displayName;
  String photoUrl;
  String bio;
  int exp;
  String title;
  int followers;
  int following;
  int placesVisited;
  int postsCount;
  bool isBlocked;
  String role; // 'user' or 'admin'
  List<String> savedPostIds;
  List<String> savedPlaceIds;
  final DateTime createdAt;
  DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.bio = '',
    this.exp = 0,
    this.title = 'Tân Binh',
    this.followers = 0,
    this.following = 0,
    this.placesVisited = 0,
    this.postsCount = 0,
    this.isBlocked = false,
    this.role = 'user',
    this.savedPostIds = const [],
    this.savedPlaceIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String documentId) {
    return UserModel(
      id: documentId,
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      bio: json['bio'] ?? '',
      exp: json['exp'] ?? 0,
      title: json['title'] ?? 'Tân Binh',
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      placesVisited: json['placesVisited'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
      isBlocked: json['isBlocked'] ?? false,
      role: json['role'] ?? 'user',
      savedPostIds: List<String>.from(json['savedPostIds'] ?? []),
      savedPlaceIds: List<String>.from(json['savedPlaceIds'] ?? []),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
                ? DateTime.parse(json['createdAt'])
                : (json['createdAt'] as Timestamp).toDate())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is String
                ? DateTime.parse(json['updatedAt'])
                : (json['updatedAt'] as Timestamp).toDate())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'exp': exp,
      'title': title,
      'followers': followers,
      'following': following,
      'placesVisited': placesVisited,
      'postsCount': postsCount,
      'isBlocked': isBlocked,
      'role': role,
      'savedPostIds': savedPostIds,
      'savedPlaceIds': savedPlaceIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
