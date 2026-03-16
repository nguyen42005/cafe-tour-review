import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../explore/explore_view.dart';
import '../map/map_view.dart';
import '../activity/activity_view.dart';
import '../profile/profile_view.dart';
import '../posts/create_post_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ExploreView(),
    const MapView(),
    const SizedBox.shrink(), // Dummy cho nút đăng bài nổi
    const ActivityView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _pages[_currentIndex],
      // Giữa thân fab và thanh tab
      floatingActionButtonLocation: const _FixedCenterDockedFabLocation(),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 30),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.backgroundLight, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostView()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != 2) {
            // Bỏ qua index 2 (nút FAB)
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white.withOpacity(0.95),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 70, // Đủ chiều cao cho tab icon
      notchMargin: 8.0,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(icon: Icons.explore, label: 'Khám phá', index: 0),
          _buildNavItem(icon: Icons.map, label: 'Bản đồ', index: 1),
          const SizedBox(width: 48), // Khoảng trống cho FAB
          _buildNavItem(
            icon: Icons.notifications_none,
            label: 'Hoạt động',
            index: 3,
          ),
          _buildNavItem(icon: Icons.person, label: 'Cá nhân', index: 4),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : Colors.grey[400]!;

    return InkWell(
      onTap: () => onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FixedCenterDockedFabLocation extends FloatingActionButtonLocation {
  const _FixedCenterDockedFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX =
        (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2.0;
    final double contentBottom = scaffoldGeometry.contentBottom;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
    final double fabY = contentBottom - fabHeight / 2.0;
    return Offset(fabX, fabY);
  }
}
