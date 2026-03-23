import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/post_model.dart';
import '../../models/place_model.dart';
import '../../services/place_service.dart';
import '../../view_models/create_post_view_model.dart';
import '../../view_models/profile_view_model.dart';
import '../places/create_place_view.dart';
import 'widgets/create_post_sections.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key, this.initialPost});

  final PostModel? initialPost;

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.initialPost?.content ?? '';

    // Khởi tạo viewModel trong post-frame hoặc dùng logic init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<CreatePostViewModel>();
      if (widget.initialPost != null) {
        viewModel.initForEdit(widget.initialPost!);
      } else {
        viewModel.reset();
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreatePostViewModel>();
    final profileViewModel = context.watch<ProfileViewModel>();
    final user = profileViewModel.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          viewModel.isEditing ? 'Chỉnh sửa bài đăng' : 'Tạo bài đăng mới',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CreatePostSectionHeader('Chọn địa điểm'),
              const SizedBox(height: 12),
              CreatePostLocationButton(
                venueName: viewModel.selectedVenueName,
                hasSelectedVenue: viewModel.selectedVenueId.isNotEmpty,
                onTap: () => _showPlaceSelectionBottomSheet(context, viewModel),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CreatePostSectionHeader('Hình ảnh quán'),
                  Text(
                    'Tối đa 5 ảnh',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CreatePostPhotoGallery(
                images: viewModel.selectedImages,
                onAdd: viewModel.pickImages,
                onRemove: viewModel.removeImage,
              ),
              const SizedBox(height: 32),
              CreatePostRatingCard(
                rating: viewModel.rating,
                onRate: viewModel.setRating,
              ),
              const SizedBox(height: 32),
              CreatePostContentSection(
                controller: _contentController,
                contentLength: viewModel.content.length,
                onChanged: viewModel.setContent,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomSheet: CreatePostSubmitBar(
        isLoading: viewModel.isLoading,
        enabled: user != null && viewModel.selectedVenueId.isNotEmpty,
        onSubmit: () async {
          if (user == null) return;
          if (viewModel.selectedVenueId.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vui lòng chọn địa điểm trước khi đăng bài'),
                ),
              );
            }
            return;
          }

          final success = await viewModel.submitPost(user);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  viewModel.isEditing
                      ? 'Cập nhật bài viết thành công!'
                      : 'Đăng bài thành công!',
                ),
              ),
            );
            Navigator.pop(context);
          } else if (mounted && viewModel.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
          }
        },
      ),
    );
  }

  void _showPlaceSelectionBottomSheet(
    BuildContext context,
    CreatePostViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        String searchQuery = '';

        return StatefulBuilder(
          builder: (context, setSheetState) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Chọn quán cà phê',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreatePlaceView(),
                                ),
                              );
                            },
                            child: Text(
                              '+ Thêm quán mới',
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (value) {
                          setSheetState(
                            () => searchQuery = value.trim().toLowerCase(),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Tìm tên quán hoặc địa chỉ...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<PlaceModel>>(
                    stream: PlaceService().getApprovedPlacesStream(),
                    builder: (context, snapshot) {
                      final places = snapshot.data ?? [];
                      final filtered = searchQuery.isEmpty
                          ? places
                          : places.where((place) {
                              final name = place.name.toLowerCase();
                              final address = place.address.toLowerCase();
                              return name.contains(searchQuery) ||
                                  address.contains(searchQuery);
                            }).toList();

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Không tìm thấy quán phù hợp',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(sheetContext);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreatePlaceView(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.add_location_alt_outlined,
                                ),
                                label: const Text('Thêm quán mới'),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: filtered.length,
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final place = filtered[index];
                          return _PlaceListItem(
                            place: place,
                            isSelected: viewModel.selectedVenueId == place.id,
                            onTap: () {
                              viewModel.setVenue(place.id, place.name);
                              Navigator.pop(sheetContext);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlaceListItem extends StatelessWidget {
  const _PlaceListItem({
    required this.place,
    required this.isSelected,
    required this.onTap,
  });

  final PlaceModel place;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                place.coverImage,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 52,
                  height: 52,
                  color: AppColors.primary.withOpacity(0.1),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    place.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.location_on,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
