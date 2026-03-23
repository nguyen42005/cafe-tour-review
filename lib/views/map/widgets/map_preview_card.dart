import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/place_model.dart';

class MapPreviewCard extends StatelessWidget {
  const MapPreviewCard({
    super.key,
    required this.place,
    required this.onOpenDetail,
    required this.onDirections,
    required this.onCheckIn,
  });

  final PlaceModel? place;
  final VoidCallback onOpenDetail;
  final VoidCallback onDirections;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    if (place == null) {
      return const SizedBox.shrink();
    }

    final p = place!;

    return GestureDetector(
      onTap: onOpenDetail,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: p.coverImage.isNotEmpty
                  ? Image.network(
                      p.coverImage,
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) => _imageFallback(),
                    )
                  : _imageFallback(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, color: AppColors.primary, size: 16),
                      const SizedBox(width: 2),
                      const Text(
                        '4.8',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${p.categoryName.isEmpty ? 'Quán cà phê' : p.categoryName} • ${p.openTime} - ${p.closeTime}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDirections,
                          icon: const Icon(Icons.directions, size: 16),
                          label: const Text('Chỉ đường'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onCheckIn,
                          icon: const Icon(Icons.check_circle, size: 16),
                          label: const Text('Nhận chỗ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 92,
      height: 92,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: const Icon(Icons.local_cafe, color: AppColors.primary),
    );
  }
}
