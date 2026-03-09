import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';

class UserAdminSearchField extends StatelessWidget {
  const UserAdminSearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm tên hoặc email...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
          ),
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class UserAdminCard extends StatelessWidget {
  const UserAdminCard({
    super.key,
    required this.user,
    required this.onToggleRole,
    required this.onBlock,
  });

  final UserModel user;
  final VoidCallback onToggleRole;
  final VoidCallback onBlock;

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == 'admin';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: user.photoUrl.isNotEmpty
                  ? NetworkImage(user.photoUrl)
                  : null,
              child: user.photoUrl.isEmpty
                  ? const Icon(Icons.person, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    user.email,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isAdmin
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAdmin ? 'ADMINISTRATOR' : 'USER',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isAdmin ? AppColors.primary : Colors.blue,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
              onSelected: (val) {
                if (val == 'role') {
                  onToggleRole();
                } else if (val == 'block') {
                  onBlock();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'role',
                  child: Row(
                    children: [
                      Icon(
                        isAdmin
                            ? Icons.person_outline
                            : Icons.admin_panel_settings_outlined,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(isAdmin ? 'Thay đổi sang User' : 'Nâng cấp Admin'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(Icons.block_flipped, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text(
                        'Khóa tài khoản',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
