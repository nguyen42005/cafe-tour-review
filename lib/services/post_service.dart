import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_comment_model.dart';
import '../models/post_model.dart';

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

  CollectionReference<Map<String, dynamic>> _postsRef() =>
      _db.collection(_collection);

  CollectionReference<Map<String, dynamic>> _likesRef(String postId) =>
      _postsRef().doc(postId).collection('likes');

  CollectionReference<Map<String, dynamic>> _commentsRef(String postId) =>
      _postsRef().doc(postId).collection('comments');

  CollectionReference<Map<String, dynamic>> _commentLikesRef(
    String postId,
    String commentId,
  ) =>
      _commentsRef(postId).doc(commentId).collection('likes');

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

    final posts = docs.map((doc) => PostModel.fromJson(doc.data(), doc.id)).toList();

    return PostPageResult(
      posts: posts,
      lastDocument: docs.isNotEmpty ? docs.last : lastDocument,
      hasMore: docs.length == limit,
    );
  }

  Stream<List<PostModel>> getPostsByVenue(String venueId) {
    return _postsRef()
        .where('venueId', isEqualTo: venueId)
        .snapshots()
        .map((snapshot) {
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
    if (comments != null) data['commentsCount'] = FieldValue.increment(comments);

    if (data.isNotEmpty) {
      await _postsRef().doc(postId).update(data);
    }
  }

  Future<bool> isPostLikedByUser(String postId, String userId) async {
    final doc = await _likesRef(postId).doc(userId).get();
    return doc.exists;
  }

  Future<void> togglePostLike({
    required String postId,
    required String userId,
    required bool shouldLike,
  }) async {
    await _db.runTransaction((transaction) async {
      final postRef = _postsRef().doc(postId);
      final likeDocRef = _likesRef(postId).doc(userId);

      if (shouldLike) {
        transaction.set(likeDocRef, {
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(postRef, {'likesCount': FieldValue.increment(1)});
      } else {
        transaction.delete(likeDocRef);
        transaction.update(postRef, {'likesCount': FieldValue.increment(-1)});
      }
    });
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
  }) async {
    final postRef = _postsRef().doc(postId);
    final commentRef = _commentsRef(postId).doc();

    await _db.runTransaction((transaction) async {
      transaction.set(commentRef, comment.toJson());
      transaction.update(postRef, {'commentsCount': FieldValue.increment(1)});
    });
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
        transaction.update(commentRef, {'likesCount': FieldValue.increment(-1)});
      }
    });
  }
}
