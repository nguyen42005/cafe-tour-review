import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_dialog.dart';
import '../../services/auth_service.dart';
import '../../view_models/profile_view_model.dart';
import '../admin/dashboard_admin_view.dart';
import '../auth/login_view.dart';
import 'widgets/profile_sections.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    if (viewModel.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFBFBFB),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final user = viewModel.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFBFBFB),
        body: Center(
          child: Text(
            'Không tải được thông tin cá nhân. Vui lòng đăng nhập lại.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: Text(
          'Cá nhân',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFFBFBFB),
        elevation: 0,
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.primary,
              ),
              onPressed: () => _showSettingsMenu(context, viewModel),
            ),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildAvatarSection(context, viewModel),
                    const SizedBox(height: 16),
                    ProfileUserInfoSection(user: user),
                    const SizedBox(height: 24),
                    ProfileStatsRow(user: user),
                    const SizedBox(height: 32),
                    const ProfileBadgesSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: ProfileTabHeaderDelegate(
                  TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey[500],
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(text: 'Bài của tôi'),
                      Tab(text: 'Lịch sử'),
                      Tab(text: 'Đã lưu'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: const TabBarView(
            children: [
              ProfilePhotoGrid(),
              Center(child: Text('Lịch sử di chuyển')),
              Center(child: Text('Bài viết đã lưu')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context, ProfileViewModel viewModel) {
    final photoUrl = viewModel.currentUser?.photoUrl ?? '';
    final ImageProvider? avatarImage = photoUrl.isNotEmpty
        ? NetworkImage(photoUrl)
        : null;

    return Stack(
      children: [
        GestureDetector(
          onTap: () async {
            final ImageSource? source = await showModalBottomSheet<ImageSource>(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (bottomSheetContext) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        leading: const Icon(Icons.camera_alt_outlined),
                        title: const Text('Chụp ảnh mới'),
                        onTap: () => Navigator.pop(
                          bottomSheetContext,
                          ImageSource.camera,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library_outlined),
                        title: const Text('Chọn từ Thư viện'),
                        onTap: () => Navigator.pop(
                          bottomSheetContext,
                          ImageSource.gallery,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );

            if (source == null) return;

            final success = await viewModel.uploadAvatar(source: source);
            if (success && context.mounted) {
              await CustomDialog.showSuccess(
                context,
                title: 'Thành công',
                message: 'Cập nhật Ảnh đại diện thành công!',
              );
            } else if (viewModel.errorMessage != null && context.mounted) {
              await CustomDialog.showError(
                context,
                title: 'Thất bại',
                message: viewModel.errorMessage!,
              );
            }
          },
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 3,
              ),
              image: avatarImage != null
                  ? DecorationImage(image: avatarImage, fit: BoxFit.cover)
                  : null,
            ),
            child: viewModel.isUploading
                ? Container(
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : (avatarImage == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primary,
                        )
                      : null),
          ),
        ),
        const Positioned(bottom: 0, right: 4, child: _AvatarCameraBadge()),
      ],
    );
  }

  void _showSettingsMenu(BuildContext context, ProfileViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Chỉnh sửa thông tin'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showEditProfileDialog(context, viewModel);
                },
              ),
              if (viewModel.currentUser?.role == 'admin')
                ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Bảng điều khiển (Admin)',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardAdminView(),
                      ),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Đổi mật khẩu'),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginView(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    ProfileViewModel viewModel,
  ) {
    final TextEditingController nameController = TextEditingController(
      text: viewModel.currentUser?.displayName,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Chỉnh sửa thông tin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên hiển thị',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text;
                if (newName.isEmpty) return;

                Navigator.pop(dialogContext);
                final success = await viewModel.updateDisplayName(newName);
                if (success && context.mounted) {
                  await CustomDialog.showSuccess(
                    context,
                    title: 'Thành công',
                    message: 'Đổi tên thành công!',
                  );
                } else if (viewModel.errorMessage != null && context.mounted) {
                  await CustomDialog.showError(
                    context,
                    title: 'Thất bại',
                    message: viewModel.errorMessage!,
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }
}

class _AvatarCameraBadge extends StatelessWidget {
  const _AvatarCameraBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 24),
    );
  }
}



