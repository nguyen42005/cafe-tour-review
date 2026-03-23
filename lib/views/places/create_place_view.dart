import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../models/place_model.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';
import '../../services/place_service.dart';
import '../../core/theme/app_colors.dart';
import '../../view_models/place_view_model.dart';
import '../../view_models/auth_view_model.dart';

class CreatePlaceView extends StatefulWidget {
  const CreatePlaceView({super.key});

  @override
  State<CreatePlaceView> createState() => _CreatePlaceViewState();
}

class _CreatePlaceViewState extends State<CreatePlaceView> {
  static const LatLng _defaultMapCenter = LatLng(10.7769, 106.7009);

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceMinController = TextEditingController();
  final _priceMaxController = TextEditingController();

  String _openTime = '07:00';
  String _closeTime = '22:00';
  double? _lat;
  double? _lng;
  final MapController _mapController = MapController();
  Timer? _addressDebounce;
  bool _isSearchingAddress = false;
  final PlaceService _placeService = PlaceService();
  final CategoryService _categoryService = CategoryService();

  @override
  void dispose() {
    _addressDebounce?.cancel();
    _nameController.dispose();
    _addressController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlaceViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(viewModel),
                    _buildInputSection(context),
                    _buildAmenitiesSection(viewModel),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildActionButton(context, viewModel, authViewModel),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Thêm địa điểm mới',
            style: GoogleFonts.publicSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(PlaceViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hình ảnh',
                style: GoogleFonts.publicSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Bắt buộc',
                style: GoogleFonts.publicSans(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Main Cover
          GestureDetector(
            onTap: () => viewModel.pickCoverImage(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: viewModel.coverImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        viewModel.coverImage!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tải ảnh bìa',
                          style: GoogleFonts.publicSans(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Định dạng JPG, PNG (Tối đa 5MB)',
                          style: GoogleFonts.publicSans(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Chọn ảnh',
                            style: GoogleFonts.publicSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Sub Images
          Row(
            children: List.generate(3, (index) {
              String label = index == 0
                  ? 'Ảnh không gian'
                  : index == 1
                  ? 'Ảnh thực đơn'
                  : 'Ảnh khác';
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 2 ? 0 : 12),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => viewModel.pickSubImage(index),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                            ),
                            child: viewModel.subImages[index] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      viewModel.subImages[index]!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add,
                                    color: AppColors.primary,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: GoogleFonts.publicSans(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget _buildExistingPlaceSearchButton(BuildContext context) {
    return InkWell(
      onTap: () => _showExistingPlaceBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tìm địa điểm đã có',
                    style: GoogleFonts.publicSans(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'Tìm theo tên quán hoặc địa chỉ',
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  Widget _buildInputSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildFieldLabel('Tên quán'),
          _buildTextField(_nameController, 'Ví dụ: Cộng Cà Phê'),
          const SizedBox(height: 12),
          _buildExistingPlaceSearchButton(context),
          const SizedBox(height: 20),
          _buildFieldLabel('Địa chỉ'),
          _buildTextField(
            _addressController,
            'Nhập địa chỉ chi tiết',
            onSubmitted: (_) => _searchAddress(),
            onChanged: _onAddressChanged,
            suffix: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSearchingAddress)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    onPressed: () => _searchAddress(),
                    icon: const Icon(Icons.search, color: AppColors.primary),
                    tooltip: 'Tìm trên bản đồ',
                  ),
                IconButton(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.location_on, color: AppColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_addressController.text.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: (_lat != null && _lng != null)
                        ? LatLng(_lat!, _lng!)
                        : _defaultMapCenter,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.mobile',
                    ),
                    MarkerLayer(
                      markers: (_lat != null && _lng != null)
                          ? [
                              Marker(
                                point: LatLng(_lat!, _lng!),
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 36,
                                ),
                              ),
                            ]
                          : [
                              Marker(
                                point: _defaultMapCenter,
                                width: 32,
                                height: 32,
                                child: Icon(
                                  Icons.hourglass_top_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                            ],
                    ),
                    if (_isSearchingAddress)
                      const Align(
                        alignment: Alignment.center,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          GestureDetector(
            onTap: () => _openMapPicker(context),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Row(
                children: [
                  const Icon(Icons.map, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Chọn trên bản đồ',
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildCategorySection(context.watch<PlaceViewModel>()),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Giờ mở cửa'),
                    _buildTimePicker(
                      context,
                      _openTime,
                      (time) => setState(() => _openTime = time),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Giờ đóng cửa'),
                    _buildTimePicker(
                      context,
                      _closeTime,
                      (time) => setState(() => _closeTime = time),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFieldLabel('Khoảng giá'),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _priceMinController,
                  '30.000đ',
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('—', style: TextStyle(color: Colors.grey[400])),
              ),
              Expanded(
                child: _buildTextField(
                  _priceMaxController,
                  '100.000đ',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.publicSans(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextAlign textAlign = TextAlign.start,
    Function(String)? onSubmitted,
    ValueChanged<String>? onChanged,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      textAlign: textAlign,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      enabled: true,
      cursorColor: AppColors.primary,
      style: GoogleFonts.publicSans(
        color: const Color(0xFF1E293B),
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.publicSans(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    String value,
    Function(String) onSelected,
  ) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(value.split(':')[0]),
            minute: int.parse(value.split(':')[1]),
          ),
        );
        if (picked != null) {
          onSelected(
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: GoogleFonts.publicSans()),
            const Icon(Icons.access_time, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(PlaceViewModel viewModel) {
    return StreamBuilder<List<CategoryModel>>(
      stream: _categoryService.getCategoriesStream(),
      builder: (context, snapshot) {
        final categories = (snapshot.data ?? [])
            .where((c) => c.isActive)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Danh mục địa điểm'),
            if (categories.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  'Chưa có danh mục khả dụng',
                  style: GoogleFonts.publicSans(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  final isSelected =
                      viewModel.selectedCategoryId == category.id;
                  return ChoiceChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (_) {
                      viewModel.setCategory(category.id, category.name);
                    },
                    selectedColor: AppColors.primary.withOpacity(0.15),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                    ),
                    labelStyle: GoogleFonts.publicSans(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: Colors.white,
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildAmenitiesSection(PlaceViewModel viewModel) {
    final List<Map<String, dynamic>> amenities = [
      {'label': 'Wifi miễn phí', 'icon': Icons.wifi},
      {'label': 'Máy lạnh', 'icon': Icons.ac_unit},
      {'label': 'Bãi đỗ ô tô', 'icon': Icons.directions_car},
      {'label': 'Thanh toán thẻ', 'icon': Icons.credit_card},
      {'label': 'Làm việc', 'icon': Icons.laptop_mac},
      {'label': 'View sống ảo', 'icon': Icons.photo_camera},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiện ích (Amenities)',
            style: GoogleFonts.publicSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemCount: amenities.length,
            itemBuilder: (context, index) {
              final item = amenities[index];
              final isSelected = viewModel.selectedAmenities.contains(
                item['label'],
              );
              return GestureDetector(
                onTap: () => viewModel.toggleAmenity(item['label']),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item['icon'],
                        color: isSelected ? AppColors.primary : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['label'],
                          style: GoogleFonts.publicSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    PlaceViewModel viewModel,
    AuthViewModel authViewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withOpacity(0), Colors.white, Colors.white],
        ),
      ),
      child: ElevatedButton(
        onPressed: viewModel.isLoading
            ? null
            : () => _handleSubmit(context, viewModel, authViewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        child: viewModel.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Tạo địa điểm',
                style: GoogleFonts.publicSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _handleSubmit(
    BuildContext context,
    PlaceViewModel viewModel,
    AuthViewModel authViewModel,
  ) async {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ Tên và Địa chỉ')),
      );
      return;
    }

    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng chọn vị trí trên bản đồ hoặc lấy GPS hiện tại',
          ),
        ),
      );
      return;
    }

    final success = await viewModel.submitPlace(
      name: _nameController.text,
      address: _addressController.text,
      lat: _lat!,
      lng: _lng!,
      openTime: _openTime,
      closeTime: _closeTime,
      priceMin: _priceMinController.text,
      priceMax: _priceMaxController.text,
      categoryId: viewModel.selectedCategoryId,
      categoryName: viewModel.selectedCategoryName,
      userId: authViewModel.user?.id ?? 'unknown',
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gửi địa điểm thành công! Đang chờ Admin duyệt.'),
        ),
      );
      Navigator.pop(context);
    } else if (viewModel.duplicateFound != null) {
      _showDuplicateWarning(context, viewModel);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Có lỗi xảy ra')),
      );
    }
  }

  void _showDuplicateWarning(BuildContext context, PlaceViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phát hiện trùng lặp'),
        content: Text(
          'Có một địa điểm tương tự ("${viewModel.duplicateFound!.name}") đã tồn tại rất gần đây. Bạn có muốn sử dụng địa điểm hiện có không?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              viewModel.clearDuplicate();
              Navigator.pop(context);
            },
            child: const Text('Tiếp tục tạo mới'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logic to select existing place
              viewModel.clearDuplicate();
              Navigator.pop(context);
              // Có thể trả về ID địa điểm có sẵn
            },
            child: const Text('Dùng địa điểm sẵn có'),
          ),
        ],
      ),
    );
  }

  void _showExistingPlaceBottomSheet(BuildContext context) {
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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Column(
                    children: [
                      Text(
                        'Tìm địa điểm đã có',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                    stream: _placeService.getApprovedPlacesStream(),
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
                          child: Text(
                            'Không tìm thấy địa điểm phù hợp',
                            style: GoogleFonts.inter(color: Colors.grey[600]),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: filtered.length,
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final place = filtered[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              _applyExistingPlace(place);
                              Navigator.pop(sheetContext);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
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
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
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
                                  const Icon(
                                    Icons.location_on,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
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

  void _applyExistingPlace(PlaceModel place) {
    setState(() {
      _nameController.text = place.name;
      _addressController.text = place.address;
      _priceMinController.text = place.priceMin;
      _priceMaxController.text = place.priceMax;
      _openTime = place.openTime;
      _closeTime = place.closeTime;
    });

    context.read<PlaceViewModel>().setCategory(place.categoryId, place.categoryName);
    _updateMapPosition(place.lat, place.lng);
  }
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dịch vụ vị trí bị tắt')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền vị trí bị từ chối')),
        );
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    _updateMapPosition(position.latitude, position.longitude);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã lấy tọa độ thực tế: $_lat, $_lng')),
    );
  }

  void _onAddressChanged(String value) {
    _addressDebounce?.cancel();
    final query = value.trim();

    if (query.isEmpty) {
      setState(() {
        _lat = null;
        _lng = null;
      });
      return;
    }

    _addressDebounce = Timer(const Duration(milliseconds: 300), () {
      _searchAddress(showError: false);
    });
  }

  Future<void> _searchAddress({bool showError = true}) async {
    if (_addressController.text.trim().isEmpty) return;

    setState(() => _isSearchingAddress = true);

    try {
      List<geo.Location> locations = await geo.locationFromAddress(
        _addressController.text.trim(),
      );

      if (locations.isNotEmpty) {
        final loc = locations.first;
        _updateMapPosition(loc.latitude, loc.longitude);
      } else if (showError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy địa chỉ này')),
        );
      }
    } catch (e) {
      if (showError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tìm địa chỉ: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSearchingAddress = false);
      }
    }
  }

  void _updateMapPosition(double lat, double lng) {
    setState(() {
      _lat = lat;
      _lng = lng;
    });

    _mapController.move(LatLng(lat, lng), 15);
  }

  void _openMapPicker(BuildContext context) {
    LatLng pickedPoint = (_lat != null && _lng != null)
        ? LatLng(_lat!, _lng!)
        : _defaultMapCenter;
    final pickerController = MapController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> useCurrentLocation() async {
              final serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dịch vụ vị trí đang tắt')),
                  );
                }
                return;
              }

              var permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
              }

              if (permission == LocationPermission.denied ||
                  permission == LocationPermission.deniedForever) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không có quyền truy cập vị trí')),
                  );
                }
                return;
              }

              final position = await Geolocator.getCurrentPosition();
              final point = LatLng(position.latitude, position.longitude);
              setSheetState(() => pickedPoint = point);
              pickerController.move(point, 17);
            }

            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            'Chọn vị trí trên bản đồ',
                            style: GoogleFonts.publicSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Lấy vị trí hiện tại',
                            onPressed: useCurrentLocation,
                            icon: const Icon(
                              Icons.my_location,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FlutterMap(
                            mapController: pickerController,
                            options: MapOptions(
                              initialCenter: pickedPoint,
                              initialZoom: 16,
                              onTap: (_, point) {
                                setSheetState(() => pickedPoint = point);
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.mobile',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: pickedPoint,
                                    width: 46,
                                    height: 46,
                                    child: const Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 42,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              child: const Text('Huỷ'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _updateMapPosition(
                                  pickedPoint.latitude,
                                  pickedPoint.longitude,
                                );
                                Navigator.pop(sheetContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Đã chọn tọa độ: '
                                      ', '
                                      '',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Áp dụng vị trí'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}










