import 'adaptive_program_protocol.dart';
import 'daily_program_personalization.dart';
import 'structured_daily_activity.dart';
import 'structured_daily_program_builder.dart';

/// Generates dynamic daily schedules from BRI / cognitive scores + week state.
abstract final class AdaptiveProgramEngine {
  /// BRI-high threshold (rot / addiction pressure).
  static const briHighThreshold = 60;

  /// Cognitive "healthy enough" floor for Reset Protocol (Case A).
  static const cognitiveHealthyFloor = 50;

  static AdaptiveProgramProtocol resolveProtocol({
    required DailyProgramTestCoverage coverage,
    required bool isPro,
  }) {
    if (!coverage.hasAnyTest) return AdaptiveProgramProtocol.base;

    final briHigh = coverage.digitalAddictionScore > briHighThreshold;
    final cognitiveWeak = isCognitiveWeak(coverage);

    // §4 Free: Reset Protocol only (never Ascension / Enhanced Mind).
    if (!isPro) {
      if (coverage.hasDigitalAddiction || briHigh) {
        return AdaptiveProgramProtocol.resetProtocol;
      }
      return AdaptiveProgramProtocol.base;
    }

    // Pro routing
    if (briHigh && cognitiveWeak) {
      return AdaptiveProgramProtocol.neuralAscension;
    }
    if (briHigh) return AdaptiveProgramProtocol.resetProtocol;
    if (cognitiveWeak) return AdaptiveProgramProtocol.neuralAscension;
    // Example 3 — healthy, wants improvement
    return AdaptiveProgramProtocol.enhancedMind;
  }

  /// Memory / focus / IQ below healthy floor.
  static bool isCognitiveWeak(DailyProgramTestCoverage coverage) {
    return coverage.attentionScore < cognitiveHealthyFloor ||
        coverage.memoryScore < cognitiveHealthyFloor ||
        coverage.iqScore < cognitiveHealthyFloor;
  }

  /// Free users who should see Pro upsell (Ascension / full library / reports).
  static bool needsAscensionPro(DailyProgramTestCoverage coverage) {
    if (!coverage.hasAnyTest) return false;
    // Any Free diagnosis → upgrade strip for full personal program.
    return true;
  }

  /// Free Reset lasts exactly 4 weeks (28 program days), then stops.
  static const freeResetMaxProgramDay = 28;

  /// Effective protocol week (1-based), after miss-day rewind.
  static int effectiveProtocolWeek({
    required int programDay,
    required int consecutiveMissedDays,
    required int storedWeekOverride,
  }) {
    if (storedWeekOverride > 0) return storedWeekOverride;
    final raw = ((programDay < 1 ? 1 : programDay) - 1) ~/ 7 + 1;
    // Missed 2 consecutive calendar days → stay on / rewind current week.
    if (consecutiveMissedDays >= 2) {
      return raw < 1 ? 1 : raw;
    }
    return raw;
  }

