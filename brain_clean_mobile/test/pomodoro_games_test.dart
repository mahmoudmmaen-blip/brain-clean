import 'package:brain_clean_mobile/core/data/app_meta_box_provider.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/bc_score_provider.dart';
import 'package:brain_clean_mobile/features/focus/application/single_task_provider.dart';
import 'package:brain_clean_mobile/features/focus/domain/task_category.dart';
import 'package:brain_clean_mobile/features/games/domain/game_scoring.dart';
import 'package:brain_clean_mobile/features/pomodoro/application/pomodoro_provider.dart';
import 'package:brain_clean_mobile/features/pomodoro/domain/pomodoro_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/diagnostic_provider_overrides.dart';
import 'helpers/hive_test_fixtures.dart';

void main() {
  group('Pomodoro phase transitions', () {
    test('focus completes then shortBreak', () {
      final advance = advancePomodoro(
        completedPhase: PomodoroPhase.focus,
        completedRounds: 0,
      );
      expect(advance.nextPhase, PomodoroPhase.shortBreak);
      expect(advance.completedRounds, 1);
      expect(advance.focusBonus, 5.0);
    });

    test('fourth focus completes then longBreak', () {
      final advance = advancePomodoro(
        completedPhase: PomodoroPhase.focus,
        completedRounds: 3,
      );
      expect(advance.nextPhase, PomodoroPhase.longBreak);
      expect(advance.completedRounds, 4);
    });

    test('BCS increases after focus complete via controller', () {
      final committed = composeWidgetTestCommittedSession(
        model: const DiagnosticModel(
          brainPerformance: 70,
          digitalDiscipline: 70,
          healthyHabits: 70,
          consistency: 70,
        ),
      ).withRecoveryPenaltyTotal(20);

      final container = ProviderContainer(
        overrides: [
          ...diagnosticWidgetTestOverrides(committedSession: committed),
          appMetaBoxProvider.overrideWithValue(InMemoryHiveBox()),
        ],
      );
      addTearDown(container.dispose);

      final before = container.read(bcScoreSessionProvider)!.bcScore;
      container.read(pomodoroControllerProvider.notifier).completeCurrentPhase();
      final after = container.read(bcScoreSessionProvider)!.bcScore;
      expect(after, greaterThan(before));
    });
  });

  group('Task category and difficulty', () {
    late ProviderContainer container;

    setUp(() {
      final committed = composeWidgetTestCommittedSession(
        model: const DiagnosticModel(
          brainPerformance: 70,
          digitalDiscipline: 70,
          healthyHabits: 70,
          consistency: 70,
        ),
      ).withRecoveryPenaltyTotal(30);

      container = ProviderContainer(
        overrides: [
          ...diagnosticWidgetTestOverrides(committedSession: committed),
          appMetaBoxProvider.overrideWithValue(InMemoryHiveBox()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('mental 3 stars bonus equals 16', () {
      expect(
        taskCompletionBonus(TaskCategory.mental, 3),
        16.0,
      );
    });

    test('abandon applies penalty of 5', () {
      final notifier = container.read(singleTaskControllerProvider.notifier);
      notifier.setCategory(TaskCategory.mental);
      notifier.setDifficulty(1);
      notifier.startTask('test');
      final before = container.read(bcScoreSessionProvider)!.bcScore;
      notifier.abandonTask();
      final after = container.read(bcScoreSessionProvider)!.bcScore;
      expect(after, lessThan(before));
      expect(
        container.read(singleTaskControllerProvider).isLocked,
        isFalse,
      );
    });
  });

  group('Pattern match scoring', () {
    test('5/9 correct yields score about 55 and bonus about 4.4', () {
      final score = patternMatchScore(correctCells: 5, totalCells: 9);
      expect(score.round(), 56);
      final bonus = patternMatchBcsBonus(score);
      expect(bonus, closeTo(4.4, 0.1));
    });
  });

  group('Number memory bonus', () {
    test('5 digits yields bonus of 6', () {
      expect(numberMemoryBcsBonus(5), 6.0);
    });
  });
}
