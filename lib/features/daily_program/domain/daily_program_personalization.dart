import '../../cognitive_tests/application/cognitive_test_results_provider.dart';
import '../../quick_tests/data/quick_test_results_provider.dart';
import 'structured_daily_activity.dart';
import 'structured_daily_program_builder.dart';

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

  /// Clarity / health equivalent of digital pillar (100 − addiction).
  int get digitalClarityScore => (100 - digitalAddictionScore).clamp(0, 100);

  /// All cognitive pillars weak + digital clarity weak.
  bool get allScoresWeak =>
      attentionScore < 50 &&
      memoryScore < 50 &&
      iqScore < 50 &&
      digitalClarityScore < 50;

  static DailyProgramTestCoverage fromResults({
    required CognitiveTestResultsState cognitive,
    required QuickTestResultsState quick,
    StructuredDailyProgramScores? profileFallback,
  }) {
    final focus = cognitive.visualAttention;
    final memory = cognitive.memorySequence;
    final iq = quick.iq;
    final dbr = quick.digitalBrainRot;
    final fallback = profileFallback ?? StructuredDailyProgramScores.neutral;

    // Digital brain-rot scorePercent is "clarity" (higher = healthier).
    // Convert to addiction pressure for program intensity.
    final clarity = dbr?.scorePercent;
    final addiction = clarity == null
        ? fallback.digitalAddiction
        : (100 - clarity).clamp(0, 100);

    return DailyProgramTestCoverage(
      hasFocus: focus != null,
      hasMemory: memory != null,
      hasIntelligence: iq != null,
      hasDigitalAddiction: dbr != null,
      attentionScore:
          focus?.normalizedScore.round().clamp(0, 100) ?? fallback.attention,
      memoryScore:
          memory?.normalizedScore.round().clamp(0, 100) ?? fallback.memory,
      iqScore: iq?.scorePercent.clamp(0, 100) ?? fallback.iq,
      digitalAddictionScore: addiction,
    );
  }
}

/// Science-based adaptive daily program (base for all + Pro additions).
abstract final class PersonalizedDailyProgramBuilder {
  /// Free / default base program (5 activities). Everyone sees this.
  static List<StructuredDailyActivity> buildBase({
    required int weekIndex,
    required int dayOfYear,
  }) {
    return StructuredDailyProgramBuilder.buildFree(
      weekIndex: weekIndex,
      dayOfYear: dayOfYear,
    );
  }

  /// Pro adaptive program: base + score-driven additions / modifications.
  static List<StructuredDailyActivity> build({
    required DailyProgramTestCoverage coverage,
    required int weekIndex,
    required int dayOfYear,
  }) {
    return buildAdaptive(
      coverage: coverage,
      weekIndex: weekIndex,
      dayOfYear: dayOfYear,
    );
  }

