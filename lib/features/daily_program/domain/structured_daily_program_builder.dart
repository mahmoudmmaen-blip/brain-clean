import 'structured_daily_activity.dart';

/// Builds Free / Pro structured daily program templates from week + scores.
abstract final class StructuredDailyProgramBuilder {
  /// Free standard program.
  ///
  /// Screen-free minutes: `15 + 5 * weekIndex` (weekIndex is 0-based).
  static List<StructuredDailyActivity> buildFree({
    required int weekIndex,
  }) {
    final safeWeek = weekIndex < 0 ? 0 : weekIndex;
    final screenFreeMinutes = 15 + (5 * safeWeek);
    return List<StructuredDailyActivity>.unmodifiable([
      const StructuredDailyActivity(
        id: 'morning_mindfulness',
        titleKey: 'dailyProgramMindfulness',
        minutes: 5,
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
      const StructuredDailyActivity(
        id: 'evening_reflection',
        titleKey: 'dailyProgramReflection',
        minutes: 10,
      ),
      const StructuredDailyActivity(
        id: 'cognitive',
        titleKey: 'dailyProgramCognitive',
        minutes: 5,
      ),
    ]);
  }

  /// Pro personalized program based on attention / memory / digital addiction.
  static List<StructuredDailyActivity> buildPro({
    required StructuredDailyProgramScores scores,
    required int weekIndex,
  }) {
    final attentionLow = scores.attention < 40;
    final memoryLow = scores.memory < 40;
    final detoxNeeded = scores.digitalAddiction > 60;
    final allLow = attentionLow && memoryLow && detoxNeeded;

    if (allLow) {
      return _fullRecovery(weekIndex: weekIndex);
    }
    if (attentionLow) {
      return _heavyFocus(weekIndex: weekIndex);
    }
    if (memoryLow) {
      return _memoryProtocol(weekIndex: weekIndex);
    }
    if (detoxNeeded) {
      return _detoxProtocol(weekIndex: weekIndex);
    }
    return buildFree(weekIndex: weekIndex);
  }

  static List<StructuredDailyActivity> _heavyFocus({required int weekIndex}) {
    final screenFree = 15 + (5 * (weekIndex < 0 ? 0 : weekIndex));
    return List<StructuredDailyActivity>.unmodifiable([
      const StructuredDailyActivity(
        id: 'morning_mindfulness',
        titleKey: 'dailyProgramMindfulness',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'heavy_pomodoro_1',
        titleKey: 'dailyProgramHeavyPomodoro',
        minutes: 25,
      ),
      const StructuredDailyActivity(
        id: 'heavy_pomodoro_2',
        titleKey: 'dailyProgramHeavyPomodoro',
        minutes: 25,
      ),
      const StructuredDailyActivity(
        id: 'heavy_pomodoro_3',
        titleKey: 'dailyProgramHeavyPomodoro',
        minutes: 25,
      ),
      const StructuredDailyActivity(
        id: 'heavy_pomodoro_4',
        titleKey: 'dailyProgramHeavyPomodoro',
        minutes: 25,
      ),
      const StructuredDailyActivity(
        id: 'heavy_pomodoro_5',
        titleKey: 'dailyProgramHeavyPomodoro',
        minutes: 25,
      ),
      const StructuredDailyActivity(
        id: 'stroop',
        titleKey: 'dailyProgramStroop',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'nback',
        titleKey: 'dailyProgramNBack',
        minutes: 5,
      ),
      StructuredDailyActivity(
        id: 'screen_free',
        titleKey: 'dailyProgramScreenFree',
        minutes: screenFree,
      ),
      const StructuredDailyActivity(
        id: 'evening_reflection',
        titleKey: 'dailyProgramReflection',
        minutes: 10,
      ),
    ]);
  }

  static List<StructuredDailyActivity> _memoryProtocol({
    required int weekIndex,
  }) {
    final screenFree = 15 + (5 * (weekIndex < 0 ? 0 : weekIndex));
    return List<StructuredDailyActivity>.unmodifiable([
      const StructuredDailyActivity(
        id: 'morning_mindfulness',
        titleKey: 'dailyProgramMindfulness',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'digit_span',
        titleKey: 'dailyProgramDigitSpan',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'nback',
        titleKey: 'dailyProgramNBack',
        minutes: 10,
      ),
      const StructuredDailyActivity(
        id: 'no_multitask',
        titleKey: 'dailyProgramNoMultitask',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'focus_pomodoro',
        titleKey: 'dailyProgramPomodoro',
        minutes: 25,
      ),
      StructuredDailyActivity(
        id: 'screen_free',
        titleKey: 'dailyProgramScreenFree',
        minutes: screenFree,
      ),
      const StructuredDailyActivity(
        id: 'evening_reflection',
        titleKey: 'dailyProgramReflection',
        minutes: 10,
      ),
    ]);
  }

  static List<StructuredDailyActivity> _detoxProtocol({
    required int weekIndex,
  }) {
    final safeWeek = weekIndex < 0 ? 0 : weekIndex;
    // Aggressive growth vs free: 25 + 10 * week.
    final screenFree = 25 + (10 * safeWeek);
    return List<StructuredDailyActivity>.unmodifiable([
      const StructuredDailyActivity(
        id: 'morning_mindfulness',
        titleKey: 'dailyProgramMindfulness',
        minutes: 5,
      ),
      StructuredDailyActivity(
        id: 'detox_block',
        titleKey: 'dailyProgramDetoxBlock',
        minutes: screenFree,
      ),
      const StructuredDailyActivity(
        id: 'app_usage_review',
        titleKey: 'dailyProgramAppUsageReview',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'focus_pomodoro',
        titleKey: 'dailyProgramPomodoro',
        minutes: 25,
      ),
      const StructuredDailyActivity(
        id: 'cognitive',
        titleKey: 'dailyProgramCognitive',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'evening_reflection',
        titleKey: 'dailyProgramReflection',
        minutes: 10,
      ),
    ]);
  }

  static List<StructuredDailyActivity> _fullRecovery({
    required int weekIndex,
  }) {
    final safeWeek = weekIndex < 0 ? 0 : weekIndex;
    final screenFree = 30 + (10 * safeWeek);
    return List<StructuredDailyActivity>.unmodifiable([
      const StructuredDailyActivity(
        id: 'morning_mindfulness',
        titleKey: 'dailyProgramMindfulness',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'hourly_plan',
        titleKey: 'dailyProgramHourlyPlan',
        minutes: 10,
      ),
      const StructuredDailyActivity(
        id: 'full_recovery_block',
        titleKey: 'dailyProgramFullRecoveryBlock',
        minutes: 45,
      ),
      const StructuredDailyActivity(
        id: 'heavy_pomodoro_1',
        titleKey: 'dailyProgramHeavyPomodoro',
        minutes: 25,
      ),
      const StructuredDailyActivity(
        id: 'digit_span',
        titleKey: 'dailyProgramDigitSpan',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'nback',
        titleKey: 'dailyProgramNBack',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'stroop',
        titleKey: 'dailyProgramStroop',
        minutes: 5,
      ),
      StructuredDailyActivity(
        id: 'detox_block',
        titleKey: 'dailyProgramDetoxBlock',
        minutes: screenFree,
      ),
      const StructuredDailyActivity(
        id: 'app_usage_review',
        titleKey: 'dailyProgramAppUsageReview',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'evening_reflection',
        titleKey: 'dailyProgramReflection',
        minutes: 10,
      ),
    ]);
  }
}