  static AdaptiveProgramPlan build({
    required DailyProgramTestCoverage coverage,
    required bool isPro,
    required int programDay,
    required int consecutiveMissedDays,
    required int consecutiveCompleteDays,
    required int difficultyOffset,
    required int dayOfWeek, // DateTime.weekday 1=Mon … 7=Sun
    required int dayOfYear,
    int storedWeekOverride = 0,
  }) {
    final protocol = resolveProtocol(coverage: coverage, isPro: isPro);
    final showUpgradeStrip = !isPro && needsAscensionPro(coverage);

    if (protocol == AdaptiveProgramProtocol.base) {
      final base = StructuredDailyProgramBuilder.buildFree(
        weekIndex: structuredWeekIndex(programDay),
        dayOfYear: dayOfYear,
      );
      return AdaptiveProgramPlan(
        protocol: protocol,
        protocolWeek: 1,
        weekGoalKey: 'adaptiveProgramBaseGoal',
        activities: isPro ? base : _capFreeBase(base),
        showWeekendChallenge: false,
        difficultyLevel: 0,
        showUpgradeStrip: showUpgradeStrip,
        isFreeTier: !isPro,
      );
    }

    // Free Reset: 4 weeks only, does not repeat.
    if (!isPro && protocol == AdaptiveProgramProtocol.resetProtocol) {
      final day = programDay < 1 ? 1 : programDay;
      if (day > freeResetMaxProgramDay) {
        return AdaptiveProgramPlan(
          protocol: protocol,
          protocolWeek: 4,
          weekGoalKey: 'adaptiveProgramFreeResetCompleteGoal',
          activities: const [],
          showWeekendChallenge: false,
          difficultyLevel: 0,
          freeResetComplete: true,
          showUpgradeStrip: true,
          isFreeTier: true,
        );
      }
      final week = ((day - 1) ~/ 7 + 1).clamp(1, 4);
      return AdaptiveProgramPlan(
        protocol: protocol,
        protocolWeek: week,
        weekGoalKey: 'adaptiveProgramResetWeek${week}Goal',
        activities: _freeResetDay(week: week),
        showWeekendChallenge: false,
        difficultyLevel: 0,
        showUpgradeStrip: true,
        isFreeTier: true,
      );
    }

    var week = effectiveProtocolWeek(
      programDay: programDay,
      consecutiveMissedDays: consecutiveMissedDays,
      storedWeekOverride: storedWeekOverride,
    );

    final briHigh = coverage.digitalAddictionScore > briHighThreshold;
    final cognitiveWeak = isCognitiveWeak(coverage);
    if (protocol == AdaptiveProgramProtocol.neuralAscension && !briHigh) {
      // Example 2: skip purge → Build (week 3+).
      if (cognitiveWeak && week < 3) week = 3;
    }
    if (protocol == AdaptiveProgramProtocol.enhancedMind && week < 9) {
      // Example 3: maintenance rotation.
      week = 9;
    }

    var difficulty = (0 + difficultyOffset).clamp(0, 2);
    if (consecutiveMissedDays >= 2) {
      difficulty = (difficulty - 1).clamp(0, 2);
    }

    // §4 Free: no challenges. Pro: weekend challenge after 5-day streak on Friday.
    final weekendChallenge =
        isPro && consecutiveCompleteDays >= 5 && dayOfWeek == DateTime.friday;

    final activities = switch (protocol) {
      AdaptiveProgramProtocol.resetProtocol => _proResetWeek(
          week: week,
          difficulty: difficulty,
          difficultyOffset: difficultyOffset,
          dayOfYear: dayOfYear,
          weekendChallenge: weekendChallenge,
        ),
      AdaptiveProgramProtocol.neuralAscension ||
      AdaptiveProgramProtocol.enhancedMind =>
        _ascensionWeek(
          week: week,
          difficulty: difficulty,
          difficultyOffset: difficultyOffset,
          dayOfYear: dayOfYear,
          weekendChallenge: weekendChallenge,
        ),
      AdaptiveProgramProtocol.base => const <StructuredDailyActivity>[],
    };

    return AdaptiveProgramPlan(
      protocol: protocol,
      protocolWeek: week,
      weekGoalKey: _weekGoalKey(protocol, week),
      activities: List<StructuredDailyActivity>.unmodifiable(activities),
      showWeekendChallenge: weekendChallenge,
      difficultyLevel: difficulty,
      showUpgradeStrip: false,
      isFreeTier: false,
    );
  }

  /// Free base (no BRI yet): still max 3 core drills.
  static List<StructuredDailyActivity> _capFreeBase(
    List<StructuredDailyActivity> base,
  ) {
    const allowed = {
      'dailyProgramPomodoro',
      'dailyProgramCognitiveStroop',
      'dailyProgramScreenFree',
    };
    final filtered = base
        .where((a) => allowed.contains(a.titleKey))
        .take(3)
        .toList(growable: false);
    if (filtered.length >= 3) return filtered;
    return _freeResetDay(week: 1);
  }

