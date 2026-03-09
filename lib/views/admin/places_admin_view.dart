import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../models/place_model.dart';
import '../../services/place_service.dart';
import 'widgets/places_admin_widgets.dart';

class PlacesAdminView extends StatelessWidget {
  const PlacesAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final placeService = PlaceService();

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
          'Phê duyệt địa điểm',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<PlaceModel>>(
        stream: placeService.getPendingPlacesStream(),
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
                    placeService.updatePlaceStatus(place.id, 'rejected'),
                onApprove: () =>
                    placeService.updatePlaceStatus(place.id, 'approved'),
              );
            },
          );
        },
      ),
    );
  }
}
