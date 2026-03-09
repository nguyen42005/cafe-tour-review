import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_dialog.dart';
import '../../models/place_model.dart';
import '../../models/post_model.dart';
import '../../services/place_service.dart';
import '../../services/post_service.dart';
import '../places/place_detail_view.dart';
import 'widgets/explore_filter.dart';
import 'widgets/explore_filter_chips.dart';
import 'widgets/explore_post_feed_card.dart';
import 'widgets/explore_search_bar.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  static const int _pageSize = 10;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final PlaceService _placeService = PlaceService();
  final PostService _postService = PostService();

  ExploreFilter _selectedFilter = ExploreFilter.all;

  final List<PostModel> _posts = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;

  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadInitialPosts() async {
    setState(() {
      _posts.clear();
      _lastDoc = null;
      _hasMore = true;
      _error = null;
      _isInitialLoading = true;
      _isLoadingMore = false;
    });

    await _fetchNextPage();

    if (mounted) {
      setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _fetchNextPage() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    try {
      final result = await _postService.getPostsPage(
        lastDocument: _lastDoc,
        limit: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _posts.addAll(result.posts);
        _lastDoc = result.lastDocument;
        _hasMore = result.hasMore;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Không thể tải bài viết: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 280) {
      _fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            ExploreSearchBar(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              onTapNotification: () async {
                await CustomDialog.showInfo(
                  context,
                  title: 'Thông báo',
                  message: 'Bạn chưa có thông báo mới',
                );
              },
            ),
            ExploreFilterChips(
              selectedFilter: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value);
              },
            ),
            Expanded(
              child: StreamBuilder<List<PlaceModel>>(
                stream: _placeService.getApprovedPlacesStream(),
                builder: (context, placeSnapshot) {
                  if (placeSnapshot.hasError) {
                    return _MessageView(
                      text: 'Lỗi tải danh sách địa điểm: ${placeSnapshot.error}',
                      color: Colors.red[400],
                    );
                  }

                  final places = placeSnapshot.data ?? [];
                  final placesById = {for (final place in places) place.id: place};

                  if (_isInitialLoading && _posts.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (_error != null && _posts.isEmpty) {
                    return _RetryView(text: _error!, onRetry: _loadInitialPosts);
                  }

                  final filteredPosts = _posts.where((post) {
                    final place = placesById[post.venueId];
                    return _matchSearch(post, place) && _matchFilter(post, place);
                  }).toList();

                  if (filteredPosts.length < 4 && _hasMore && !_isLoadingMore) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _fetchNextPage();
                    });
                  }

                  if (filteredPosts.isEmpty) {
                    return _MessageView(
                      text: _posts.isEmpty
                          ? 'Chưa có bài viết nào trong cộng đồng'
                          : 'Không có bài viết phù hợp bộ lọc',
                      color: Colors.grey[600],
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                    itemCount: filteredPosts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == filteredPosts.length) {
                        return _FeedFooter(
                          isLoading: _isLoadingMore,
                          hasMore: _hasMore,
                          error: _error,
                          onRetry: _fetchNextPage,
                        );
                      }

                      final post = filteredPosts[index];
                      final place = placesById[post.venueId];

                      return ExplorePostFeedCard(
                        post: post,
                        place: place,
                        onOpenPlace: place == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlaceDetailView(place: place),
                                  ),
                                );
                              },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchSearch(PostModel post, PlaceModel? place) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return true;

    final fields = [
      post.userName,
      post.content,
      post.venueName,
      place?.name ?? '',
      place?.address ?? '',
      place?.categoryName ?? '',
    ];

    return fields.any((value) => value.toLowerCase().contains(query));
  }

  bool _matchFilter(PostModel post, PlaceModel? place) {
    switch (_selectedFilter) {
      case ExploreFilter.all:
        return true;
      case ExploreFilter.coffee:
        final haystack =
            '${post.venueName} ${place?.categoryName ?? ''} ${post.content}'
                .toLowerCase();
        return haystack.contains('coffee') ||
            haystack.contains('cà phê') ||
            haystack.contains('cafe');
      case ExploreFilter.travel:
        final haystack = '${post.content} ${place?.categoryName ?? ''}'.toLowerCase();
        return haystack.contains('du lịch') ||
            haystack.contains('travel') ||
            haystack.contains('trip') ||
            haystack.contains('khám phá');
      case ExploreFilter.topRated:
        return post.rating >= 4.5;
    }
  }
}

class _FeedFooter extends StatelessWidget {
  const _FeedFooter({
    required this.isLoading,
    required this.hasMore,
    required this.error,
    required this.onRetry,
  });

  final bool isLoading;
  final bool hasMore;
  final String? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (error != null && hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: TextButton(
            onPressed: onRetry,
            child: const Text('Tải thêm thất bại. Nhấn để thử lại'),
          ),
        ),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            'Bạn đã xem hết bài viết',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.text, required this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: color),
        ),
      ),
    );
  }
}

class _RetryView extends StatelessWidget {
  const _RetryView({required this.text, required this.onRetry});

  final String text;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.red[400]),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}


