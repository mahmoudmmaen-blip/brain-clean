import '../../cognitive_tests/application/cognitive_test_results_provider.dart';
import '../../quick_tests/data/quick_test_results_provider.dart';
import 'structured_daily_activity.dart';

/// Whether the user has enough test signal for a personalized daily program.
class DailyProgramTestCoverage {
  const DailyProgramTestCoverage({
    required this.hasFocus,
    required this.hasMemory,
    required this.hasIntelligence,
    required this.hasDigitalAddiction,
    required this.attentionScore,
    required this.memoryScore,
    required this.iqScore,
    required this.digitalAddictionScore,
  });

  final bool hasFocus;
  final bool hasMemory;
  final bool hasIntelligence;
  final bool hasDigitalAddiction;
  final int attentionScore;
  final int memoryScore;
  final int iqScore;

  /// 0–100 where higher = more digital friction / addiction pressure.
  final int digitalAddictionScore;

  bool get hasAnyTest =>
      hasFocus || hasMemory || hasIntelligence || hasDigitalAddiction;

  bool get hasFullCoverage =>
      hasFocus && hasMemory && hasIntelligence && hasDigitalAddiction;

  static DailyProgramTestCoverage fromResults({
    required CognitiveTestResultsState cognitive,
    required QuickTestResultsState quick,
  }) {
    final focus = cognitive.visualAttention;
    final memory = cognitive.memorySequence;
    final iq = quick.iq;
    final dbr = quick.digitalBrainRot;

    // Digital brain-rot scorePercent is "clarity" (higher = healthier).
    // Convert to addiction pressure for program intensity.
    final clarity = dbr?.scorePercent;
    final addiction = clarity == null ? 50 : (100 - clarity).clamp(0, 100);

    return DailyProgramTestCoverage(
      hasFocus: focus != null,
      hasMemory: memory != null,
      hasIntelligence: iq != null,
      hasDigitalAddiction: dbr != null,
      attentionScore: focus?.normalizedScore.round().clamp(0, 100) ?? 50,
      memoryScore: memory?.normalizedScore.round().clamp(0, 100) ?? 50,
      iqScore: iq?.scorePercent.clamp(0, 100) ?? 50,
      digitalAddictionScore: addiction,
    );
  }
}

/// Builds a personalized program when all four test pillars are present.
abstract final class PersonalizedDailyProgramBuilder {
  static List<StructuredDailyActivity> build({
    required DailyProgramTestCoverage coverage,
    required int weekIndex,
    required int dayOfYear,
  }) {
    final safeWeek = weekIndex < 0 ? 0 : weekIndex;
    final activities = <StructuredDailyActivity>[];

    // Reading 15–30 min from overall health (avg of pillars; higher = more reading).
    final overall = ((coverage.attentionScore +
                coverage.memoryScore +
                coverage.iqScore +
                (100 - coverage.digitalAddictionScore)) /
            4)
        .round();
    final readingMinutes = overall >= 70
        ? 30
        : overall >= 45
            ? 20
            : 15;
    activities.add(
      StructuredDailyActivity(
        id: 'morning_reading',
        titleKey: 'dailyProgramReading',
        minutes: readingMinutes,
      ),
    );

    // Focus — Stroop + Pomodoro count from attention.
    final pomodoroCount = coverage.attentionScore < 40
        ? 4
        : coverage.attentionScore < 60
            ? 2
            : 1;
    activities.add(
      const StructuredDailyActivity(
        id: 'stroop_daily',
        titleKey: 'dailyProgramStroop',
        minutes: 5,
      ),
    );
    for (var i = 0; i < pomodoroCount; i++) {
      activities.add(
        StructuredDailyActivity(
          id: 'focus_pomodoro_$i',
          titleKey: 'dailyProgramPomodoro',
          minutes: 25,
        ),
      );
    }

    // Memory — N-Back + Digit Span when memory needs work or always lightly.
    activities.add(
      StructuredDailyActivity(
        id: 'nback_1',
        titleKey: 'dailyProgramNBack',
        minutes: coverage.memoryScore < 40 ? 10 : 5,
      ),
    );
    activities.add(
      const StructuredDailyActivity(
        id: 'digit_span',
        titleKey: 'dailyProgramDigitSpan',
        minutes: 5,
      ),
    );
    if (coverage.memoryScore < 40) {
      activities.add(
        const StructuredDailyActivity(
          id: 'nback_2',
          titleKey: 'dailyProgramNBack',
          minutes: 5,
        ),
      );
      activities.add(
        const StructuredDailyActivity(
          id: 'no_multitask',
          titleKey: 'dailyProgramNoMultitask',
          minutes: 1,
        ),
      );
    }

    // Intelligence — pattern / logic challenge.
    activities.add(
      StructuredDailyActivity(
        id: 'iq_challenge',
        titleKey: 'dailyProgramIqChallenge',
        minutes: coverage.iqScore < 50 ? 10 : 5,
      ),
    );

    // Digital detox — screen-free grows with addiction + week.
    final baseScreen = 15 + (5 * safeWeek);
    final screenFree = coverage.digitalAddictionScore > 60
        ? baseScreen * 2
        : coverage.digitalAddictionScore > 40
            ? (baseScreen * 1.5).round()
            : baseScreen;
    activities.add(
      StructuredDailyActivity(
        id: 'screen_free',
        titleKey: 'dailyProgramScreenFree',
        minutes: screenFree.clamp(15, 120),
      ),
    );
    if (coverage.digitalAddictionScore > 60) {
      activities.add(
        const StructuredDailyActivity(
          id: 'search_wait_rule',
          titleKey: 'dailyProgramSearchWaitRule',
          minutes: 1,
        ),
      );
    }

    activities.add(
      const StructuredDailyActivity(
        id: 'evening_review',
        titleKey: 'dailyProgramEveningReview',
        minutes: 5,
      ),
    );

    return List<StructuredDailyActivity>.unmodifiable(activities);
  }
}
