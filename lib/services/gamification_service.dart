class GamificationService {
  // EXP Rewards
  static const int expPostReview = 50;
  static const int expVisitPlace = 20;
  static const int expReceiveLike = 5;
  static const int expReceiveComment = 10;
  static const int expGainFollower = 15;

  // Title Thresholds
  static const Map<int, String> titles = {
    0: 'Tân Binh',
    200: 'Người Khám Phá',
    500: 'Chuyên Gia Cà Phê',
    1000: 'Bậc Thầy Review',
    2000: 'Huyền Thoại Cafe',
  };

  static String getTitleForExp(int exp) {
    String currentTitle = 'Tân Binh';
    final sortedThresholds = titles.keys.toList()..sort();

    for (var threshold in sortedThresholds) {
      if (exp >= threshold) {
        currentTitle = titles[threshold]!;
      } else {
        break;
      }
    }
    return currentTitle;
  }

  static double getProgressToNextLevel(int currentExp) {
    final sortedThresholds = titles.keys.toList()..sort();
    int? nextThreshold;

    for (var threshold in sortedThresholds) {
      if (threshold > currentExp) {
        nextThreshold = threshold;
        break;
      }
    }

    if (nextThreshold == null) return 1.0; // Max level

    int currentLevelBase = 0;
    for (var i = sortedThresholds.length - 1; i >= 0; i--) {
      if (sortedThresholds[i] <= currentExp) {
        currentLevelBase = sortedThresholds[i];
        break;
      }
    }

    return (currentExp - currentLevelBase) / (nextThreshold - currentLevelBase);
  }

  static int getNextThreshold(int currentExp) {
    final sortedThresholds = titles.keys.toList()..sort();
    for (var threshold in sortedThresholds) {
      if (threshold > currentExp) {
        return threshold;
      }
    }
    return currentExp; // Maxed out
  }

  // Badge Logic
  static List<Map<String, dynamic>> getAllBadges(
    int posts,
    int followers,
    int places,
  ) {
    return [
      {
        'id': 'reviewer_bronze',
        'name': 'Reviewer Đồng',
        'description': 'Đã đăng 5 bài viết',
        'icon': 'stars',
        'isUnlocked': posts >= 5,
      },
      {
        'id': 'reviewer_silver',
        'name': 'Reviewer Bạc',
        'description': 'Đã đăng 15 bài viết',
        'icon': 'military_tech',
        'isUnlocked': posts >= 15,
      },
      {
        'id': 'reviewer_gold',
        'name': 'Reviewer Vàng',
        'description': 'Đã đăng 30 bài viết',
        'icon': 'workspace_premium',
        'isUnlocked': posts >= 30,
      },
      {
        'id': 'social_star',
        'name': 'Ngôi Sao Club',
        'description': 'Đạt 50 người theo dõi',
        'icon': 'person_add',
        'isUnlocked': followers >= 50,
      },
      {
        'id': 'explorer',
        'name': 'Nhà Thám Hiểm',
        'description': 'Đã đi 10 địa điểm',
        'icon': 'explore',
        'isUnlocked': places >= 10,
      },
    ];
  }
}
