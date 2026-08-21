import 'structured_daily_activity.dart';

/// Builds Free / Pro structured daily program templates from week + scores.
abstract final class StructuredDailyProgramBuilder {
  /// Free brain-recovery program (5 activities).
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

  /// Pro personalized program based on attention / memory / digital addiction.
  static List<StructuredDailyActivity> buildPro({
    required StructuredDailyProgramScores scores,
    required int weekIndex,
    int dayOfYear = 1,
  }) {
    final attentionLow = scores.attention < 40;
    final memoryLow = scores.memory < 40;
    final detoxNeeded = scores.digitalAddiction > 60;
    final allLow = attentionLow && memoryLow && detoxNeeded;

    if (allLow) {
      return _fullHourlyPlan(weekIndex: weekIndex);
    }
    if (attentionLow) {
      return _heavyFocus(weekIndex: weekIndex, dayOfYear: dayOfYear);
    }
    if (memoryLow) {
      return _memoryProtocol(weekIndex: weekIndex);
    }
    if (detoxNeeded) {
      return _detoxProtocol(weekIndex: weekIndex, dayOfYear: dayOfYear);
    }
    return buildFree(weekIndex: weekIndex, dayOfYear: dayOfYear);
  }

  /// Attention &lt; 40: base + 3 extra Pomodoros + Stroop + single-screen rule.
  static List<StructuredDailyActivity> _heavyFocus({
    required int weekIndex,
    required int dayOfYear,
  }) {
    final base = buildFree(weekIndex: weekIndex, dayOfYear: dayOfYear);
    return List<StructuredDailyActivity>.unmodifiable([
      ...base.where((a) => a.id != 'cognitive'),
      const StructuredDailyActivity(
        id: 'extra_pomodoro_1',
        titleKey: 'dailyProgramHeavyPomodoro',
        minutes: 25,
      ),
      const StructuredDailyActivity(
        id: 'extra_pomodoro_2',
        titleKey: 'dailyProgramHeavyPomodoro',
        minutes: 25,
      ),
      const StructuredDailyActivity(
        id: 'extra_pomodoro_3',
        titleKey: 'dailyProgramHeavyPomodoro',
        minutes: 25,
      ),
      const StructuredDailyActivity(
        id: 'stroop_daily',
        titleKey: 'dailyProgramStroop',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'single_screen_rule',
        titleKey: 'dailyProgramSingleScreenRule',
        minutes: 1,
      ),
    ]);
  }

  /// Memory &lt; 40: Digit Span + N-Back twice + no-multitask rule.
  static List<StructuredDailyActivity> _memoryProtocol({
    required int weekIndex,
  }) {
    final screenFree = 15 + (5 * (weekIndex < 0 ? 0 : weekIndex));
    return List<StructuredDailyActivity>.unmodifiable([
      const StructuredDailyActivity(
        id: 'morning_reading',
        titleKey: 'dailyProgramReading',
        minutes: 15,
      ),
      const StructuredDailyActivity(
        id: 'digit_span',
        titleKey: 'dailyProgramDigitSpan',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'nback_1',
        titleKey: 'dailyProgramNBack',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'nback_2',
        titleKey: 'dailyProgramNBack',
        minutes: 5,
      ),
      const StructuredDailyActivity(
        id: 'no_multitask',
        titleKey: 'dailyProgramNoMultitask',
        minutes: 1,
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
        id: 'evening_review',
        titleKey: 'dailyProgramEveningReview',
        minutes: 5,
      ),
    ]);
  }

  /// Digital addiction &gt; 60: doubled screen-free + search-wait rule.
  static List<StructuredDailyActivity> _detoxProtocol({
    required int weekIndex,
    required int dayOfYear,
  }) {
    final safeWeek = weekIndex < 0 ? 0 : weekIndex;
    final screenFree = (15 + (5 * safeWeek)) * 2;
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
        minutes: screenFree,
      ),
      const StructuredDailyActivity(
        id: 'search_wait_rule',
        titleKey: 'dailyProgramSearchWaitRule',
        minutes: 1,
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

  /// All pillars weak: hour-by-hour plan 07:00–22:00.
  static List<StructuredDailyActivity> _fullHourlyPlan({
    required int weekIndex,
  }) {
    final safeWeek = weekIndex < 0 ? 0 : weekIndex;
    final screenFree = (15 + (5 * safeWeek)) * 2;
    return List<StructuredDailyActivity>.unmodifiable([
      const StructuredDailyActivity(
        id: 'h07_wake_hydrate',
        titleKey: 'dailyProgramHourly07',
        minutes: 15,
      ),
      const StructuredDailyActivity(
        id: 'h08_reading',
        titleKey: 'dailyProgramHourly08',
        minutes: 30,
      ),
      const StructuredDailyActivity(
        id: 'h09_pomodoro_1',
        titleKey: 'dailyProgramHourly09',
        minutes: 50,
      ),
      const StructuredDailyActivity(
        id: 'h10_movement',
        titleKey: 'dailyProgramHourly10',
        minutes: 20,
      ),
      const StructuredDailyActivity(
        id: 'h11_pomodoro_2',
        titleKey: 'dailyProgramHourly11',
        minutes: 50,
      ),
      const StructuredDailyActivity(
        id: 'h12_break',
        titleKey: 'dailyProgramHourly12',
        minutes: 40,
      ),
      const StructuredDailyActivity(
        id: 'h13_pomodoro_3',
        titleKey: 'dailyProgramHourly13',
        minutes: 50,
      ),
      StructuredDailyActivity(
        id: 'h14_screen_free',
        titleKey: 'dailyProgramHourly14',
        minutes: screenFree.clamp(30, 90),
      ),
      const StructuredDailyActivity(
        id: 'h15_cognitive',
        titleKey: 'dailyProgramHourly15',
        minutes: 20,
      ),
      const StructuredDailyActivity(
        id: 'h16_pomodoro_4',
        titleKey: 'dailyProgramHourly16',
        minutes: 50,
      ),
      const StructuredDailyActivity(
        id: 'h17_outdoors',
        titleKey: 'dailyProgramHourly17',
        minutes: 30,
      ),
      const StructuredDailyActivity(
        id: 'h18_light_focus',
        titleKey: 'dailyProgramHourly18',
        minutes: 40,
      ),
      const StructuredDailyActivity(
        id: 'h19_digital_sunset',
        titleKey: 'dailyProgramHourly19',
        minutes: 30,
      ),
      const StructuredDailyActivity(
        id: 'h20_reading',
        titleKey: 'dailyProgramHourly20',
        minutes: 30,
      ),
      const StructuredDailyActivity(
        id: 'h21_evening_review',
        titleKey: 'dailyProgramHourly21',
        minutes: 15,
      ),
      const StructuredDailyActivity(
        id: 'h22_wind_down',
        titleKey: 'dailyProgramHourly22',
        minutes: 20,
      ),
    ]);
  }
}
