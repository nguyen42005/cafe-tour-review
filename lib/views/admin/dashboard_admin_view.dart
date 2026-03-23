import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../view_models/profile_view_model.dart';
import '../../view_models/admin_dashboard_view_model.dart';
import 'categories_admin_view.dart';
import 'user_admin_view.dart';
import 'places_admin_view.dart';
import 'reports_admin_view.dart';
import 'content_admin_view.dart';
import 'notifications_admin_view.dart';
import 'settings_admin_view.dart';
import 'widgets/dashboard_admin_widgets.dart';
// import '../main/main_view.dart'; // Bỏ qua nếu không cần logout ở đây

class DashboardAdminView extends StatefulWidget {
  const DashboardAdminView({super.key});

  @override
  State<DashboardAdminView> createState() => _DashboardAdminViewState();
}

class _DashboardAdminViewState extends State<DashboardAdminView> {
  int _selectedIndex = 0;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      context.read<AdminDashboardViewModel>().loadDashboardData();
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F7F6),
          drawer: isDesktop ? null : _buildSidebar(isDesktop: false),
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
                  title: Text(
                    'CafeTravel Admin',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1F2937),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          body: Row(
            children: [
              if (isDesktop) _buildSidebar(isDesktop: true),
              Expanded(
                child: Column(
                  children: [
                    if (isDesktop) _buildTopBar(),
                    Expanded(child: _getBody(constraints)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebar({required bool isDesktop}) {
    final viewModel = context.watch<ProfileViewModel>();
    final user = viewModel.currentUser;

    final sidebar = Container(
      width: 256,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_cafe, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CafeTravel',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Cổng quản trị',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(0, Icons.dashboard_outlined, 'Tổng quan'),
                _buildNavItem(1, Icons.category_outlined, 'Danh mục'),
                _buildNavItem(2, Icons.location_on_outlined, 'Địa điểm'),
                _buildNavItem(3, Icons.article_outlined, 'Nội dung'),
                _buildNavItem(4, Icons.group_outlined, 'Người dùng'),
                _buildNavItem(5, Icons.report_outlined, 'Báo cáo'),
                _buildNavItem(
                  6,
                  Icons.notifications_none_outlined,
                  'Thông báo',
                ),
                _buildNavItem(7, Icons.settings_outlined, 'Cài đặt'),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  backgroundImage: user?.photoUrl.isNotEmpty == true
                      ? NetworkImage(user!.photoUrl)
                      : null,
                  child: user?.photoUrl.isEmpty ?? true
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Admin',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Quản trị viên',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.grey, size: 20),
                  onPressed: () {
                    // Thay vì logout hẳn, chỉ back về là đủ (do dev testing)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Container(
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey[200]!)),
        ),
        child: sidebar,
      );
    } else {
      return Drawer(child: sidebar);
    }
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap();
        } else {
          setState(() => _selectedIndex = index);
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? const Border(
                  right: BorderSide(color: AppColors.primary, width: 4),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey[500],
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                color: isSelected ? AppColors.primary : const Color(0xFF1F2937),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final viewModel = context.watch<ProfileViewModel>();
    final user = viewModel.currentUser;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm đánh giá, địa điểm...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {},
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.grey),
                onPressed: () {},
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Chào mừng trở lại,',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    user?.displayName ?? 'Admin',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getBody(BoxConstraints constraints) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardHome(constraints);
      case 1:
        return const CategoriesAdminView();
      case 2:
        return const PlacesAdminView();
      case 3:
        return const ContentAdminView();
      case 4:
        return const UserAdminView();
      case 5:
        return const ReportsAdminView();
      case 6:
        return const NotificationsAdminView();
      case 7:
        return const SettingsAdminView();
      default:
        return _buildDashboardHome(constraints);
    }
  }

  Widget _buildDashboardHome(BoxConstraints constraints) {
    final adminVM = context.watch<AdminDashboardViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, gridConstraints) {
              int crossAxisCount = 1;
              if (gridConstraints.maxWidth > 1000)
                crossAxisCount = 4;
              else if (gridConstraints.maxWidth > 600)
                crossAxisCount = 2;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: gridConstraints.maxWidth > 600 ? 1.3 : 2.0,
                children: [
                  _buildStatCard(
                    'Người dùng',
                    adminVM.totalUsers.toString(),
                    'Tổng số',
                    Icons.person,
                    Colors.green,
                    Colors.green[50]!,
                    const Color(0xFFE8F5E9),
                  ),
                  _buildStatCard(
                    'Tổng bài đăng',
                    adminVM.totalPosts.toString(),
                    'Toàn hệ thống',
                    Icons.rate_review,
                    Colors.blue,
                    Colors.blue[50]!,
                    const Color(0xFFE3F2FD),
                  ),
                  _buildStatCard(
                    'Địa điểm',
                    adminVM.totalPlaces.toString(),
                    'Đã đăng ký',
                    Icons.storefront,
                    Colors.orange,
                    Colors.orange[50]!,
                    const Color(0xFFFFF3E0),
                  ),
                  _buildStatCard(
                    'Báo cáo chờ',
                    adminVM.pendingReports.toString(),
                    'Cần xử lý',
                    Icons.report_problem,
                    Colors.red,
                    Colors.red[50]!,
                    const Color(0xFFFFEBEE),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, lowerConstraints) {
              if (lowerConstraints.maxWidth > 1000) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildRecentActivity()),
                    const SizedBox(width: 32),
                    Expanded(flex: 1, child: _buildGamificationStats()),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildRecentActivity(),
                    const SizedBox(height: 32),
                    _buildGamificationStats(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String trend,
    IconData icon,
    Color iconColor,
    Color iconBgColor,
    Color trendBgColor,
  ) {
    return DashboardStatCardWidget(
      title: title,
      value: value,
      trend: trend,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      trendBgColor: trendBgColor,
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hoạt động gần đây',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Xem tất cả',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildActivityItem(
            avatarUrl:
                'https://ui-avatars.com/api/?name=Alex+Chen&background=random',
            titleText: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF1F2937),
                ),
                children: const [
                  TextSpan(
                    text: 'Alex Chen',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' posted a review of '),
                  TextSpan(
                    text: 'The Coffee House',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            time: '2 minutes ago',
            trailing: Row(
              children: List.generate(
                5,
                (_) => const Icon(Icons.star, color: Colors.amber, size: 16),
              ),
            ),
          ),
          const Divider(height: 1),
          _buildActivityItem(
            icon: Icons.add_location_alt,
            iconColor: Colors.orange,
            iconBg: Colors.orange[50]!,
            titleText: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF1F2937),
                ),
                children: const [
                  TextSpan(text: 'New venue '),
                  TextSpan(
                    text: "'Mountain View Cafe'",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' added'),
                ],
              ),
            ),
            time: '15 minutes ago',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ĐANG CHỜ',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          _buildActivityItem(
            avatarUrl:
                'https://ui-avatars.com/api/?name=Linh+Nguyen&background=random',
            titleText: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF1F2937),
                ),
                children: const [
                  TextSpan(
                    text: 'Linh Nguyen',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' joined the community'),
                ],
              ),
            ),
            time: '45 minutes ago',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'MỚI',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          _buildActivityItem(
            icon: Icons.report_outlined,
            iconColor: Colors.blue,
            iconBg: Colors.blue[50]!,
            titleText: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF1F2937),
                ),
                children: const [
                  TextSpan(text: 'Review on '),
                  TextSpan(
                    text: 'Urban Roast',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' reported'),
                ],
              ),
            ),
            time: '1 hour ago',
            trailing: Text(
              'REVIEW',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    String? avatarUrl,
    IconData? icon,
    Color? iconColor,
    Color? iconBg,
    required Widget titleText,
    required String time,
    required Widget trailing,
  }) {
    return DashboardActivityItemWidget(
      avatarUrl: avatarUrl,
      icon: icon,
      iconColor: iconColor,
      iconBg: iconBg,
      titleText: titleText,
      time: time,
      trailing: trailing,
    );
  }

  Widget _buildGamificationStats() {
    final adminVM = context.watch<AdminDashboardViewModel>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top người đóng góp',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Bảng xếp hạng tuần này',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HUY HIỆU THỊNH HÀNH',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBadgeItem(
                      Icons.emoji_events,
                      'Elite Reviewer',
                      Colors.yellow[700]!,
                      Colors.yellow[100]!,
                    ),
                    _buildBadgeItem(
                      Icons.explore,
                      'City Explorer',
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.1),
                    ),
                    _buildBadgeItem(
                      Icons.camera_alt,
                      'Photogenic',
                      Colors.purple,
                      Colors.purple[100]!,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'TOP TÀI KHOẢN',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (adminVM.topContributors.isEmpty)
                  Center(
                    child: Text(
                      'Chưa có dữ liệu',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  ...adminVM.topContributors.map(
                    (u) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildTopUser(
                        u['photoUrl'].isNotEmpty
                            ? u['photoUrl']
                            : 'https://ui-avatars.com/api/?name=${u['displayName']}&background=random',
                        u['displayName'],
                        '${u['exp']} EXP',
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Mục tiêu cộng đồng',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.75,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '75% hoàn thành 1,000 review hàng tháng',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(
    IconData icon,
    String title,
    Color color,
    Color bgColor,
  ) {
    return DashboardBadgeItemWidget(
      icon: icon,
      title: title,
      color: color,
      bgColor: bgColor,
    );
  }

  Widget _buildTopUser(String avatar, String name, String pts) {
    return DashboardTopUserWidget(avatar: avatar, name: name, pts: pts);
  }
}
