import '../../../core/constants/app_routes.dart';
import 'daily_challenge_game_keys.dart';

/// Pure rotation and routing helpers for the daily brain challenge.
class DailyChallengeService {
  const DailyChallengeService._();

  static String getGameForDate(DateTime date) {
    final index = date.day % DailyChallengeGameKeys.rotationOrder.length;
    return DailyChallengeGameKeys.rotationOrder[index];
  }

  static String getGameDisplayName(String gameKey) {
    return switch (gameKey) {
      DailyChallengeGameKeys.nBack => 'ذاكرة N-Back',
      DailyChallengeGameKeys.speedSort => 'الترتيب السريع',
      DailyChallengeGameKeys.colorWord => 'كلمة اللون',
      DailyChallengeGameKeys.numberMemory => 'ذاكرة الأرقام',
      DailyChallengeGameKeys.patternMatch => 'تطابق الأنماط',
      DailyChallengeGameKeys.crossword => 'كلمة متقاطعة',
      _ => 'تحدي الدماغ',
    };
  }

  static String getGameRoute(String gameKey) {
    return switch (gameKey) {
      DailyChallengeGameKeys.nBack => AppRoutes.gameNBack,
      DailyChallengeGameKeys.speedSort => AppRoutes.gameSpeedSort,
      DailyChallengeGameKeys.colorWord => AppRoutes.gameColorWord,
      DailyChallengeGameKeys.numberMemory => AppRoutes.gameNumberMemory,
      DailyChallengeGameKeys.patternMatch => AppRoutes.gamePatternMatch,
      DailyChallengeGameKeys.crossword => AppRoutes.crossword,
      _ => AppRoutes.games,
    };
  }
}
