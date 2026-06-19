import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/bc_score_provider.dart';
import 'package:brain_clean_mobile/features/focus/application/single_task_provider.dart';
import 'package:brain_clean_mobile/features/focus/delayed_gratification_screen.dart';
import 'package:brain_clean_mobile/features/focus/silence_challenge_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/diagnostic_provider_overrides.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/test_l10n.dart';

void main() {
  group('Silence Challenge', () {
    testWidgets('shows countdown and level label', (tester) async {
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const SilenceChallengeScreen(streakDays: 7),
          locale: const Locale('ar'),
        ),
      );
      await tester.pump();

      expect(find.byKey(silenceCountdownKey), findsOneWidget);
      expect(find.byKey(silenceLevelLabelKey), findsOneWidget);
      expect(find.textContaining('المستوى'), findsOneWidget);
    });
  });

  group('Single Task', () {
    late ProviderContainer container;

    setUp(() {
      final committed = composeWidgetTestCommittedSession(
        model: const DiagnosticModel(
          brainPerformance: 70,
          digitalDiscipline: 70,
          healthyHabits: 70,
          consistency: 70,
        ),
      ).withRecoveryPenaltyTotal(20);

      container = ProviderContainer(
        overrides: diagnosticWidgetTestOverrides(
          committedSession: committed,
        ),
      );
    });

    tearDown(() => container.dispose());

    test('startTask locks and completeTask applies bonus', () {
      final notifier = container.read(singleTaskControllerProvider.notifier);
      final before = container.read(bcScoreSessionProvider)!.bcScore;

      notifier.startTask('قراءة كتاب');
      final locked = container.read(singleTaskControllerProvider);
      expect(locked.isLocked, isTrue);
      expect(locked.activeTaskLabel, 'قراءة كتاب');

      notifier.completeTask();
      final idle = container.read(singleTaskControllerProvider);
      expect(idle.isLocked, isFalse);
      expect(idle.activeTaskLabel, isNull);

      final after = container.read(bcScoreSessionProvider)!.bcScore;
      expect(after, greaterThan(before));
    });
  });

  group('Delayed Gratification', () {
    testWidgets('shows title and progress bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: diagnosticWidgetTestOverrides(),
          child: createLocalizedTestWidget(
            const DelayedGratificationScreen(),
            locale: const Locale('ar'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(delayedGratificationTitleKey), findsOneWidget);
      expect(find.text(testL10nAr.delayedGratTitle), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
