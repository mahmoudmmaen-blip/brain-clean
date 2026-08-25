import 'structured_daily_activity.dart';
import 'daily_program_personalization.dart';

/// Builds Free / Pro structured daily program templates from week + scores.
abstract final class StructuredDailyProgramBuilder {
  /// Free brain-recovery base program (5 activities) — shown to everyone.
  ///
  /// Screen-free minutes: `15 + 5 * weekIndex` (weekIndex is 0-based).
  /// Cognitive exercise alternates N-Back / Stroop by [dayOfYear].
  static List<StructuredDailyActivity> buildFree({
    required int weekIndex,
    int dayOfYear = 1,
  }) {
    final safeWeek = weekIndex < 0 ? 0 : weekIndex;
    final screenFreeMinutes = 15 + (5 * safeWeek);
    final useNBack = dayOfYear.isOdd;
    return List<StructuredDailyActivity>.unmodifiable([
      const StructuredDailyActivity(
        id: 'morning_reading',
        titleKey: 'dailyProgramReading',
        minutes: 15,
      ),
      const StructuredDailyActivity(
        id: 'focus_pomodoro',
        titleKey: 'dailyProgramPomodoro',
        minutes: 25,
      ),
      StructuredDailyActivity(
        id: 'screen_free',
        titleKey: 'dailyProgramScreenFree',
        minutes: screenFreeMinutes,
      ),
      StructuredDailyActivity(
        id: 'cognitive',
        titleKey: useNBack
            ? 'dailyProgramCognitiveNBack'
            : 'dailyProgramCognitiveStroop',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'evening_review',
        titleKey: 'dailyProgramEveningReview',
        minutes: 5,
      ),
    ]);
  }

  /// Pro personalized program — delegates to science-based adaptive builder.
  static List<StructuredDailyActivity> buildPro({
    required StructuredDailyProgramScores scores,
    required int weekIndex,
    int dayOfYear = 1,
  }) {
    final coverage = DailyProgramTestCoverage(
      hasFocus: true,
      hasMemory: true,
      hasIntelligence: true,
      hasDigitalAddiction: true,
      attentionScore: scores.attention,
      memoryScore: scores.memory,
      iqScore: scores.iq,
      digitalAddictionScore: scores.digitalAddiction,
    );
    return PersonalizedDailyProgramBuilder.buildAdaptive(
      coverage: coverage,
      weekIndex: weekIndex,
      dayOfYear: dayOfYear,
    );
  }
}
