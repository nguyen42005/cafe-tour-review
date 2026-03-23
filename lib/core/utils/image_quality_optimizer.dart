class ImageQualityOptimizer {
  static const int _minPx = 480;
  static const int _maxPx = 4096;

  static int normalizePx(double logicalSize, double dpr) {
    final px = (logicalSize * dpr).round();
    if (px < _minPx) return _minPx;
    if (px > _maxPx) return _maxPx;
    return px;
  }

  static bool isCloudinaryUrl(String url) {
    return url.contains('res.cloudinary.com') && url.contains('/image/upload/');
  }

  static String buildBestUrl(
    String originalUrl, {
    required int targetWidthPx,
    int? targetHeightPx,
  }) {
    if (!isCloudinaryUrl(originalUrl)) return originalUrl;

    final transforms = <String>[
      'f_auto',
      'q_auto:best',
      'dpr_auto',
      'e_sharpen:100',
      'c_limit',
      'w_$targetWidthPx',
    ];

    if (targetHeightPx != null && targetHeightPx > 0) {
      transforms.add('h_$targetHeightPx');
    }

    final block = transforms.join(',');
    return originalUrl.replaceFirst('/upload/', '/upload/$block/');
  }
}
