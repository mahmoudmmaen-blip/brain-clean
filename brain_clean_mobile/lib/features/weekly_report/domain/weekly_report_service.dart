import '../../daily_challenge/domain/daily_challenge_game_keys.dart';
import '../../daily_challenge/domain/daily_challenge_service.dart';
import 'weekly_report_data.dart';

/// Local copy generation for weekly reports.
class WeeklyReportService {
  const WeeklyReportService._();

  static String getMotivationalMessage(
    WeeklyReportData data, {
    required bool isArabic,
  }) {
    if (!data.hasBciData) {
      return isArabic
          ? 'أسبوعك الأول — كل خطوة بتحسب 🚀'
          : 'Your first week — every step counts 🚀';
    }
    if (data.bciChange > 5) {
      return isArabic
          ? 'أسبوع قوي — دماغك بيتحسن بوضوح 💚'
          : 'Strong week — your mind is clearly improving 💚';
    }
    if (data.bciChange > 0) {
      return isArabic
          ? 'تقدم ثابت — كمّل على نفس الإيقاع 🌿'
          : 'Steady progress — keep your rhythm 🌿';
    }
    if (data.bciChange == 0) {
      return isArabic
          ? 'أسبوع ثابت — الاستمرارية هي الفوز 💪'
          : 'A steady week — consistency wins 💪';
    }
    return isArabic
        ? 'أسبوع صعب — وده جزء طبيعي من الرحلة 🤝'
        : 'A tough week — that is a natural part of the journey 🤝';
  }

  static String? bestGameArabicName({
    required int nBack,
    required int speedSort,
    required int colorWord,
    required int numberMemory,
    required int patternMatch,
  }) {
    final scores = <String, int>{
      DailyChallengeGameKeys.nBack: nBack,
      DailyChallengeGameKeys.speedSort: speedSort,
      DailyChallengeGameKeys.colorWord: colorWord,
      DailyChallengeGameKeys.numberMemory: numberMemory,
      DailyChallengeGameKeys.patternMatch: patternMatch,
    };

    String? bestKey;
    var bestScore = 0;
    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestKey = entry.key;
      }
    }

    if (bestKey == null || bestScore <= 0) return null;
    return DailyChallengeService.getGameDisplayName(bestKey);
  }

  static String safaMessageForWorryCount(int count, {required bool isArabic}) {
    if (count >= 3) {
      return isArabic
          ? 'لاحظت إنك اهتممت بدفتر القلق — ده بيفرق فعلاً 🌿'
          : 'I noticed you used the worry journal — it really helps 🌿';
    }
    if (count >= 1) {
      return isArabic
          ? 'كويس إنك كتبت — فضّل تكتب كل يوم عشان تحس بالفرق'
          : 'Good that you wrote — try journaling daily to feel the difference';
    }
    return isArabic
        ? 'جرّب دفتر القلق الأسبوع الجاي — 5 دقايق بس'
        : 'Try the worry journal next week — just 5 minutes';
  }
}
