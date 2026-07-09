import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/features/daily_challenge/domain/daily_challenge_game_keys.dart';
import 'package:brain_clean_mobile/features/daily_challenge/domain/daily_challenge_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyChallengeService.getGameForDate', () {
    test('rotates through six games by day of month', () {
      expect(
        DailyChallengeService.getGameForDate(DateTime(2026, 7, 6)),
        DailyChallengeGameKeys.nBack,
      );
      expect(
        DailyChallengeService.getGameForDate(DateTime(2026, 7, 1)),
        DailyChallengeGameKeys.speedSort,
      );
      expect(
        DailyChallengeService.getGameForDate(DateTime(2026, 7, 2)),
        DailyChallengeGameKeys.colorWord,
      );
      expect(
        DailyChallengeService.getGameForDate(DateTime(2026, 7, 3)),
        DailyChallengeGameKeys.numberMemory,
      );
      expect(
        DailyChallengeService.getGameForDate(DateTime(2026, 7, 4)),
        DailyChallengeGameKeys.patternMatch,
      );
      expect(
        DailyChallengeService.getGameForDate(DateTime(2026, 7, 5)),
        DailyChallengeGameKeys.crossword,
      );
      expect(
        DailyChallengeService.getGameForDate(DateTime(2026, 7, 7)),
        DailyChallengeGameKeys.speedSort,
      );
    });
  });

  group('DailyChallengeService.getGameRoute', () {
    test('maps each game key to a GoRouter path', () {
      expect(
        DailyChallengeService.getGameRoute(DailyChallengeGameKeys.nBack),
        AppRoutes.gameNBack,
      );
      expect(
        DailyChallengeService.getGameRoute(DailyChallengeGameKeys.speedSort),
        AppRoutes.gameSpeedSort,
      );
      expect(
        DailyChallengeService.getGameRoute(DailyChallengeGameKeys.colorWord),
        AppRoutes.gameColorWord,
      );
      expect(
        DailyChallengeService.getGameRoute(DailyChallengeGameKeys.numberMemory),
        AppRoutes.gameNumberMemory,
      );
      expect(
        DailyChallengeService.getGameRoute(DailyChallengeGameKeys.patternMatch),
        AppRoutes.gamePatternMatch,
      );
      expect(
        DailyChallengeService.getGameRoute(DailyChallengeGameKeys.crossword),
        AppRoutes.crossword,
      );
    });
  });

  group('DailyChallengeService.getGameDisplayName', () {
    test('returns Arabic labels', () {
      expect(
        DailyChallengeService.getGameDisplayName(DailyChallengeGameKeys.nBack),
        'ذاكرة N-Back',
      );
      expect(
        DailyChallengeService.getGameDisplayName(
          DailyChallengeGameKeys.crossword,
        ),
        'كلمة متقاطعة',
      );
    });
  });
}
