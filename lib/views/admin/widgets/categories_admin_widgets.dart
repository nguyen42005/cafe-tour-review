import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/category_model.dart';

IconData getCategoryIconData(String iconName) {
  switch (iconName.toLowerCase()) {
    case 'coffee':
      return Icons.coffee_rounded;
    case 'restaurant':
      return Icons.restaurant_rounded;
    case 'local_cafe':
      return Icons.local_cafe_rounded;
    case 'bakery_dining':
      return Icons.bakery_dining_rounded;
    case 'icecream':
      return Icons.icecream_rounded;
    case 'beach':
      return Icons.beach_access_rounded;
    case 'forest':
      return Icons.forest_rounded;
    case 'mountain':
      return Icons.terrain_rounded;
    case 'nature':
      return Icons.nature_people_rounded;
    case 'hotel':
      return Icons.hotel_rounded;
    case 'map':
      return Icons.map_rounded;
    case 'explore':
      return Icons.explore_rounded;
    case 'camera':
      return Icons.camera_alt_rounded;
    case 'favorite':
      return Icons.favorite_rounded;
    case 'star':
      return Icons.star_rounded;
    case 'pets':
      return Icons.pets_rounded;
    case 'event':
      return Icons.event_rounded;
    case 'shopping':
      return Icons.shopping_bag_rounded;
    default:
      return Icons.category_rounded;
  }
}

class CategoryAdminItemCard extends StatelessWidget {
  const CategoryAdminItemCard({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });

  final CategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                color: category.isActive ? AppColors.primary : Colors.grey[300],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: category.isActive
                              ? AppColors.primary.withOpacity(0.08)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          getCategoryIconData(category.icon),
                          color: category.isActive
                              ? AppColors.primary
                              : Colors.grey[400],
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Text(
                                    'STT: ${category.sortOrder}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category.isActive
                                      ? 'Đang hoạt động'
                                      : 'Tạm ngắt',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: category.isActive
                                        ? Colors.green[600]
                                        : Colors.grey[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_note_rounded,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: onEdit,
                                tooltip: 'Chỉnh sửa',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_sweep_rounded,
                                  color: Colors.redAccent,
                                ),
                                onPressed: onDelete,
                                tooltip: 'Xóa',
                              ),
                            ],
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: category.isActive,
                              activeColor: AppColors.primary,
                              onChanged: onStatusChanged,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryDeleteConfirmDialog extends StatelessWidget {
  const CategoryDeleteConfirmDialog({
    super.key,
    required this.categoryName,
    required this.onConfirm,
  });

  final String categoryName;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Xác nhận xóa',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn có chắc chắn muốn xóa danh mục "$categoryName" không? Hành động này không thể hoàn tác.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onConfirm,
                    child: Text(
                      'Xóa bỏ',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
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
