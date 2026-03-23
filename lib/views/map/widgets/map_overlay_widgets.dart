import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/place_model.dart';
import 'map_preview_card.dart';
import 'map_search_header.dart';
import 'result_badge.dart';
import 'round_map_action_button.dart';

class MapHeaderOverlay extends StatelessWidget {
  const MapHeaderOverlay({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onTapSearch,
    required this.onTapFilter,
    required this.resultCount,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onTapSearch;
  final VoidCallback onTapFilter;
  final int resultCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: MapSearchHeader(
            controller: controller,
            onSubmitted: onSubmitted,
            onTapSearch: onTapSearch,
            onTapFilter: onTapFilter,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 16),
            child: ResultBadge(count: resultCount),
          ),
        ),
      ],
    );
  }
}

class MapFloatingActions extends StatelessWidget {
  const MapFloatingActions({
    super.key,
    required this.isLocating,
    required this.onTapLayers,
    required this.onTapLocation,
  });

  final bool isLocating;
  final VoidCallback onTapLayers;
  final VoidCallback onTapLocation;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 280,
      child: Column(
        children: [
          RoundMapActionButton(icon: Icons.layers_outlined, onTap: onTapLayers),
          const SizedBox(height: 10),
          RoundMapActionButton(
            icon: isLocating ? Icons.gps_fixed : Icons.my_location,
            onTap: onTapLocation,
          ),
        ],
      ),
    );
  }
}

class MapPreviewOverlay extends StatelessWidget {
  const MapPreviewOverlay({
    super.key,
    required this.visible,
    required this.place,
    required this.onOpenDetail,
    required this.onDirections,
    required this.onCheckIn,
  });

  final bool visible;
  final PlaceModel? place;
  final VoidCallback onOpenDetail;
  final VoidCallback onDirections;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    if (!visible || place == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 86,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: MapPreviewCard(
          place: place,
          onOpenDetail: onOpenDetail,
          onDirections: onDirections,
          onCheckIn: onCheckIn,
        ),
      ),
    );
  }
}

class MapLoadingOverlay extends StatelessWidget {
  const MapLoadingOverlay({super.key, required this.show});

  final bool show;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    return const Positioned(
      top: 88,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.4,
          ),
        ),
      ),
    );
  }
}
