import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import 'explore_filter.dart';

class ExploreFilterChips extends StatelessWidget {
  const ExploreFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  final ExploreFilter selectedFilter;
  final ValueChanged<ExploreFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(
            label: 'Tất cả',
            icon: Icons.explore,
            value: ExploreFilter.all,
            selected: selectedFilter == ExploreFilter.all,
            onChanged: onChanged,
          ),
          _Chip(
            label: 'Quán cà phê',
            icon: Icons.local_cafe,
            value: ExploreFilter.coffee,
            selected: selectedFilter == ExploreFilter.coffee,
            onChanged: onChanged,
          ),
          _Chip(
            label: 'Du lịch',
            icon: Icons.travel_explore,
            value: ExploreFilter.travel,
            selected: selectedFilter == ExploreFilter.travel,
            onChanged: onChanged,
          ),
          _Chip(
            label: 'Đánh giá cao',
            icon: Icons.star,
            value: ExploreFilter.topRated,
            selected: selectedFilter == ExploreFilter.topRated,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final ExploreFilter value;
  final bool selected;
  final ValueChanged<ExploreFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onChanged(value),
        avatar: Icon(
          icon,
          size: 16,
          color: selected ? Colors.white : AppColors.primary,
        ),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.primary,
          ),
        ),
        selectedColor: AppColors.primary,
        showCheckmark: false,
        backgroundColor: AppColors.primary.withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide.none,
      ),
    );
  }
}

