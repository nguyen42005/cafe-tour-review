import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../models/category_model.dart';
import '../../view_models/category_view_model.dart';
import 'widgets/add_category_widgets.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key, required this.viewModel, this.category});

  final CategoryViewModel viewModel;
  final CategoryModel? category;

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  final _sortOrderController = TextEditingController();
  bool _isActive = true;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'coffee', 'icon': Icons.coffee_rounded},
    {'name': 'restaurant', 'icon': Icons.restaurant_rounded},
    {'name': 'local_cafe', 'icon': Icons.local_cafe_rounded},
    {'name': 'bakery_dining', 'icon': Icons.bakery_dining_rounded},
    {'name': 'icecream', 'icon': Icons.icecream_rounded},
    {'name': 'beach', 'icon': Icons.beach_access_rounded},
    {'name': 'forest', 'icon': Icons.forest_rounded},
    {'name': 'mountain', 'icon': Icons.terrain_rounded},
    {'name': 'nature', 'icon': Icons.nature_people_rounded},
    {'name': 'hotel', 'icon': Icons.hotel_rounded},
    {'name': 'map', 'icon': Icons.map_rounded},
    {'name': 'explore', 'icon': Icons.explore_rounded},
    {'name': 'camera', 'icon': Icons.camera_alt_rounded},
    {'name': 'favorite', 'icon': Icons.favorite_rounded},
    {'name': 'star', 'icon': Icons.star_rounded},
    {'name': 'pets', 'icon': Icons.pets_rounded},
    {'name': 'event', 'icon': Icons.event_rounded},
    {'name': 'shopping', 'icon': Icons.shopping_bag_rounded},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _iconController.text = widget.category!.icon;
      _sortOrderController.text = widget.category!.sortOrder.toString();
      _isActive = widget.category!.isActive;
    } else {
      _sortOrderController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final icon = _iconController.text.trim();
    final sortOrder = int.tryParse(_sortOrderController.text.trim()) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên danh mục')),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đang xử lý...')));
    Navigator.pop(context);

    if (widget.category == null) {
      await widget.viewModel.addCategory(name, icon, sortOrder, _isActive);
    } else {
      await widget.viewModel.updateCategory(
        widget.category!.id,
        name,
        icon,
        sortOrder,
        _isActive,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.category == null
                          ? Icons.add_box_rounded
                          : Icons.edit_note_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.category == null
                        ? 'Thêm Danh mục'
                        : 'Cập nhật Danh mục',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CategoryDialogTextField(
                      controller: _nameController,
                      label: 'Tên danh mục',
                      hint: 'Nhập tên danh mục (vd: Cà phê, Nhà hàng...)',
                      icon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 20),
                    CategoryDialogTextField(
                      controller: _iconController,
                      label: 'Tên Icon (Sẽ tự cập nhật khi chọn bên dưới)',
                      hint: 'vd: coffee, restaurant, beach...',
                      icon: Icons.emoji_emotions_outlined,
                    ),
                    const SizedBox(height: 12),
                    CategoryIconPickerGrid(
                      availableIcons: _availableIcons,
                      selectedIconName: _iconController.text,
                      onSelected: (name) =>
                          setState(() => _iconController.text = name),
                    ),
                    const SizedBox(height: 20),
                    CategoryDialogTextField(
                      controller: _sortOrderController,
                      label: 'Thứ tự sắp xếp',
                      hint: 'Nhập số để sắp xếp vị trí',
                      icon: Icons.sort_rounded,
                      isNumber: true,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _isActive
                            ? AppColors.primary.withOpacity(0.03)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isActive
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.grey[200]!,
                        ),
                      ),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        title: Text(
                          'Trạng thái hoạt động',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _isActive
                                ? const Color(0xFF0F172A)
                                : Colors.grey[500],
                          ),
                        ),
                        value: _isActive,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        'Hủy bỏ',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        widget.category == null ? 'Xác nhận' : 'Lưu thay đổi',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
