import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_dialog.dart';
import '../../../core/widgets/optimized_network_image.dart';
import '../../../models/place_model.dart';
import '../../../models/post_comment_model.dart';
import '../../../models/post_model.dart';
import '../../../services/post_service.dart';
import '../../../services/user_service.dart';

class ExplorePostFeedCard extends StatefulWidget {
  const ExplorePostFeedCard({
    super.key,
    required this.post,
    required this.place,
    required this.onOpenPlace,
  });

  final PostModel post;
  final PlaceModel? place;
  final VoidCallback? onOpenPlace;

  @override
  State<ExplorePostFeedCard> createState() => _ExplorePostFeedCardState();
}

class _ExplorePostFeedCardState extends State<ExplorePostFeedCard> {
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  int _currentImage = 0;
  bool _isLiked = false;
  bool _isSaved = false;
  bool _isLikeLoading = false;
  bool _isSaveLoading = false;
  int _likesCount = 0;
  int _commentsCount = 0;

  @override
  void initState() {
    super.initState();
    _syncFromPost();
    _loadInteractionStates();
  }

  @override
  void didUpdateWidget(covariant ExplorePostFeedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id ||
        oldWidget.post.likesCount != widget.post.likesCount ||
        oldWidget.post.commentsCount != widget.post.commentsCount) {
      _syncFromPost();
      _loadInteractionStates();
    }
  }

  void _syncFromPost() {
    _likesCount = widget.post.likesCount;
    _commentsCount = widget.post.commentsCount;
    _currentImage = 0;
  }

  Future<void> _loadInteractionStates() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final liked = await _postService.isPostLikedByUser(widget.post.id, uid);
      final saved = await _userService.isPostSaved(uid, widget.post.id);
      if (!mounted) return;
      setState(() {
        _isLiked = liked;
        _isSaved = saved;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final imageList = widget.post.images.isNotEmpty
        ? widget.post.images
        : ((widget.place?.coverImage ?? '').isNotEmpty
              ? [widget.place!.coverImage]
              : <String>[]);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.16),
                  backgroundImage: (widget.post.userPhotoUrl ?? '').isNotEmpty
                      ? NetworkImage(widget.post.userPhotoUrl!)
                      : null,
                  child: (widget.post.userPhotoUrl ?? '').isEmpty
                      ? const Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              _shortLocation(widget.place?.address ?? widget.post.venueName),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.onOpenPlace != null)
                        InkWell(
                          onTap: widget.onOpenPlace,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_cafe,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Xem quán: ${widget.post.venueName}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                _PostImageCarousel(
                  images: imageList,
                  onPageChanged: (index) => setState(() => _currentImage = index),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          widget.post.rating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (imageList.length > 1)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_currentImage + 1}/${imageList.length}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (imageList.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageList.length, (index) {
                  final selected = index == _currentImage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: selected ? 14 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.grey[300],
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _FeedActionIconButton(
                      icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                      iconColor: _isLiked ? Colors.red : const Color(0xFF334155),
                      text: _formatCount(_likesCount),
                      onTap: _isLikeLoading ? null : _toggleLike,
                    ),
                    const SizedBox(width: 14),
                    _FeedActionIconButton(
                      icon: Icons.chat_bubble_outline,
                      text: _formatCount(_commentsCount),
                      onTap: () => _openCommentsSheet(context),
                    ),
                    const SizedBox(width: 14),
                    _FeedActionIconButton(
                      icon: Icons.send,
                      text: '',
                      onTap: () => CustomDialog.showInfo(
                        context,
                        title: 'Thông tin',
                        message: 'Tính năng chia sẻ sẽ được cập nhật sớm.',
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _isSaveLoading ? null : _toggleSave,
                      icon: Icon(
                        _isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: _isSaved ? AppColors.primary : const Color(0xFF334155),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: widget.onOpenPlace,
                  child: Text(
                    widget.post.venueName,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF475569),
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(
                        text: '${widget.post.userName} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      TextSpan(text: widget.post.content),
                    ],
                  ),
                ),
                if (_commentsCount > 0)
                  InkWell(
                    onTap: () => _openCommentsSheet(context),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Xem tất cả $_commentsCount bình luận',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      await CustomDialog.showInfo(
        context,
        title: 'Yêu cầu đăng nhập',
        message: 'Vui lòng đăng nhập để thả tim bài viết.',
      );
      return;
    }

    final next = !_isLiked;
    setState(() {
      _isLikeLoading = true;
      _isLiked = next;
      _likesCount += next ? 1 : -1;
      if (_likesCount < 0) _likesCount = 0;
    });

    try {
      await _postService.togglePostLike(
        postId: widget.post.id,
        userId: uid,
        shouldLike: next,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLiked = !next;
        _likesCount += next ? -1 : 1;
      });
      await CustomDialog.showError(
        context,
        title: 'Không thể thả tim',
        message: 'Có lỗi xảy ra: $e',
      );
    } finally {
      if (mounted) setState(() => _isLikeLoading = false);
    }
  }

  Future<void> _toggleSave() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      await CustomDialog.showInfo(
        context,
        title: 'Yêu cầu đăng nhập',
        message: 'Vui lòng đăng nhập để lưu bài viết.',
      );
      return;
    }

    final next = !_isSaved;
    setState(() {
      _isSaveLoading = true;
      _isSaved = next;
    });

    try {
      await _userService.toggleSavedPost(uid, widget.post.id, next);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaved = !next);
      await CustomDialog.showError(
        context,
        title: 'Không thể lưu bài viết',
        message: 'Có lỗi xảy ra: $e',
      );
    } finally {
      if (mounted) setState(() => _isSaveLoading = false);
    }
  }

  Future<void> _openCommentsSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        postId: widget.post.id,
        postService: _postService,
        onCommentAdded: () {
          if (mounted) setState(() => _commentsCount += 1);
        },
      ),
    );
  }

  static String _shortLocation(String location) {
    if (location.trim().isEmpty) return 'Địa điểm chưa cập nhật';
    final parts = location
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts[parts.length - 2]}, ${parts.last}';
    }
    return parts.first;
  }

  static String _formatCount(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toString();
  }
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({
    required this.postId,
    required this.postService,
    required this.onCommentAdded,
  });

  final String postId;
  final PostService postService;
  final VoidCallback onCommentAdded;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final Map<String, bool> _likedState = {};
  final Map<String, int> _likesOverride = {};
  final Set<String> _likeLoading = {};

  bool _isSending = false;
  PostCommentModel? _replyTo;

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        padding: EdgeInsets.only(bottom: bottom),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Bình luận',
                    style: GoogleFonts.inter(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<PostCommentModel>>(
                stream: widget.postService.getCommentsStream(widget.postId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  final comments = snapshot.data ?? [];
                  _ensureLikeStates(comments);

                  final root = comments.where((c) => c.parentId.isEmpty).toList();
                  final repliesMap = <String, List<PostCommentModel>>{};
                  for (final c in comments.where((x) => x.parentId.isNotEmpty)) {
                    repliesMap.putIfAbsent(c.parentId, () => []).add(c);
                  }

                  if (root.isEmpty) {
                    return Center(
                      child: Text(
                        'Chưa có bình luận nào',
                        style: GoogleFonts.inter(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
                    itemCount: root.length,
                    itemBuilder: (context, index) {
                      final comment = root[index];
                      final replies = repliesMap[comment.id] ?? const [];
                      return _CommentThreadTile(
                        comment: comment,
                        replies: replies,
                        isLiked: _likedState[comment.id] ?? false,
                        likesCount: _likesOverride[comment.id] ?? comment.likesCount,
                        isLikeLoading: _likeLoading.contains(comment.id),
                        onLike: () => _toggleCommentLike(comment),
                        onReply: () {
                          setState(() => _replyTo = comment);
                          _focusNode.requestFocus();
                        },
                        replyLikeResolver: (reply) => _likedState[reply.id] ?? false,
                        replyCountResolver: (reply) => _likesOverride[reply.id] ?? reply.likesCount,
                        replyLoadingResolver: (reply) => _likeLoading.contains(reply.id),
                        onLikeReply: (reply) => _toggleCommentLike(reply),
                        onReplyReply: (reply) {
                          setState(() => _replyTo = reply);
                          _focusNode.requestFocus();
                        },
                      );
                    },
                  );
                },
              ),
            ),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyTo != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Đang trả lời ${_replyTo!.userName}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _replyTo = null),
                    child: const Icon(Icons.close, size: 16, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: _replyTo == null
                        ? 'Viết bình luận...'
                        : 'Trả lời ${_replyTo!.userName}...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _isSending ? null : _sendComment,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _ensureLikeStates(List<PostCommentModel> comments) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final missing = comments.where((c) => !_likedState.containsKey(c.id)).map((c) => c.id).toList();
    if (missing.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (final id in missing) {
        try {
          final liked = await widget.postService.isCommentLikedByUser(widget.postId, id, uid);
          if (!mounted) return;
          setState(() => _likedState[id] = liked);
        } catch (_) {
          if (!mounted) return;
          setState(() => _likedState[id] = false);
        }
      }
    });
  }

  Future<void> _toggleCommentLike(PostCommentModel comment) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      await CustomDialog.showInfo(
        context,
        title: 'Yêu cầu đăng nhập',
        message: 'Vui lòng đăng nhập để thả tim bình luận.',
      );
      return;
    }

    if (_likeLoading.contains(comment.id)) return;

    final currentLike = _likedState[comment.id] ?? false;
    final next = !currentLike;
    final currentCount = _likesOverride[comment.id] ?? comment.likesCount;

    setState(() {
      _likeLoading.add(comment.id);
      _likedState[comment.id] = next;
      _likesOverride[comment.id] = (currentCount + (next ? 1 : -1)).clamp(0, 999999999);
    });

    try {
      await widget.postService.toggleCommentLike(
        postId: widget.postId,
        commentId: comment.id,
        userId: uid,
        shouldLike: next,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _likedState[comment.id] = currentLike;
        _likesOverride[comment.id] = currentCount;
      });
      await CustomDialog.showError(
        context,
        title: 'Không thể thả tim',
        message: 'Có lỗi xảy ra: $e',
      );
    } finally {
      if (mounted) setState(() => _likeLoading.remove(comment.id));
    }
  }

  Future<void> _sendComment() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final content = _commentController.text.trim();

    if (uid == null || firebaseUser == null) {
      await CustomDialog.showInfo(
        context,
        title: 'Yêu cầu đăng nhập',
        message: 'Vui lòng đăng nhập để bình luận.',
      );
      return;
    }

    if (content.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final comment = PostCommentModel(
        id: '',
        userId: uid,
        userName: firebaseUser.displayName?.trim().isNotEmpty == true
            ? firebaseUser.displayName!.trim()
            : 'Người dùng',
        userPhotoUrl: firebaseUser.photoURL ?? '',
        content: content,
        parentId: _replyTo?.id ?? '',
        likesCount: 0,
        createdAt: DateTime.now(),
      );

      await widget.postService.addComment(postId: widget.postId, comment: comment);
      _commentController.clear();
      _focusNode.unfocus();
      widget.onCommentAdded();
      if (mounted) setState(() => _replyTo = null);
    } catch (e) {
      if (!mounted) return;
      await CustomDialog.showError(
        context,
        title: 'Không thể gửi bình luận',
        message: 'Có lỗi xảy ra: $e',
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}

class _CommentThreadTile extends StatelessWidget {
  const _CommentThreadTile({
    required this.comment,
    required this.replies,
    required this.isLiked,
    required this.likesCount,
    required this.isLikeLoading,
    required this.onLike,
    required this.onReply,
    required this.replyLikeResolver,
    required this.replyCountResolver,
    required this.replyLoadingResolver,
    required this.onLikeReply,
    required this.onReplyReply,
  });

  final PostCommentModel comment;
  final List<PostCommentModel> replies;
  final bool isLiked;
  final int likesCount;
  final bool isLikeLoading;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final bool Function(PostCommentModel) replyLikeResolver;
  final int Function(PostCommentModel) replyCountResolver;
  final bool Function(PostCommentModel) replyLoadingResolver;
  final ValueChanged<PostCommentModel> onLikeReply;
  final ValueChanged<PostCommentModel> onReplyReply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommentBubble(
            comment: comment,
            isLiked: isLiked,
            likesCount: likesCount,
            isLikeLoading: isLikeLoading,
            onLike: onLike,
            onReply: onReply,
            compact: false,
          ),
          if (replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 8),
              child: Column(
                children: replies
                    .map(
                      (reply) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _CommentBubble(
                          comment: reply,
                          isLiked: replyLikeResolver(reply),
                          likesCount: replyCountResolver(reply),
                          isLikeLoading: replyLoadingResolver(reply),
                          onLike: () => onLikeReply(reply),
                          onReply: () => onReplyReply(reply),
                          compact: true,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  const _CommentBubble({
    required this.comment,
    required this.isLiked,
    required this.likesCount,
    required this.isLikeLoading,
    required this.onLike,
    required this.onReply,
    required this.compact,
  });

  final PostCommentModel comment;
  final bool isLiked;
  final int likesCount;
  final bool isLikeLoading;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: compact ? 14 : 17,
          backgroundColor: AppColors.primary.withOpacity(0.15),
          backgroundImage: comment.userPhotoUrl.isNotEmpty
              ? NetworkImage(comment.userPhotoUrl)
              : null,
          child: comment.userPhotoUrl.isEmpty
              ? Icon(Icons.person, size: compact ? 14 : 16)
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: compact ? const Color(0xFFF1F5F9) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.userName,
                        style: GoogleFonts.inter(
                          fontSize: compact ? 11.5 : 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _ago(comment.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: GoogleFonts.inter(fontSize: compact ? 12 : 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    InkWell(
                      onTap: isLikeLoading ? null : onLike,
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: isLiked ? Colors.red : Colors.grey[600],
                          ),
                          if (likesCount > 0) ...[
                            const SizedBox(width: 3),
                            Text(
                              likesCount.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: onReply,
                      child: Text(
                        'Trả lời',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _ago(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes}p';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }
}

class _PostImageCarousel extends StatelessWidget {
  const _PostImageCarousel({required this.images, required this.onPageChanged});

  final List<String> images;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        color: AppColors.primary.withOpacity(0.08),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.primary,
          size: 40,
        ),
      );
    }

    return PageView.builder(
      itemCount: images.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return OptimizedNetworkImage(
          url: images[index],
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          placeholder: Container(
            color: AppColors.primary.withOpacity(0.08),
            alignment: Alignment.center,
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.primary,
              size: 40,
            ),
          ),
        );
      },
    );
  }
}

class _FeedActionIconButton extends StatelessWidget {
  const _FeedActionIconButton({
    required this.icon,
    required this.text,
    required this.onTap,
    this.iconColor = const Color(0xFF334155),
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            if (text.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
