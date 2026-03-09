import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_dialog.dart';
import '../../models/place_model.dart';
import '../../models/post_model.dart';
import '../../services/post_service.dart';
import '../../services/user_service.dart';
import '../../view_models/create_post_view_model.dart';
import '../posts/create_post_view.dart';
import 'widgets/place_detail_components.dart';

class PlaceDetailView extends StatefulWidget {
  final PlaceModel place;

  const PlaceDetailView({super.key, required this.place});

  @override
  State<PlaceDetailView> createState() => _PlaceDetailViewState();
}

class _PlaceDetailViewState extends State<PlaceDetailView> {
  static const double _heroHeight = 520;
  static const double _overlap = 92;

  final PageController _pageController = PageController();
  final UserService _userService = UserService();
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _isBookmarkLoading = false;

  List<String> get _images {
    final items = <String>[];
    if (widget.place.coverImage.isNotEmpty) items.add(widget.place.coverImage);
    items.addAll(widget.place.subImages.where((e) => e.isNotEmpty));
    return items.isEmpty ? [''] : items;
  }

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedState() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final isSaved = await _userService.isPlaceSaved(uid, widget.place.id);
    if (!mounted) return;
    setState(() => _isFavorite = isSaved);
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = _isOpenNow(widget.place.openTime, widget.place.closeTime);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: _heroHeight,
                  width: double.infinity,
                  child: PlaceImageSliderSection(
                    images: _images,
                    controller: _pageController,
                    currentIndex: _currentImageIndex,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -_overlap),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 18,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PlaceHeaderBlock(
                            name: widget.place.name,
                            isOpen: isOpen,
                            metaText:
                                '• 240m • ${widget.place.categoryName.isEmpty ? 'Quán Cà Phê' : widget.place.categoryName}',
                          ),
                          const SizedBox(height: 18),
                          _buildActionGrid(),
                          const SizedBox(height: 28),
                          _buildDetailInfo(),
                          const SizedBox(height: 28),
                          _buildAmenities(),
                          const SizedBox(height: 28),
                          _buildReviews(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildTopOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopOverlay() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x66000000), Color(0x00000000)],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GlassCircleIconButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
            Row(
              children: [
                GlassCircleIconButton(
                  icon: Icons.share,
                  onTap: _sharePlace,
                ),
                const SizedBox(width: 8),
                GlassCircleIconButton(
                  icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                  onTap: _isBookmarkLoading ? () {} : _toggleSavePlace,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid() {
    return Row(
      children: [
        Expanded(
          child: PlaceActionButton(
            icon: Icons.location_on,
            label: 'Check-in',
            onTap: _handleCheckIn,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PlaceActionButton(
            icon: _isFavorite ? Icons.bookmark_added : Icons.bookmark,
            label: _isFavorite ? 'Đã lưu' : 'Lưu',
            onTap: _isBookmarkLoading ? () {} : _toggleSavePlace,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PlaceActionButton(
            icon: Icons.directions,
            label: 'Chỉ đường',
            highlighted: true,
            onTap: _openDirections,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailInfo() {
    return Column(
      children: [
        PlaceInfoRow(icon: Icons.map_outlined, title: widget.place.address),
        const SizedBox(height: 16),
        PlaceInfoRow(
          icon: Icons.schedule,
          title: '${widget.place.openTime} - ${widget.place.closeTime}',
          subtitle: 'Giờ cao điểm: 18:00 - 20:00',
        ),
        const SizedBox(height: 16),
        PlaceInfoRow(
          icon: Icons.payments,
          title: '${widget.place.priceMin} - ${widget.place.priceMax}',
        ),
      ],
    );
  }

  Widget _buildAmenities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PlaceSectionHeader(title: 'Tiện ích'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.place.amenities
              .map((e) => AmenityChip(label: e))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlaceSectionHeader(
          title: 'Bài viết cộng đồng',
          actionLabel: 'Xem tất cả',
          onActionTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đang hiển thị 6 bài viết mới nhất')),
            );
          },
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<PostModel>>(
          stream: PostService().getPostsByVenue(widget.place.id),
          builder: (context, snapshot) {
            final posts = snapshot.data ?? [];

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            if (posts.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  'Chưa có bài viết đánh giá nào cho địa điểm này',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }

            return Column(
              children: posts
                  .take(6)
                  .map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ReviewCard(
                        post: post,
                        timeAgo: _timeAgo(post.createdAt),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _sharePlace() async {
    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${widget.place.lat},${widget.place.lng}';
    final shareText =
        'Check quán ${widget.place.name}\n${widget.place.address}\n$mapsUrl';

    await Clipboard.setData(ClipboardData(text: shareText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép thông tin địa điểm để chia sẻ')),
    );
  }

  void _handleCheckIn() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để check-in')),
      );
      return;
    }

    final createPostVm = context.read<CreatePostViewModel>();
    createPostVm.setVenue(widget.place.id, widget.place.name);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostView()),
    );
  }

  Future<void> _toggleSavePlace() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để lưu địa điểm')),
      );
      return;
    }

    setState(() => _isBookmarkLoading = true);
    try {
      final next = !_isFavorite;
      await _userService.toggleSavedPlace(uid, widget.place.id, next);
      if (!mounted) return;
      setState(() => _isFavorite = next);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(next ? 'Đã lưu địa điểm' : 'Đã bỏ lưu địa điểm'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu địa điểm thất bại: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isBookmarkLoading = false);
      }
    }
  }

  Future<void> _openDirections() async {
    final lat = widget.place.lat;
    final lng = widget.place.lng;

    final appUri = Uri.parse(
      'comgooglemaps://?daddr=$lat,$lng&directionsmode=driving',
    );
    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không mở được Google Maps trên thiết bị này'),
        ),
      );
    }
  }

  bool _isOpenNow(String open, String close) {
    try {
      final now = TimeOfDay.now();
      final openParts = open.split(':');
      final closeParts = close.split(':');
      final openMinutes = int.parse(openParts[0]) * 60 + int.parse(openParts[1]);
      final closeMinutes =
          int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);
      final nowMinutes = now.hour * 60 + now.minute;

      if (closeMinutes < openMinutes) {
        return nowMinutes >= openMinutes || nowMinutes <= closeMinutes;
      }
      return nowMinutes >= openMinutes && nowMinutes <= closeMinutes;
    } catch (_) {
      return true;
    }
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${(diff.inDays / 7).floor()} tuần trước';
  }
}


