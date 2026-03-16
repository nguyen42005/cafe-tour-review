import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../models/post_model.dart';
import '../../../services/gamification_service.dart';
import '../../posts/post_detail_view.dart';

class ProfileUserInfoSection extends StatelessWidget {
  const ProfileUserInfoSection({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final double progress = GamificationService.getProgressToNextLevel(
      user.exp,
    );
    final int nextThreshold = GamificationService.getNextThreshold(user.exp);

    return Column(
      children: [
        Text(
          user.displayName.isEmpty ? 'Chưa cập nhật tên' : user.displayName,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.workspace_premium,
                color: AppColors.primary,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                user.title.isEmpty ? 'Tân Binh' : user.title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${user.exp} EXP',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    '$nextThreshold EXP',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ProfileStatCard(
            label: 'Người theo\ndõi',
            value: _formatNumber(user.followers),
          ),
          ProfileStatCard(
            label: 'Đã đi',
            value: _formatNumber(user.placesVisited),
          ),
          ProfileStatCard(
            label: 'Bài đăng',
            value: _formatNumber(user.postsCount),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

class ProfileStatCard extends StatelessWidget {
  const ProfileStatCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[400],
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileBadgesSection extends StatelessWidget {
  const ProfileBadgesSection({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final badges = GamificationService.getAllBadges(
      user.postsCount,
      user.followers,
      user.placesVisited,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Huy hiệu đạt được',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                'Xem tất cả',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, index) {
              final badge = badges[index];
              final bool isUnlocked = badge['isUnlocked'] as bool;

              return SizedBox(
                width: 80,
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.grey[200],
                        shape: BoxShape.circle,
                        border: isUnlocked
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Icon(
                        _getIconData(badge['icon'] as String),
                        color: isUnlocked
                            ? AppColors.primary
                            : Colors.grey[400],
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      badge['name'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: isUnlocked
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isUnlocked
                            ? const Color(0xFF334155)
                            : Colors.grey[500],
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'stars':
        return Icons.stars;
      case 'military_tech':
        return Icons.military_tech;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'person_add':
        return Icons.person_add;
      case 'explore':
        return Icons.explore;
      default:
        return Icons.help_outline;
    }
  }
}

class ProfilePhotoGrid extends StatelessWidget {
  const ProfilePhotoGrid({super.key, required this.posts});

  final List<PostModel> posts;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa có bài viết nào',
                      style: GoogleFonts.inter(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailView(post: post),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(color: Colors.grey[100]),
            child: post.images.isNotEmpty
                ? Image.network(
                    post.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.image_outlined, color: Colors.grey),
                  ),
          ),
        );
      },
    );
  }
}

class ProfileTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  ProfileTabHeaderDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFFFBFBFB), child: tabBar);
  }

  @override
  bool shouldRebuild(ProfileTabHeaderDelegate oldDelegate) => false;
}
