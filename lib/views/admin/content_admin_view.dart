import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/post_model.dart';
import '../../services/post_service.dart';

class ContentAdminView extends StatefulWidget {
  const ContentAdminView({super.key});

  @override
  State<ContentAdminView> createState() => _ContentAdminViewState();
}

class _ContentAdminViewState extends State<ContentAdminView> {
  final PostService _postService = PostService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        Expanded(
          child: StreamBuilder<List<PostModel>>(
            stream: _postService.getPosts(), // Lấy toàn bộ post
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var posts = snapshot.data ?? [];
              if (_searchQuery.isNotEmpty) {
                posts = posts
                    .where(
                      (p) =>
                          p.content.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ||
                          p.userName.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();
              }

              if (posts.isEmpty) {
                return Center(
                  child: Text(
                    'Không tìm thấy bài viết nào',
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            (post.userPhotoUrl?.isNotEmpty ?? false)
                            ? NetworkImage(post.userPhotoUrl!)
                            : null,
                        child: (post.userPhotoUrl?.isEmpty ?? true)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        post.userName,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        post.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              post.isHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: post.isHidden
                                  ? Colors.orange
                                  : Colors.blue,
                            ),
                            onPressed: () => _toggleHide(post),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _deletePost(post),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Xem chi tiết
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Text(
        'Quản lý nội dung',
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo nội dung hoặc người đăng...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Future<void> _toggleHide(PostModel post) async {
    try {
      await _postService.toggleHidePost(post.id, !post.isHidden);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              post.isHidden ? 'Đã hiện bài viết' : 'Đã ẩn bài viết',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  Future<void> _deletePost(PostModel post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa bài viết này vĩnh viễn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _postService.deletePost(post.id, post.userId);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã xóa bài viết')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }
}
