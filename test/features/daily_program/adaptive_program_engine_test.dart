import 'package:brain_clean_mobile/features/daily_program/domain/adaptive_program_engine.dart';
import 'package:brain_clean_mobile/features/daily_program/domain/adaptive_program_protocol.dart';
import 'package:brain_clean_mobile/features/daily_program/domain/daily_program_personalization.dart';
import 'package:flutter_test/flutter_test.dart';

DailyProgramTestCoverage _coverage({
  required int bri,
  required int memory,
  required int focus,
  int iq = 55,
}) {
  return DailyProgramTestCoverage(
    hasFocus: true,
    hasMemory: true,
    hasIntelligence: true,
    hasDigitalAddiction: true,
    attentionScore: focus,
    memoryScore: memory,
    iqScore: iq,
    digitalAddictionScore: bri,
  );
}

void main() {
  group('AdaptiveProgramEngine examples', () {
    test('Example 1 Free: BRI=88 → Reset with exactly 3 drills', () {
      final coverage = _coverage(bri: 88, memory: 60, focus: 62, iq: 58);
      expect(
        AdaptiveProgramEngine.resolveProtocol(
          coverage: coverage,
          isPro: false,
        ),
        AdaptiveProgramProtocol.resetProtocol,
      );

      final plan = AdaptiveProgramEngine.build(
        coverage: coverage,
        isPro: false,
        programDay: 1,
        consecutiveMissedDays: 0,
        consecutiveCompleteDays: 0,
        difficultyOffset: 0,
        dayOfWeek: DateTime.monday,
        dayOfYear: 10,
      );
      expect(plan.protocol, AdaptiveProgramProtocol.resetProtocol);
      expect(plan.isFreeTier, isTrue);
      expect(plan.showUpgradeStrip, isTrue);
      expect(plan.showWeekendChallenge, isFalse);
      expect(plan.activities, hasLength(3));
      expect(
        plan.activities.map((a) => a.titleKey).toSet(),
        {
          'dailyProgramPomodoro',
          'dailyProgramCognitiveStroop',
          'dailyProgramScreenFree',
        },
      );
    });

    test('Example 1 Free: after day 28 Reset does not repeat', () {
      final coverage = _coverage(bri: 88, memory: 60, focus: 62);
      final plan = AdaptiveProgramEngine.build(
        coverage: coverage,
        isPro: false,
        programDay: 29,
        consecutiveMissedDays: 0,
        consecutiveCompleteDays: 0,
        difficultyOffset: 0,
        dayOfWeek: DateTime.monday,
        dayOfYear: 40,
      );
      expect(plan.freeResetComplete, isTrue);
      expect(plan.activities, isEmpty);
      expect(plan.showUpgradeStrip, isTrue);
    });

    test('Example 1 Pro: BRI=88 → full Reset week 1 library', () {
      final coverage = _coverage(bri: 88, memory: 60, focus: 62, iq: 58);
      final plan = AdaptiveProgramEngine.build(
        coverage: coverage,
        isPro: true,
        programDay: 1,
        consecutiveMissedDays: 0,
        consecutiveCompleteDays: 0,
        difficultyOffset: 0,
        dayOfWeek: DateTime.monday,
        dayOfYear: 10,
      );
      expect(plan.protocol, AdaptiveProgramProtocol.resetProtocol);
      expect(plan.activities.length, greaterThan(3));
      expect(plan.isFreeTier, isFalse);
    });

    test(
      'Example 2: BRI=45 + memory=35 + focus=40 → Neural Ascension (Pro)',
      () {
        final coverage = _coverage(bri: 45, memory: 35, focus: 40, iq: 48);
        expect(
          AdaptiveProgramEngine.resolveProtocol(
            coverage: coverage,
            isPro: true,
          ),
          AdaptiveProgramProtocol.neuralAscension,
        );
        expect(
          AdaptiveProgramEngine.resolveProtocol(
            coverage: coverage,
            isPro: false,
          ),
          AdaptiveProgramProtocol.resetProtocol,
        );

        final plan = AdaptiveProgramEngine.build(
          coverage: coverage,
          isPro: true,
          programDay: 1,
          consecutiveMissedDays: 0,
          consecutiveCompleteDays: 0,
          difficultyOffset: 0,
          dayOfWeek: DateTime.monday,
          dayOfYear: 10,
        );

        expect(plan.protocol, AdaptiveProgramProtocol.neuralAscension);
        expect(plan.protocolWeek, 3);
        expect(plan.weekGoalKey, 'adaptiveProgramAscensionPhase2Goal');

        final keys = plan.activities.map((a) => a.titleKey).toSet();
        expect(keys.contains('dailyProgramCognitiveNBack'), isTrue);
        expect(keys.contains('dailyProgramPhysicalExercise'), isTrue);
      },
    );

    test(
      'Example 3: healthy scores → Enhanced Mind (Pro maintenance)',
      () {
        final coverage = _coverage(bri: 20, memory: 75, focus: 70, iq: 65);
        expect(
          AdaptiveProgramEngine.resolveProtocol(
            coverage: coverage,
            isPro: true,
          ),
          AdaptiveProgramProtocol.enhancedMind,
        );
        expect(
          AdaptiveProgramEngine.resolveProtocol(
            coverage: coverage,
            isPro: false,
          ),
          AdaptiveProgramProtocol.resetProtocol,
        );

        final plan = AdaptiveProgramEngine.build(
          coverage: coverage,
          isPro: true,
          programDay: 1,
          consecutiveMissedDays: 0,
          consecutiveCompleteDays: 0,
          difficultyOffset: 0,
          dayOfWeek: DateTime.monday,
          dayOfYear: 10,
        );

        expect(plan.protocol, AdaptiveProgramProtocol.enhancedMind);
        expect(plan.protocolWeek, 9);
        expect(plan.weekGoalKey, 'adaptiveProgramEnhancedMindGoal');
        expect(
          plan.activities.any((a) => a.titleKey == 'dailyProgramIqChallenge'),
          isTrue,
        );
      },
    );

    test('Free never gets weekend challenge', () {
      final coverage = _coverage(bri: 80, memory: 55, focus: 55);
      final plan = AdaptiveProgramEngine.build(
        coverage: coverage,
        isPro: false,
        programDay: 10,
        consecutiveMissedDays: 0,
        consecutiveCompleteDays: 6,
        difficultyOffset: 0,
        dayOfWeek: DateTime.friday,
        dayOfYear: 20,
      );
      expect(plan.showWeekendChallenge, isFalse);
      expect(
        plan.activities.any((a) => a.id.contains('weekend')),
        isFalse,
      );
    });
  });
}
