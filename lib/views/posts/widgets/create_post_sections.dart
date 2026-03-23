import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class CreatePostSectionHeader extends StatelessWidget {
  const CreatePostSectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF0F172A),
      ),
    );
  }
}

class CreatePostLocationButton extends StatelessWidget {
  const CreatePostLocationButton({
    super.key,
    required this.venueName,
    required this.hasSelectedVenue,
    required this.onTap,
  });

  final String venueName;
  final bool hasSelectedVenue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venueName,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    hasSelectedVenue
                        ? 'Điểm này đã được chọn'
                        : 'Tìm kiếm quán bạn đã ghé qua',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class CreatePostPhotoGallery extends StatelessWidget {
  const CreatePostPhotoGallery({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  final List<File> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return InkWell(
              onTap: onAdd,
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_a_photo,
                      color: AppColors.primary,
                      size: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thêm ảnh',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final file = images[index - 1];
          return Stack(
            children: [
              Container(
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: FileImage(file),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () => onRemove(index - 1),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CreatePostRatingCard extends StatelessWidget {
  const CreatePostRatingCard({
    super.key,
    required this.rating,
    required this.onRate,
  });

  final double rating;
  final ValueChanged<double> onRate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            'Đánh giá của bạn',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1.0;
              final isFilled = rating >= starValue;
              return IconButton(
                onPressed: () => onRate(starValue),
                icon: Icon(
                  isFilled ? Icons.star : Icons.star_border,
                  color: isFilled
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.3),
                  size: 36,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            _getRatingText(rating),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText(double value) {
    if (value >= 5) return 'Tuyệt vời (5/5)';
    if (value >= 4) return 'Tốt (4/5)';
    if (value >= 3) return 'Bình thường (3/5)';
    if (value >= 2) return 'Tạm được (2/5)';
    return 'Kém (1/5)';
  }
}

class CreatePostContentSection extends StatelessWidget {
  const CreatePostContentSection({
    super.key,
    required this.controller,
    required this.contentLength,
    required this.onChanged,
  });

  final TextEditingController controller;
  final int contentLength;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CreatePostSectionHeader('Nội dung bài viết'),
        const SizedBox(height: 12),
        Stack(
          children: [
            TextField(
              controller: controller,
              maxLines: 6,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Chia sẻ trải nghiệm của bạn về quán này...',
                hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Text(
                '$contentLength / 1000',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: const [
            CreatePostHashTag('#caphe'),
            CreatePostHashTag('#review'),
            CreatePostHashTag('#saigon'),
          ],
        ),
      ],
    );
  }
}

class CreatePostHashTag extends StatelessWidget {
  const CreatePostHashTag(this.tag, {super.key});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Text(
      tag,
      style: GoogleFonts.inter(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}

class CreatePostSubmitBar extends StatelessWidget {
  const CreatePostSubmitBar({
    super.key,
    required this.isLoading,
    required this.enabled,
    required this.onSubmit,
  });

  final bool isLoading;
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: ElevatedButton(
        onPressed: (!enabled || isLoading) ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Đăng bài',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
