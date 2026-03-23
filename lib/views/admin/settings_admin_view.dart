import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class SettingsAdminView extends StatefulWidget {
  const SettingsAdminView({super.key});

  @override
  State<SettingsAdminView> createState() => _SettingsAdminViewState();
}

class _SettingsAdminViewState extends State<SettingsAdminView> {
  bool _maintenanceMode = false;
  bool _allowGuestBrowsing = true;
  bool _autoApprovePlaces = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildSectionTitle('Cấu hình hệ thống'),
              _buildSwitchTile(
                'Chế độ bảo trì',
                'Khi bật, người dùng sẽ không thể truy cập ứng dụng.',
                _maintenanceMode,
                (val) => setState(() => _maintenanceMode = val),
              ),
              _buildSwitchTile(
                'Cho phép khách duyệt',
                'Cho phép người dùng chưa đăng nhập xem bài viết và địa điểm.',
                _allowGuestBrowsing,
                (val) => setState(() => _allowGuestBrowsing = val),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Quản lý nội dung'),
              _buildSwitchTile(
                'Tự động phê duyệt địa điểm',
                'Địa điểm mới sẽ được duyệt tự động mà không cần Admin kiểm tra.',
                _autoApprovePlaces,
                (val) => setState(() => _autoApprovePlaces = val),
              ),
              const SizedBox(height: 48),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã lưu cài đặt')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Lưu thay đổi'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Text(
            'Cài đặt hệ thống',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
