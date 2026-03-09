import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onTapNotification,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onTapNotification;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm quán cà phê hoặc nội dung...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ),
          IconButton(
            onPressed: onTapNotification,
            icon: const Icon(Icons.notifications_none, color: AppColors.primary),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
