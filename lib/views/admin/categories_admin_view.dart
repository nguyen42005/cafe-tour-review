import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/category_model.dart';
import '../../view_models/category_view_model.dart';
import 'add_category_dialog.dart';
import 'widgets/categories_admin_widgets.dart';

class CategoriesAdminView extends StatelessWidget {
  const CategoriesAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CategoryViewModel>();

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
          'Quản lý Danh mục',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[100], height: 1),
        ),
      ),
      body: StreamBuilder<List<CategoryModel>>(
        stream: viewModel.categoriesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có danh mục nào',
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final categories = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryAdminItemCard(
                category: category,
                onEdit: () =>
                    _showCategoryDialog(context, viewModel, category: category),
                onDelete: () => _confirmDelete(context, viewModel, category),
                onStatusChanged: (value) =>
                    viewModel.updateCategoryStatus(category.id, value),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context, viewModel),
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Thêm mới',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context,
    CategoryViewModel viewModel, {
    CategoryModel? category,
  }) {
    showDialog(
      context: context,
      builder: (context) =>
          AddCategoryDialog(viewModel: viewModel, category: category),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CategoryViewModel viewModel,
    CategoryModel category,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => CategoryDeleteConfirmDialog(
        categoryName: category.name,
        onConfirm: () {
          Navigator.pop(dialogContext);
          viewModel.deleteCategory(category.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa danh mục "${category.name}"'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF334155),
            ),
          );
        },
      ),
    );
  }
}
