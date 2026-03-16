import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../models/place_model.dart';
import '../../services/place_service.dart';
import 'widgets/places_admin_widgets.dart';

class PlacesAdminView extends StatefulWidget {
  const PlacesAdminView({super.key});

  @override
  State<PlacesAdminView> createState() => _PlacesAdminViewState();
}

class _PlacesAdminViewState extends State<PlacesAdminView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PlaceService _placeService = PlaceService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Quản lý địa điểm',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Chờ duyệt'),
            Tab(text: 'Tất cả'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPendingList(), _buildAllPlacesList()],
      ),
    );
  }

  Widget _buildPendingList() {
    return StreamBuilder<List<PlaceModel>>(
      stream: _placeService.getPendingPlacesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Lỗi tải danh sách chờ duyệt: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.red[400]),
              ),
            ),
          );
        }

        final places = snapshot.data ?? [];

        if (places.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Không có yêu cầu chờ duyệt nào',
                  style: GoogleFonts.inter(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return PendingPlaceCard(
              place: place,
              onReject: () =>
                  _placeService.updatePlaceStatus(place.id, 'rejected'),
              onApprove: () =>
                  _placeService.updatePlaceStatus(place.id, 'approved'),
            );
          },
        );
      },
    );
  }

  Widget _buildAllPlacesList() {
    return StreamBuilder<List<PlaceModel>>(
      stream: _placeService.getApprovedPlacesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final places = snapshot.data ?? [];
        if (places.isEmpty) {
          return const Center(child: Text('Chưa có địa điểm nào được duyệt'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    place.coverImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                title: Text(
                  place.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  place.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  // Xem chi tiết hoặc sửa
                },
              ),
            );
          },
        );
      },
    );
  }
}
