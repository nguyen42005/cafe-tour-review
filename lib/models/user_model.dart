class UserModel {
  final String id;
  String email;
  String displayName;
  String photoUrl;
  int exp;
  String title;
  int followers;
  int following;
  int placesVisited;
  int postsCount;
  String role;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.exp = 0,
    this.title = 'Tân Binh',
    this.followers = 0,
    this.following = 0,
    this.placesVisited = 0,
    this.postsCount = 0,
    this.role = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String documentId) {
    return UserModel(
      id: documentId,
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      exp: json['exp'] ?? 0,
      title: json['title'] ?? 'Tân Binh',
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      placesVisited: json['placesVisited'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'exp': exp,
      'title': title,
      'followers': followers,
      'following': following,
      'placesVisited': placesVisited,
      'postsCount': postsCount,
      'role': role,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