  /// §4 Free: exactly Pomodoro + easy Stroop + screen-free.
  static List<StructuredDailyActivity> _freeResetDay({required int week}) {
    final w = week.clamp(1, 4);
    final pomoMinutes = switch (w) {
      1 => 15,
      2 => 20,
      _ => 25,
    };
    final screenMinutes = switch (w) {
      1 => 30,
      2 => 45,
      _ => 60,
    };
    return List<StructuredDailyActivity>.unmodifiable([
      StructuredDailyActivity(
        id: 'free_pomo',
        titleKey: 'dailyProgramPomodoro',
        minutes: pomoMinutes,
        isAdaptive: true,
      ),
      const StructuredDailyActivity(
        id: 'free_stroop',
        titleKey: 'dailyProgramCognitiveStroop',
        minutes: 5,
        isAdaptive: true,
      ),
      StructuredDailyActivity(
        id: 'free_screen',
        titleKey: 'dailyProgramScreenFree',
        minutes: screenMinutes,
        isAdaptive: true,
      ),
    ]);
  }

  static int structuredWeekIndex(int programDay) {
    final day = programDay < 1 ? 1 : programDay;
    return (day - 1) ~/ 7;
  }

  static String _weekGoalKey(AdaptiveProgramProtocol protocol, int week) {
    if (protocol == AdaptiveProgramProtocol.resetProtocol) {
      final w = week.clamp(1, 4);
      return 'adaptiveProgramResetWeek${w}Goal';
    }
    if (protocol == AdaptiveProgramProtocol.enhancedMind) {
      return 'adaptiveProgramEnhancedMindGoal';
    }
    // Neural Ascension phases
    if (week <= 2) return 'adaptiveProgramAscensionPhase1Goal';
    if (week <= 5) return 'adaptiveProgramAscensionPhase2Goal';
    if (week <= 8) return 'adaptiveProgramAscensionPhase3Goal';
    return 'adaptiveProgramAscensionPhase4Goal';
  }

