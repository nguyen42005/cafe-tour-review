import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_comment_model.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';
import 'user_service.dart';
import 'gamification_service.dart';
import 'activity_service.dart';

class PostPageResult {
  final List<PostModel> posts;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;

  const PostPageResult({
    required this.posts,
    required this.lastDocument,
    required this.hasMore,
  });
}

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'posts';
  final UserService _userService = UserService();
  final ActivityService _activityService = ActivityService();

  CollectionReference<Map<String, dynamic>> _postsRef() =>
      _db.collection(_collection);

  CollectionReference<Map<String, dynamic>> _likesRef(String postId) =>
      _postsRef().doc(postId).collection('likes');

  CollectionReference<Map<String, dynamic>> _commentsRef(String postId) =>
      _postsRef().doc(postId).collection('comments');

  CollectionReference<Map<String, dynamic>> _commentLikesRef(
    String postId,
    String commentId,
  ) => _commentsRef(postId).doc(commentId).collection('likes');

  Future<PostModel?> getPost(String postId) async {
    try {
      final doc = await _postsRef().doc(postId).get();
      if (doc.exists && doc.data() != null) {
        return PostModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('GetPost Error: $e');
      return null;
    }
  }

  Future<String> createPost(PostModel post) async {
    try {
      final docRef = await _postsRef().add(post.toJson());
      return docRef.id;
    } catch (e) {
      print('CreatePost Error: $e');
      throw Exception('Không thể tạo bài viết');
    }
  }

  Stream<List<PostModel>> getPosts({String? userId}) {
    Query query = _postsRef().orderBy('createdAt', descending: true);

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<PostPageResult> getPostsPage({
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    int limit = 10,
  }) async {
    Query<Map<String, dynamic>> query = _postsRef()
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;

    final posts = docs
        .map((doc) => PostModel.fromJson(doc.data(), doc.id))
        .toList();

    return PostPageResult(
      posts: posts,
      lastDocument: docs.isNotEmpty ? docs.last : lastDocument,
      hasMore: docs.length == limit,
    );
  }

  Stream<List<PostModel>> getPostsByVenue(String venueId) {
    return _postsRef().where('venueId', isEqualTo: venueId).snapshots().map((
      snapshot,
    ) {
      final posts = snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data(), doc.id))
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  Future<void> updatePostStats(
    String postId, {
    int? likes,
    int? comments,
  }) async {
    Map<String, dynamic> data = {};
    if (likes != null) data['likesCount'] = FieldValue.increment(likes);
    if (comments != null)
      data['commentsCount'] = FieldValue.increment(comments);

    if (data.isNotEmpty) {
      await _postsRef().doc(postId).update(data);
    }
  }

  Future<void> deletePost(String postId, String userId) async {
    try {
      await _postsRef().doc(postId).delete();
      await _userService.updatePartialUser(userId, {
        'postsCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('DeletePost Error: $e');
      throw Exception('Không thể xóa bài viết');
    }
  }

  Future<void> toggleHidePost(String postId, bool isHidden) async {
    try {
      await _postsRef().doc(postId).update({'isHidden': isHidden});
    } catch (e) {
      print('ToggleHidePost Error: $e');
      throw Exception('Không thể ẩn/hiện bài viết');
    }
  }

  Future<bool> isPostLikedByUser(String postId, String userId) async {
    final doc = await _likesRef(postId).doc(userId).get();
    return doc.exists;
  }

  Future<void> togglePostLike({
    required String postId,
    required UserModel liker,
    required bool shouldLike,
  }) async {
    final batch = _db.batch();
    final postRef = _postsRef().doc(postId);
    final likeRef = _likesRef(postId).doc(liker.id);

    if (shouldLike) {
      batch.set(likeRef, {
        'userId': liker.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final postDoc = await postRef.get();
      if (postDoc.exists) {
        final data = postDoc.data()!;
        final int newLikes = (data['likesCount'] ?? 0) + 1;
        final int comments = data['commentsCount'] ?? 0;
        final double newHotScore = (newLikes * 10.0) + (comments * 30.0);

        batch.update(postRef, {
          'likesCount': newLikes,
          'hotScore': newHotScore,
        });
        final authorId = postDoc.data()?['userId'];
        if (authorId != null && authorId != liker.id) {
          await _userService.addExp(
            authorId,
            GamificationService.expReceiveLike,
          );

          // Log Activity
          await _activityService.logActivity(
            ownerId: authorId,
            activity: ActivityModel(
              id: '',
              type: 'like',
              fromUserId: liker.id,
              fromUserName: liker.displayName,
              fromUserPhoto: liker.photoUrl,
              targetId: postId,
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    } else {
      batch.delete(likeRef);

      final postDoc = await postRef.get();
      if (postDoc.exists) {
        final data = postDoc.data()!;
        final int newLikes = ((data['likesCount'] ?? 0) - 1).clamp(0, 999999);
        final int comments = data['commentsCount'] ?? 0;
        final double newHotScore = (newLikes * 10.0) + (comments * 30.0);

        batch.update(postRef, {
          'likesCount': newLikes,
          'hotScore': newHotScore,
        });
      }
    }

    await batch.commit();
  }

  Stream<List<PostCommentModel>> getCommentsStream(String postId) {
    return _commentsRef(postId)
        .orderBy('createdAt', descending: false)
        .limit(300)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PostCommentModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addComment({
    required String postId,
    required PostCommentModel comment,
    required String performerName,
    required String performerPhoto,
  }) async {
    final postRef = _postsRef().doc(postId);
    final commentRef = _commentsRef(postId).doc();

    await _db.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) return;

      final data = postSnapshot.data()!;
      final int likes = data['likesCount'] ?? 0;
      final int newComments = (data['commentsCount'] ?? 0) + 1;
      final double newHotScore = (likes * 10.0) + (newComments * 30.0);

      transaction.set(commentRef, comment.toJson());
      transaction.update(postRef, {
        'commentsCount': newComments,
        'hotScore': newHotScore,
      });
    });

    // Thưởng EXP & Log Activity
    try {
      final postDoc = await postRef.get();
      if (postDoc.exists) {
        final authorId = postDoc.data()?['userId'];
        if (authorId != null && authorId != comment.userId) {
          await _userService.addExp(
            authorId,
            GamificationService.expReceiveComment,
          );

          // Log Activity
          await _activityService.logActivity(
            ownerId: authorId,
            activity: ActivityModel(
              id: '',
              type: 'comment',
              fromUserId: comment.userId,
              fromUserName: performerName,
              fromUserPhoto: performerPhoto,
              targetId: postId,
              content: comment.content,
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      print('AddComment Activity/EXP Error: $e');
    }
  }

  Future<bool> isCommentLikedByUser(
    String postId,
    String commentId,
    String userId,
  ) async {
    final doc = await _commentLikesRef(postId, commentId).doc(userId).get();
    return doc.exists;
  }

  Future<void> toggleCommentLike({
    required String postId,
    required String commentId,
    required String userId,
    required bool shouldLike,
  }) async {
    await _db.runTransaction((transaction) async {
      final commentRef = _commentsRef(postId).doc(commentId);
      final likeDocRef = _commentLikesRef(postId, commentId).doc(userId);

      if (shouldLike) {
        transaction.set(likeDocRef, {
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(commentRef, {'likesCount': FieldValue.increment(1)});
      } else {
        transaction.delete(likeDocRef);
        transaction.update(commentRef, {
          'likesCount': FieldValue.increment(-1),
        });
      }
    });
  }

  Future<List<PostModel>> getPostsByIds(List<String> postIds) async {
    if (postIds.isEmpty) return [];

    // Firestore whereIn has a limit of 30 in some versions, but 10 is safest.
    // For simplicity, we'll fetch all if small, or chunk if needed.
    // Here we'll do a simple fetch for up to 30.
    final snapshot = await _postsRef()
        .where(FieldPath.documentId, whereIn: postIds.take(30).toList())
        .get();

    return snapshot.docs
        .map((doc) => PostModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  // Thuật toán bảng tin: Followed users + Trending
  Future<List<PostModel>> getRecommendedPosts({
    required String uid,
    int limit = 20,
  }) async {
    try {
      // 1. Lấy danh sách đang theo dõi
      final followingSnapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('following')
          .limit(100)
          .get();

      final followingUids = followingSnapshot.docs.map((d) => d.id).toList();

      List<PostModel> allPosts = [];

      // 2. Lấy bài viết từ người theo dõi (nếu có)
      if (followingUids.isNotEmpty) {
        // Bỏ orderBy createdAt để tránh yêu cầu missing composite index trên Firebase
        final followedPostsSnapshot = await _postsRef()
            .where('userId', whereIn: followingUids.take(10).toList())
            .limit(20)
            .get();

        allPosts.addAll(
          followedPostsSnapshot.docs.map(
            (d) => PostModel.fromJson(d.data(), d.id),
          ),
        );
      }

      // 3. Lấy bài viết trending (hotScore cao)
      // Bỏ orderBy createdAt tiếp theo để tránh yêu cầu missing composite index
      final trendingSnapshot = await _postsRef()
          .orderBy('hotScore', descending: true)
          .limit(limit)
          .get();

      final trendingPosts = trendingSnapshot.docs.map(
        (d) => PostModel.fromJson(d.data(), d.id),
      );

      // 3.5 Lấy bài viết nhiều like nhất (dành cho dữ liệu cũ chưa có trường hotScore)
      final topLikedSnapshot = await _postsRef()
          .orderBy('likesCount', descending: true)
          .limit(limit)
          .get();

      final topLikedPosts = topLikedSnapshot.docs.map(
        (d) => PostModel.fromJson(d.data(), d.id),
      );

      // Lấy thêm bài viết mới nhất (để bao phủ các bài cũ chưa có hotScore)
      final recentSnapshot = await _postsRef()
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final recentPosts = recentSnapshot.docs.map(
        (d) => PostModel.fromJson(d.data(), d.id),
      );

      // 4. Hợp nhất và loại bỏ trùng lặp
      for (final post in trendingPosts) {
        if (!allPosts.any((p) => p.id == post.id)) {
          allPosts.add(post);
        }
      }
      for (final post in topLikedPosts) {
        if (!allPosts.any((p) => p.id == post.id)) {
          allPosts.add(post);
        }
      }
      for (final post in recentPosts) {
        if (!allPosts.any((p) => p.id == post.id)) {
          allPosts.add(post);
        }
      }

      // 5. Sắp xếp: Ưu tiên hotScore cao và người đang theo dõi
      allPosts.sort((a, b) {
        double scoreA = a.hotScore;
        double scoreB = b.hotScore;

        // Ưu tiên bài viết của người đang theo dõi
        if (followingUids.contains(a.userId)) scoreA += 100;
        if (followingUids.contains(b.userId)) scoreB += 100;

        // Nếu điểm bằng nhau, ưu tiên bài mới hơn
        if (scoreA == scoreB) {
          return b.createdAt.compareTo(a.createdAt);
        }

        return scoreB.compareTo(scoreA);
      });

      // 6. Lọc bỏ bài viết bị ẩn (đề phòng)
      return allPosts.where((p) => !p.isHidden).take(limit).toList();
    } catch (e) {
      print('GetRecommendedPosts Error: $e');
      // Fallback về bài mới nhất
      final fallback = await getPostsPage(limit: limit);
      return fallback.posts;
    }
  }
}
