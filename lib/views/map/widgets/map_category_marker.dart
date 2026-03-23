import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MapCategoryMarker extends StatelessWidget {
  const MapCategoryMarker({
    super.key,
    required this.icon,
    required this.isSelected,
  });

  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final markerColor = isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.9);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        if (isSelected)
          Positioned(
            top: 0,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.22),
                shape: BoxShape.circle,
              ),
            ),
          ),
        Positioned(
          top: isSelected ? 3 : 6,
          child: Container(
            width: isSelected ? 36 : 30,
            height: isSelected ? 36 : 30,
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: isSelected ? 20 : 17),
          ),
        ),
        Positioned(
          top: 34,
          child: Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: isSelected ? 12 : 10,
              height: isSelected ? 12 : 10,
              decoration: BoxDecoration(
                color: markerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
