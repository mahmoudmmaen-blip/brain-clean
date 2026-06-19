import 'package:brain_clean_mobile/core/constants/hive_meta_keys.dart';
import 'package:brain_clean_mobile/core/data/app_meta_box_provider.dart';
import 'package:brain_clean_mobile/core/services/cloud_sync_service.dart';
import 'package:brain_clean_mobile/core/services/midnight_reset_service.dart';
import 'package:brain_clean_mobile/features/dashboard/application/habit_state_provider.dart';
import 'package:brain_clean_mobile/features/dashboard/application/seven_day_provider.dart';
import 'package:brain_clean_mobile/features/dashboard/data/daily_snapshots_repository.dart';
import 'package:brain_clean_mobile/features/dashboard/domain/daily_snapshot.dart';
import 'package:brain_clean_mobile/features/dashboard/presentation/seven_day_chart_widget.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/bc_score_provider.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/visual_cognitive_scorer.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/visual_cognitive_test_screen.dart';
import 'package:brain_clean_mobile/features/home/presentation/home_streak_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/diagnostic_provider_overrides.dart';
import 'helpers/hive_test_fixtures.dart';
import 'helpers/localized_test_app.dart';

void main() {
  group('sevenDaySnapshotsProvider', () {
    test('pads to 7 with leading zeros when Hive has 3 snapshots', () async {
      final box = InMemoryHiveBox();
      final now = DateTime(2026, 5, 20);
      box.put('a', DailySnapshot(date: now.subtract(const Duration(days: 2)), bcsValue: 60));
      box.put('b', DailySnapshot(date: now.subtract(const Duration(days: 1)), bcsValue: 65));
      box.put('c', DailySnapshot(date: now, bcsValue: 70));

      final container = ProviderContainer(
        overrides: [
          dailySnapshotsBoxProvider.overrideWithValue(box),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(sevenDaySnapshotsProvider.future);
      expect(result.length, 7);
      expect(result.take(4).every((s) => s.bcsValue == 0), isTrue);
      expect(result.last.bcsValue, 70);
    });
  });

  group('MidnightResetService', () {
    test('resets habits not streak and saves one snapshot', () async {
      final metaBox = InMemoryHiveBox();
      final snapshotsBox = InMemoryHiveBox();
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      metaBox.put(HiveMetaKeys.lastResetDate, MidnightResetService.formatDate(yesterday));

      final container = ProviderContainer(
        overrides: [
          appMetaBoxProvider.overrideWithValue(metaBox),
          dailySnapshotsBoxProvider.overrideWithValue(snapshotsBox),
          cloudSyncServiceProvider.overrideWithValue(const CloudSyncService()),
          ...diagnosticWidgetTestOverrides(
            committedSession: composeWidgetTestCommittedSession(
              model: const DiagnosticModel(
                brainPerformance: 70,
                digitalDiscipline: 70,
                healthyHabits: 70,
                consistency: 70,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(habitStateProvider.notifier).setBoredomBefriended(true);
      container.read(habitStateProvider.notifier).setBodyActivated(true);
      container.read(homeStreakRetrogradeProvider.notifier).applyHours(5);
      final streakBefore = container.read(homeStreakRetrogradeProvider);

      await MidnightResetService.fromContainer(container).triggerResetIfNeeded();

      final habits = container.read(habitStateProvider);
      expect(habits.boredomBefriended, isFalse);
      expect(habits.bodyActivated, isFalse);
      expect(container.read(homeStreakRetrogradeProvider), streakBefore);
      expect(DailySnapshotsRepository(snapshotsBox).loadAll().length, 1);
    });
  });

  group('VisualCognitiveScorer', () {
    test('correct fast tap scores 3', () {
      expect(
        VisualCognitiveScorer.scoreCorrectTap(tapTimeSeconds: 0.5),
        3,
      );
    });

    test('correct slow tap scores 1', () {
      expect(
        VisualCognitiveScorer.scoreCorrectTap(tapTimeSeconds: 2.0),
        1,
      );
    });

    test('wrong tap scores 0', () {
      expect(VisualCognitiveScorer.scoreWrongTap(), 0);
    });
  });

  testWidgets('VisualCognitiveTestScreen shows grid', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: diagnosticWidgetTestOverrides(),
        child: createLocalizedTestWidget(
          const VisualCognitiveTestScreen(),
          locale: const Locale('ar'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(visualCognitiveGridKey), findsOneWidget);
  });

  testWidgets('DelayedGratification title in chart widget area', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailySnapshotsBoxProvider.overrideWithValue(InMemoryHiveBox()),
        ],
        child: createLocalizedTestWidget(
          const Scaffold(body: SevenDayChartWidget()),
          locale: const Locale('ar'),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('تقدمك خلال 7 أيام'), findsOneWidget);
    expect(find.byKey(chartEmptyStateKey), findsOneWidget);
  });
}
