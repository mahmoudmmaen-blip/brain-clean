/// Brain Clean gamification levels based on cumulative BCS points.
enum BrainLevel {
  level1(threshold: 0, emoji: '🌱', nameAr: 'مبتدئ الوعي', nameEn: 'Awareness Beginner'),
  level2(
    threshold: 100,
    emoji: '🎯',
    nameAr: 'متحكم الانتباه',
    nameEn: 'Attention Controller',
  ),
  level3(threshold: 300, emoji: '🧘', nameAr: 'صافي الذهن', nameEn: 'Clear Mind'),
  level4(threshold: 600, emoji: '⚡', nameAr: 'سيد التركيز', nameEn: 'Focus Master'),
  level5(threshold: 1000, emoji: '🧠', nameAr: 'عقل نقي', nameEn: 'Pure Mind');

  const BrainLevel({
    required this.threshold,
    required this.emoji,
    required this.nameAr,
    required this.nameEn,
  });

  final int threshold;
  final String emoji;
  final String nameAr;
  final String nameEn;

  String localizedName(bool isArabic) => isArabic ? nameAr : nameEn;

  static BrainLevel forScore(int cumulativeScore) {
    if (cumulativeScore >= BrainLevel.level5.threshold) return BrainLevel.level5;
    if (cumulativeScore >= BrainLevel.level4.threshold) return BrainLevel.level4;
    if (cumulativeScore >= BrainLevel.level3.threshold) return BrainLevel.level3;
    if (cumulativeScore >= BrainLevel.level2.threshold) return BrainLevel.level2;
    return BrainLevel.level1;
  }

  BrainLevel? get next {
    final values = BrainLevel.values;
    final i = index;
    if (i >= values.length - 1) return null;
    return values[i + 1];
  }

  /// Progress fraction toward [next] level (0–1).
  static double progressToNext(int cumulativeScore) {
    final current = forScore(cumulativeScore);
    final next = current.next;
    if (next == null) return 1.0;
    final span = next.threshold - current.threshold;
    if (span <= 0) return 1.0;
    return ((cumulativeScore - current.threshold) / span).clamp(0.0, 1.0);
  }

  static int pointsToNextLevel(int cumulativeScore) {
    final current = forScore(cumulativeScore);
    final next = current.next;
    if (next == null) return 0;
    return (next.threshold - cumulativeScore).clamp(0, next.threshold);
  }
}

int cumulativeScoreFromSnapshots(Iterable<double> bcsValues) {
  var total = 0;
  for (final v in bcsValues) {
    total += v.round();
  }
  return total;
}
