import 'package:flutter/material.dart';

import '../utils/image_quality_optimizer.dart';

class OptimizedNetworkImage extends StatefulWidget {
  const OptimizedNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  @override
  State<OptimizedNetworkImage> createState() => _OptimizedNetworkImageState();
}

class _OptimizedNetworkImageState extends State<OptimizedNetworkImage> {
  late List<String> _candidates;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _candidates = [widget.url];
  }

  @override
  void didUpdateWidget(covariant OptimizedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _selectedIndex = 0;
      _candidates = [widget.url];
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.of(context).devicePixelRatio;

        final logicalWidth = _resolveLogicalSize(
          preferred: widget.width,
          constrained: constraints.maxWidth,
          fallback: MediaQuery.of(context).size.width,
        );

        final logicalHeight = _resolveLogicalSize(
          preferred: widget.height,
          constrained: constraints.maxHeight,
          fallback: logicalWidth,
        );

        final targetWidthPx = ImageQualityOptimizer.normalizePx(logicalWidth, dpr);
        final targetHeightPx = ImageQualityOptimizer.normalizePx(logicalHeight, dpr);

        final best = ImageQualityOptimizer.buildBestUrl(
          widget.url,
          targetWidthPx: targetWidthPx,
          targetHeightPx: targetHeightPx,
        );

        _candidates = best == widget.url ? [widget.url] : [best, widget.url];

        final image = Image.network(
          _candidates[_selectedIndex],
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          gaplessPlayback: true,
          cacheWidth: targetWidthPx,
          cacheHeight: targetHeightPx,
          errorBuilder: (_, __, ___) {
            if (_selectedIndex < _candidates.length - 1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _selectedIndex++);
              });
            }
            return widget.placeholder ??
                Container(
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined),
                );
          },
        );

        if (widget.borderRadius != null) {
          return ClipRRect(borderRadius: widget.borderRadius!, child: image);
        }
        return image;
      },
    );
  }

  double _resolveLogicalSize({
    required double? preferred,
    required double constrained,
    required double fallback,
  }) {
    if (preferred != null && preferred.isFinite && preferred > 0) {
      return preferred;
    }
    if (constrained.isFinite && constrained > 0) {
      return constrained;
    }
    return fallback;
  }
}
