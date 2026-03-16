import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../view_models/user_admin_view_model.dart';
import 'widgets/users_admin_widgets.dart';

class UserAdminView extends StatefulWidget {
  const UserAdminView({super.key});

  @override
  State<UserAdminView> createState() => _UserAdminViewState();
}

class _UserAdminViewState extends State<UserAdminView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserAdminViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quản lý Người dùng',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: UserAdminSearchField(
            onChanged: (val) =>
                setState(() => _searchQuery = val.toLowerCase()),
          ),
        ),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: viewModel.usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Đã có lỗi: ${snapshot.error}'));
          }

          var users = snapshot.data ?? [];
          if (_searchQuery.isNotEmpty) {
            users = users
                .where(
                  (u) =>
                      u.displayName.toLowerCase().contains(_searchQuery) ||
                      u.email.toLowerCase().contains(_searchQuery),
                )
                .toList();
          }

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy người dùng nào',
                    style: GoogleFonts.inter(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserAdminCard(
                user: user,
                onToggleRole: () => _toggleRole(context, user, viewModel),
                onBlock: () => _toggleBlock(context, user, viewModel),
              );
            },
          );
        },
      ),
    );
  }

  void _toggleRole(
    BuildContext context,
    UserModel user,
    UserAdminViewModel viewModel,
  ) {
    final newRole = user.role == 'admin' ? 'user' : 'admin';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận vai trò'),
        content: Text(
          'Bạn có chắc chắn muốn chuyển "${user.displayName}" thành $newRole?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.updateUserRole(user.id, newRole);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật vai trò thành công'),
                  ),
                );
              }
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  void _toggleBlock(
    BuildContext context,
    UserModel user,
    UserAdminViewModel viewModel,
  ) {
    final isBlocked = user.isBlocked;
    final action = isBlocked ? 'mở khóa' : 'khóa';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận $action'),
        content: Text(
          'Bạn có chắc chắn muốn $action tài khoản "${user.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.toggleBlock(user.id, !isBlocked);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã ${isBlocked ? "mở khóa" : "khóa"} người dùng thành công',
                    ),
                  ),
                );
              }
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }
}
