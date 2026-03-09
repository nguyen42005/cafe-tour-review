import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<String> createPost(PostModel post) async {
    try {
      final docRef = await _db.collection(_collection).add(post.toJson());
      return docRef.id;
    } catch (e) {
      print('CreatePost Error: $e');
      throw Exception('Không thể tạo bài viết');
    }
  }

  Stream<List<PostModel>> getPosts({String? userId}) {
    Query query = _db.collection(_collection).orderBy('createdAt', descending: true);

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
    Query<Map<String, dynamic>> query = _db
        .collection(_collection)
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

  // Lấy bài viết theo địa điểm, sort phía client để tránh phụ thuộc index.
  Stream<List<PostModel>> getPostsByVenue(String venueId) {
    return _db
        .collection(_collection)
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
      await _db.collection(_collection).doc(postId).update(data);
    }
  }
}