  static List<StructuredDailyActivity> buildAdaptive({
    required DailyProgramTestCoverage coverage,
    required int weekIndex,
    required int dayOfYear,
  }) {
    if (coverage.allScoresWeak) {
      return _fullRecoveryProtocol(dayOfYear: dayOfYear);
    }

    final safeWeek = weekIndex < 0 ? 0 : weekIndex;
    var screenFreeMinutes = 15 + (5 * safeWeek);
    var pomodoroMinutes = 25;
    var pomodoroTitle = 'dailyProgramPomodoro';
    var cognitiveMinutes = 5;
    var readingTitle = 'dailyProgramReading';
    final useNBack = dayOfYear.isOdd;

    final extras = <StructuredDailyActivity>[];

    // —— Digital addiction > 60 ——
    if (coverage.digitalAddictionScore > 60) {
      screenFreeMinutes = screenFreeMinutes < 45 ? 45 : screenFreeMinutes;
      extras.add(
        const StructuredDailyActivity(
          id: 'morning_zero_screens',
          titleKey: 'dailyProgramMorningZeroScreens',
          minutes: 60,
          isAdaptive: true,
        ),
      );
      extras.add(
        const StructuredDailyActivity(
          id: 'grayscale_mode',
          titleKey: 'dailyProgramGrayscaleMode',
          minutes: 1,
          isAdaptive: true,
        ),
      );
    }

    // —— Attention < 40 ——
    if (coverage.attentionScore < 40) {
      pomodoroMinutes = 50;
      pomodoroTitle = 'dailyProgramPomodoro5010';
      extras.add(
        const StructuredDailyActivity(
          id: 'white_noise',
          titleKey: 'dailyProgramWhiteNoise',
          minutes: 25,
          isAdaptive: true,
        ),
      );
      extras.add(
        const StructuredDailyActivity(
          id: 'single_screen_rule',
          titleKey: 'dailyProgramSingleScreenRule',
          minutes: 1,
          isAdaptive: true,
        ),
      );
    }

    // —— Memory < 40 ——
    if (coverage.memoryScore < 40) {
      readingTitle = 'dailyProgramActiveRecallReading';
      extras.add(
        const StructuredDailyActivity(
          id: 'nsdr_rest',
          titleKey: 'dailyProgramNsdrRest',
          minutes: 15,
          isAdaptive: true,
          isOptional: true,
        ),
      );
      extras.add(
        const StructuredDailyActivity(
          id: 'digit_span',
          titleKey: 'dailyProgramDigitSpan',
          minutes: 5,
          isAdaptive: true,
        ),
      );
    }

    // —— IQ < 50 ——
    if (coverage.iqScore < 50) {
      cognitiveMinutes = 10;
      extras.add(
        const StructuredDailyActivity(
          id: 'physical_exercise',
          titleKey: 'dailyProgramPhysicalExercise',
          minutes: 25,
          isAdaptive: true,
        ),
      );
    }

    final readingAdaptive = readingTitle != 'dailyProgramReading';
    final pomodoroAdaptive = pomodoroMinutes != 25;
    final cognitiveAdaptive = cognitiveMinutes != 5;
    final screenAdaptive = coverage.digitalAddictionScore > 60;

    final base = <StructuredDailyActivity>[
      StructuredDailyActivity(
        id: 'morning_reading',
        titleKey: readingTitle,
        minutes: 15,
        isAdaptive: readingAdaptive,
      ),
      StructuredDailyActivity(
        id: 'focus_pomodoro',
        titleKey: pomodoroTitle,
        minutes: pomodoroMinutes,
        isAdaptive: pomodoroAdaptive,
      ),
      StructuredDailyActivity(
        id: 'screen_free',
        titleKey: 'dailyProgramScreenFree',
        minutes: screenFreeMinutes,
        isAdaptive: screenAdaptive,
      ),
      StructuredDailyActivity(
        id: 'cognitive',
        titleKey: useNBack
            ? 'dailyProgramCognitiveNBack'
            : 'dailyProgramCognitiveStroop',
        minutes: cognitiveMinutes,
        isAdaptive: cognitiveAdaptive,
      ),
      const StructuredDailyActivity(
        id: 'evening_review',
        titleKey: 'dailyProgramEveningReview',
        minutes: 5,
      ),
    ];

    return List<StructuredDailyActivity>.unmodifiable([
      ...base,
      ...extras,
    ]);
  }

  /// Full recovery day plan when every pillar is weak.
  static List<StructuredDailyActivity> _fullRecoveryProtocol({
    required int dayOfYear,
  }) {
    final useNBack = dayOfYear.isOdd;
    return List<StructuredDailyActivity>.unmodifiable([
      const StructuredDailyActivity(
        id: 'recovery_0700',
        titleKey: 'dailyProgramRecovery0700',
        minutes: 60,
        isAdaptive: true,
      ),
      const StructuredDailyActivity(
        id: 'recovery_0900',
        titleKey: 'dailyProgramRecovery0900',
        minutes: 50,
        isAdaptive: true,
      ),
      const StructuredDailyActivity(
        id: 'recovery_1200',
        titleKey: 'dailyProgramRecovery1200',
        minutes: 15,
        isAdaptive: true,
      ),
      StructuredDailyActivity(
        id: 'recovery_1600_reading',
        titleKey: 'dailyProgramActiveRecallReading',
        minutes: 15,
        isAdaptive: true,
      ),
      StructuredDailyActivity(
        id: 'recovery_1600_cognitive',
        titleKey: useNBack
            ? 'dailyProgramCognitiveNBack'
            : 'dailyProgramCognitiveStroop',
        minutes: 5,
        isAdaptive: true,
      ),
      const StructuredDailyActivity(
        id: 'recovery_2100',
        titleKey: 'dailyProgramRecovery2100',
        minutes: 30,
        isAdaptive: true,
      ),
    ]);
  }
}
