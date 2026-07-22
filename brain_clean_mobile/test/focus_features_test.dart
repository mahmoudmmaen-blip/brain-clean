import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/bc_score_provider.dart';
import 'package:brain_clean_mobile/features/focus/application/silence_challenge_daily_program_gate.dart';
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
  group('SilenceChallengeDailyProgramGate', () {
    test('arm/consume/disarm behave like mood gate', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final gate =
          container.read(silenceChallengeDailyProgramGateProvider.notifier);
      expect(container.read(silenceChallengeDailyProgramGateProvider), isFalse);

      gate.arm();
      expect(container.read(silenceChallengeDailyProgramGateProvider), isTrue);
      expect(gate.consume(), isTrue);
      expect(container.read(silenceChallengeDailyProgramGateProvider), isFalse);
      expect(gate.consume(), isFalse);

      gate.arm();
      gate.disarm();
      expect(container.read(silenceChallengeDailyProgramGateProvider), isFalse);
    });
  });

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
      expect(find.byKey(silenceSessionIconKey), findsOneWidget);
      expect(find.text('🔕'), findsOneWidget);
      expect(find.textContaining('المستوى'), findsOneWidget);
    });

    testWidgets('popping back disarms gate without provider lifecycle error',
        (tester) async {
      late ProviderContainer container;
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return MaterialApp(
                navigatorKey: navigatorKey,
                localizationsDelegates: appLocalizationsDelegates,
                supportedLocales: supportedLocales,
                locale: const Locale('ar'),
                home: Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      navigatorKey.currentState!.push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              const SilenceChallengeScreen(streakDays: 0),
                        ),
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      container
          .read(silenceChallengeDailyProgramGateProvider.notifier)
          .arm();
      expect(container.read(silenceChallengeDailyProgramGateProvider), isTrue);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byKey(silenceCountdownKey), findsOneWidget);

      navigatorKey.currentState!.pop();
      await tester.pump();
      await tester.pump();

      expect(
        container.read(silenceChallengeDailyProgramGateProvider),
        isFalse,
      );
      expect(tester.takeException(), isNull);
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

    test('startTask locks and completeTask applies bonus', () async {
      final notifier = container.read(singleTaskControllerProvider.notifier);
      final before = container.read(bcScoreSessionProvider)!.bcScore;

      notifier.startTask('قراءة كتاب');
      final locked = container.read(singleTaskControllerProvider);
      expect(locked.isLocked, isTrue);
      expect(locked.activeTaskLabel, 'قراءة كتاب');

      await notifier.completeTask();
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
