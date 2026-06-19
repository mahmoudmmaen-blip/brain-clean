import 'package:brain_clean_mobile/core/bootstrap/app_hydration_provider.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/bc_score_provider.dart';
import 'package:brain_clean_mobile/features/emotions/application/emotion_notification_service.dart';
import 'package:brain_clean_mobile/features/emotions/application/emotion_provider.dart';
import 'package:brain_clean_mobile/features/emotions/data/emotion_log_repository.dart';
import 'package:brain_clean_mobile/features/emotions/domain/emotion_model.dart';
import 'package:brain_clean_mobile/features/emotions/presentation/emotion_wheel_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/diagnostic_provider_overrides.dart';
import 'helpers/hive_test_fixtures.dart';
import 'helpers/localized_test_app.dart';

class _NoOpEmotionNotifications extends EmotionNotificationService {
  _NoOpEmotionNotifications()
      : super(plugin: null, navigatorKey: null);

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showRecoveryDecline({required int newBcsRounded}) async {}
}

void main() {
  group('EmotionNotifier', () {
    late ProviderContainer container;
    late InMemoryHiveBox emotionBox;

    setUp(() {
      emotionBox = InMemoryHiveBox();
      container = ProviderContainer(
        overrides: [
          emotionLogBoxProvider.overrideWithValue(emotionBox),
          emotionNotificationServiceProvider.overrideWithValue(
            _NoOpEmotionNotifications(),
          ),
          ...diagnosticWidgetTestOverrides(
            liveModel: const DiagnosticModel(
              brainPerformance: 80,
              digitalDiscipline: 80,
              healthyHabits: 80,
              consistency: 80,
            ),
            committedSession: composeWidgetTestCommittedSession(
              model: const DiagnosticModel(
                brainPerformance: 80,
                digitalDiscipline: 80,
                healthyHabits: 80,
                consistency: 80,
              ),
            ),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('selectEmotion with negative impact awaits confirmation', () {
      final sadness = EmotionModel.catalog.firstWhere(
        (e) => e.category == EmotionCategory.sadness && e.intensity == 3,
      );
      expect(sadness.recoveryImpact, lessThan(0));

      container.read(emotionNotifierProvider.notifier).selectEmotion(sadness);
      final state = container.read(emotionNotifierProvider);

      expect(state.isAwaitingConfirmation, isTrue);
      expect(state.pendingImpact, lessThan(0));
      expect(state.selectedEmotion?.label, sadness.label);
    });

    test('confirmImpact applies delta to bcScoreSession', () async {
      final before = container.read(bcScoreSessionProvider)!.bcScore;
      final outerFear = EmotionModel.catalog.firstWhere(
        (e) => e.category == EmotionCategory.fear && e.intensity == 3,
      );

      container.read(emotionNotifierProvider.notifier).selectEmotion(outerFear);
      await container.read(emotionNotifierProvider.notifier).confirmImpact();

      final after = container.read(bcScoreSessionProvider)!.bcScore;
      expect(after, lessThan(before));
      expect(
        before - after,
        closeTo(before * outerFear.recoveryImpact.abs(), 0.01),
      );
    });

    test('rejectImpact resets state without changing BCS', () {
      final before = container.read(bcScoreSessionProvider)!.bcScore;
      final anger = EmotionModel.catalog.firstWhere(
        (e) => e.category == EmotionCategory.anger && e.intensity == 1,
      );

      container.read(emotionNotifierProvider.notifier).selectEmotion(anger);
      container.read(emotionNotifierProvider.notifier).rejectImpact();

      final state = container.read(emotionNotifierProvider);
      expect(state, EmotionState.initial);
      expect(container.read(bcScoreSessionProvider)!.bcScore, before);
    });
  });

  testWidgets('mood gate negative shows category chips', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appHydrationProvider.overrideWith(_InstantHydration.new),
        ],
        child: createLocalizedTestWidget(
          const EmotionWheelScreen(),
          locale: const Locale('ar'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(emotionMoodNegativeKey));
    await tester.pumpAndSettle();

    expect(find.byKey(emotionCategoryChipKey(EmotionCategory.sadness)),
        findsOneWidget);
    expect(find.byKey(emotionCategoryChipKey(EmotionCategory.fear)),
        findsOneWidget);
    expect(find.byKey(emotionCategoryChipKey(EmotionCategory.anger)),
        findsOneWidget);
    expect(find.byKey(emotionCategoryChipKey(EmotionCategory.disgust)),
        findsOneWidget);
  });
}

class _InstantHydration extends AppHydration {
  @override
  Future<AppHydrationSnapshot> build() async {
    return const AppHydrationSnapshot(
      hasCommittedSession: false,
      hasDraftProgress: false,
    );
  }
}
