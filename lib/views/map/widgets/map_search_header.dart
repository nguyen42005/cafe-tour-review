import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'round_map_action_button.dart';

class MapSearchHeader extends StatelessWidget {
  const MapSearchHeader({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onTapSearch,
    required this.onTapFilter,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onTapSearch;
  final VoidCallback onTapFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight.withOpacity(0.95),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Tìm quán cà phê & điểm đến',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
                  onPressed: onTapSearch,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        RoundMapActionButton(icon: Icons.tune, onTap: onTapFilter),
      ],
    );
  }
}
