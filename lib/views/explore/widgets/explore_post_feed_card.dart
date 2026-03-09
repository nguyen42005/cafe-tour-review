import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/place_model.dart';
import '../../../models/post_model.dart';
import '../../../core/widgets/optimized_network_image.dart';

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
  int _currentImage = 0;

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
                    _FeedActionIcon(
                      icon: Icons.favorite_border,
                      text: _formatCount(widget.post.likesCount),
                    ),
                    const SizedBox(width: 14),
                    _FeedActionIcon(
                      icon: Icons.chat_bubble_outline,
                      text: _formatCount(widget.post.commentsCount),
                    ),
                    const SizedBox(width: 14),
                    const _FeedActionIcon(icon: Icons.send, text: ''),
                    const Spacer(),
                    const Icon(Icons.bookmark_border),
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
                if (widget.post.commentsCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Xem tất cả ${widget.post.commentsCount} bình luận',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
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
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
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

class _FeedActionIcon extends StatelessWidget {
  const _FeedActionIcon({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF334155)),
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
    );
  }
}