  /// Pro Reset Protocol weeks 1–4 (full library schedule).
  static List<StructuredDailyActivity> _proResetWeek({
    required int week,
    required int difficulty,
    required int difficultyOffset,
    required int dayOfYear,
    required bool weekendChallenge,
  }) {
    final w = week.clamp(1, 4);
    // Hard drills blocked before week 3.
    final allowHard = w >= 3 && difficulty >= 2;
    final allowMedium = w >= 3 || difficulty >= 1;
    final useNBack = dayOfYear.isOdd;

    final list = <StructuredDailyActivity>[];

    switch (w) {
      case 1:
        // Digital fasting: Pomodoro 15×2, screen-free 30, evening 5, easy Stroop, reading
        list.addAll([
          const StructuredDailyActivity(
            id: 'reset_reading',
            titleKey: 'dailyProgramReading',
            minutes: 15,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_pomo_1',
            titleKey: 'dailyProgramPomodoro',
            minutes: 15,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_pomo_2',
            titleKey: 'dailyProgramPomodoro',
            minutes: 15,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_screen_free',
            titleKey: 'dailyProgramScreenFree',
            minutes: 30,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_stroop',
            titleKey: 'dailyProgramCognitiveStroop',
            minutes: 5,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_evening',
            titleKey: 'dailyProgramEveningReview',
            minutes: 5,
          ),
        ]);
      case 2:
        list.addAll([
          const StructuredDailyActivity(
            id: 'reset_reading',
            titleKey: 'dailyProgramReading',
            minutes: 15,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_pomo_1',
            titleKey: 'dailyProgramPomodoro',
            minutes: 20,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_pomo_2',
            titleKey: 'dailyProgramPomodoro',
            minutes: 20,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_pomo_3',
            titleKey: 'dailyProgramPomodoro',
            minutes: 20,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_screen_free',
            titleKey: 'dailyProgramScreenFree',
            minutes: 45,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_breathing',
            titleKey: 'adaptiveProgramBreathing',
            minutes: 5,
            isAdaptive: true,
          ),
          StructuredDailyActivity(
            id: 'reset_cognitive',
            titleKey: allowMedium
                ? 'dailyProgramIqChallenge'
                : 'dailyProgramCognitiveStroop',
            minutes: 5,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_evening',
            titleKey: 'dailyProgramEveningReview',
            minutes: 5,
          ),
        ]);
      case 3:
        list.addAll([
          const StructuredDailyActivity(
            id: 'reset_reading',
            titleKey: 'dailyProgramActiveRecallReading',
            minutes: 15,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_pomo_1',
            titleKey: 'dailyProgramPomodoro',
            minutes: 25,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_pomo_2',
            titleKey: 'dailyProgramPomodoro',
            minutes: 25,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_pomo_3',
            titleKey: 'dailyProgramPomodoro',
            minutes: 25,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_screen_free',
            titleKey: 'dailyProgramScreenFree',
            minutes: 60,
            isAdaptive: true,
          ),
          StructuredDailyActivity(
            id: 'reset_nback',
            titleKey: useNBack
                ? 'dailyProgramCognitiveNBack'
                : 'dailyProgramCognitiveStroop',
            minutes: allowHard ? 10 : 5,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_evening',
            titleKey: 'dailyProgramEveningReview',
            minutes: 5,
          ),
        ]);
      default:
        // Week 4+ protection
        list.addAll([
          const StructuredDailyActivity(
            id: 'reset_reading',
            titleKey: 'dailyProgramActiveRecallReading',
            minutes: 20,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_pomo_1',
            titleKey: 'dailyProgramPomodoro',
            minutes: 25,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_pomo_2',
            titleKey: 'dailyProgramPomodoro',
            minutes: 25,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_pomo_3',
            titleKey: 'dailyProgramPomodoro',
            minutes: 25,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_pomo_4',
            titleKey: 'dailyProgramPomodoro',
            minutes: 25,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_screen_free',
            titleKey: 'dailyProgramScreenFree',
            minutes: 60,
            isAdaptive: true,
          ),
          StructuredDailyActivity(
            id: 'reset_cognitive',
            titleKey: useNBack
                ? 'dailyProgramCognitiveNBack'
                : 'dailyProgramCognitiveStroop',
            minutes: allowHard ? 10 : 5,
            isAdaptive: true,
          ),
          const StructuredDailyActivity(
            id: 'reset_evening',
            titleKey: 'dailyProgramEveningReview',
            minutes: 5,
          ),
        ]);
    }

    if (weekendChallenge) {
      list.add(
        const StructuredDailyActivity(
          id: 'weekend_challenge',
          titleKey: 'adaptiveProgramWeekendChallenge',
          minutes: 20,
          isAdaptive: true,
        ),
      );
    }

    if (difficultyOffset < 0) {
      list.add(
        const StructuredDailyActivity(
          id: 'reset_breathing_extra',
          titleKey: 'adaptiveProgramBreathing',
          minutes: 5,
          isAdaptive: true,
        ),
      );
    }

    return list;
  }

  /// Case B — Neural Ascension (Pro) phased weeks.
  static List<StructuredDailyActivity> _ascensionWeek({
    required int week,
    required int difficulty,
    required int difficultyOffset,
    required int dayOfYear,
    required bool weekendChallenge,
  }) {
    final useNBack = dayOfYear.isOdd;
    final list = <StructuredDailyActivity>[];

    if (week <= 2) {
      // Phase 1 purification: 70% detox / 30% light cognitive
      list.addAll([
        const StructuredDailyActivity(
          id: 'asc_screen_free',
          titleKey: 'dailyProgramScreenFree',
          minutes: 45,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_morning_zero',
          titleKey: 'dailyProgramMorningZeroScreens',
          minutes: 60,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_pomo_1',
          titleKey: 'dailyProgramPomodoro',
          minutes: 15,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_pomo_2',
          titleKey: 'dailyProgramPomodoro',
          minutes: 15,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_stroop',
          titleKey: 'dailyProgramCognitiveStroop',
          minutes: 5,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_reading',
          titleKey: 'dailyProgramReading',
          minutes: 10,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_evening',
          titleKey: 'dailyProgramEveningReview',
          minutes: 5,
        ),
      ]);
    } else if (week <= 5) {
      // Phase 2 build: memory + focus
      list.addAll([
        const StructuredDailyActivity(
          id: 'asc_screen_free',
          titleKey: 'dailyProgramScreenFree',
          minutes: 40,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_pomo_1',
          titleKey: 'dailyProgramPomodoro',
          minutes: 25,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_pomo_2',
          titleKey: 'dailyProgramPomodoro',
          minutes: 25,
          isAdaptive: true,
        ),
        StructuredDailyActivity(
          id: 'asc_nback',
          titleKey: 'dailyProgramCognitiveNBack',
          minutes: difficulty >= 1 ? 8 : 5,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_reading',
          titleKey: 'dailyProgramActiveRecallReading',
          minutes: 15,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_physical',
          titleKey: 'dailyProgramPhysicalExercise',
          minutes: 20,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_evening',
          titleKey: 'dailyProgramEveningReview',
          minutes: 5,
        ),
      ]);
    } else if (week <= 8) {
      // Phase 3 optimize
      list.addAll([
        const StructuredDailyActivity(
          id: 'asc_screen_free',
          titleKey: 'dailyProgramScreenFree',
          minutes: 30,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_pomo_1',
          titleKey: 'dailyProgramPomodoro5010',
          minutes: 50,
          isAdaptive: true,
        ),
        StructuredDailyActivity(
          id: 'asc_digit_span',
          titleKey: 'dailyProgramDigitSpan',
          minutes: 5,
          isAdaptive: true,
        ),
        StructuredDailyActivity(
          id: 'asc_cognitive',
          titleKey: useNBack
              ? 'dailyProgramCognitiveNBack'
              : 'dailyProgramCognitiveStroop',
          minutes: 10,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_iq',
          titleKey: 'dailyProgramIqChallenge',
          minutes: 10,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_reading',
          titleKey: 'dailyProgramActiveRecallReading',
          minutes: 20,
          isAdaptive: true,
        ),
        const StructuredDailyActivity(
          id: 'asc_evening',
          titleKey: 'dailyProgramEveningReview',
          minutes: 5,
        ),
      ]);
    } else {
      // Phase 4 maintenance rotation by dayOfYear
      final mode = dayOfYear % 4;
      list.addAll([
        const StructuredDailyActivity(
          id: 'asc_maintain_screen',
          titleKey: 'dailyProgramScreenFree',
          minutes: 30,
          isAdaptive: true,
        ),
        if (mode == 0)
          const StructuredDailyActivity(
            id: 'asc_day_focus',
            titleKey: 'dailyProgramPomodoro5010',
            minutes: 50,
            isAdaptive: true,
          ),
        if (mode == 1)
          const StructuredDailyActivity(
            id: 'asc_day_memory',
            titleKey: 'dailyProgramCognitiveNBack',
            minutes: 10,
            isAdaptive: true,
          ),
        if (mode == 2)
          const StructuredDailyActivity(
            id: 'asc_day_iq',
            titleKey: 'dailyProgramIqChallenge',
            minutes: 10,
            isAdaptive: true,
          ),
        if (mode == 3)
          const StructuredDailyActivity(
            id: 'asc_day_active_rest',
            titleKey: 'dailyProgramNsdrRest',
            minutes: 15,
            isAdaptive: true,
          ),
        const StructuredDailyActivity(
          id: 'asc_evening',
          titleKey: 'dailyProgramEveningReview',
          minutes: 5,
        ),
      ]);
    }

    if (weekendChallenge) {
      list.add(
        const StructuredDailyActivity(
          id: 'weekend_challenge',
          titleKey: 'adaptiveProgramWeekendChallenge',
          minutes: 25,
          isAdaptive: true,
        ),
      );
    }

    if (difficultyOffset < 0) {
      list.add(
        const StructuredDailyActivity(
          id: 'asc_breathing',
          titleKey: 'adaptiveProgramBreathing',
          minutes: 5,
          isAdaptive: true,
        ),
      );
    }

    return list;
  }
}
