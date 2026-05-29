import 'package:brain_clean_mobile/features/dashboard/presentation/dashboard_screen.dart'
    show DashboardScreen, dashboardDetoxCheckInTileKey;
import 'package:brain_clean_mobile/features/detox/presentation/detox_protocol_screen.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/brain_rot_questionnaire_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/diagnostic_screen.dart';
import 'package:brain_clean_mobile/features/recovery/data/recovery_protocol_hive_repository.dart';
import 'package:brain_clean_mobile/features/recovery/data/recovery_protocol_storage_provider.dart';
import 'package:brain_clean_mobile/features/recovery/presentation/recovery_grid_screen.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/widgets/bc_score_hero_card.dart';
import 'package:brain_clean_mobile/core/bootstrap/app_hydration_provider.dart';
import 'package:brain_clean_mobile/features/home/presentation/home_screen.dart';
import 'package:brain_clean_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brain_clean_mobile/features/accountability/accountability_box_modal.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/bc_score_provider.dart';
import 'package:brain_clean_mobile/features/focus/breathing_friction_screen.dart';
import 'package:brain_clean_mobile/features/home/presentation/home_streak_provider.dart';

import 'helpers/diagnostic_provider_overrides.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/test_l10n.dart';

void main() {
  final en = testL10n;

  group('Diagnostic UI', () {
    testWidgets('diagnostic screen starts Brain Rot questionnaire', (tester) async {
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const DiagnosticScreen(),
          overrides: diagnosticWidgetTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(en.diagnosticBrainRotTitle), findsOneWidget);
      expect(find.text(en.diagnosticYes), findsOneWidget);
      expect(find.text(en.diagnosticNo), findsOneWidget);
      expect(find.text(en.diagnosticBrainRotQ1), findsOneWidget);
    });

    testWidgets('diagnostic BHI sliders after questionnaire override', (tester) async {
      const liveModel = DiagnosticModel(
        brainPerformance: 72,
        digitalDiscipline: 68,
        healthyHabits: 70,
        consistency: 66,
      );
      final questionnaire = BrainRotQuestionnaireSnapshot(
        answers: List<bool?>.filled(10, false),
        currentIndex: 9,
        phase: BrainRotFlowPhase.bhiSliders,
      );

      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const DiagnosticScreen(),
          overrides: diagnosticWidgetTestOverrides(
            questionnaireFlow: questionnaire,
            liveModel: liveModel,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(en.diagnosticBhiTitle), findsOneWidget);
      expect(find.text(en.bcScoreHeroLabel), findsOneWidget);
      expect(find.text(en.bcScoreBreakdownTitle), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(4));
    });

    testWidgets('recovery grid shows 30-day layout and five tasks', (tester) async {
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const RecoveryGridScreen(),
          overrides: [
            recoveryProtocolStorageProvider.overrideWithValue(
              RecoveryProtocolMemoryRepository(),
            ),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text(en.recoveryGridTitle), findsOneWidget);
      expect(find.byKey(const Key('recovery_day_tasks_header')), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(5));
    });

    testWidgets('dashboard shows empty state without session', (tester) async {
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const DashboardScreen(),
          overrides: diagnosticWidgetTestOverrides(),
        ),
      );
      await tester.pump();

      expect(find.text(en.dashboardTitle), findsOneWidget);
      expect(find.text(en.dashboardEmptyDiagnosticPrompt), findsOneWidget);

      final detoxTile = find.byKey(dashboardDetoxCheckInTileKey);
      expect(detoxTile, findsOneWidget);
      expect(find.text(en.dashboardOpenDetoxCheckIn), findsOneWidget);
      expect(find.text(en.dashboardOpenDetoxCheckInSubtitle), findsOneWidget);
      expect(
        find.descendant(
          of: detoxTile,
          matching: find.byIcon(Icons.chevron_right),
        ),
        findsOneWidget,
      );
    });

    testWidgets('detox screen shows live score and habit check-in cards', (tester) async {
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const DetoxProtocolScreen(),
          overrides: diagnosticWidgetTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(en.detoxTitle), findsOneWidget);
      expect(find.text(en.detoxLiveBcScoreTitle), findsOneWidget);
      expect(find.text(en.detoxBoredomTitle), findsOneWidget);
      expect(find.text(en.detoxDelayedTitle), findsOneWidget);
      expect(find.text(en.detoxBodyTitle), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNWidgets(2));
    });

    testWidgets('dashboard detox ListTile navigates to detox check-in', (tester) async {
      await tester.pumpWidget(
        createLocalizedRouterTestWidget(
          router: createDashboardDetoxTestRouter(),
          overrides: diagnosticWidgetTestOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      final detoxTile = find.byKey(dashboardDetoxCheckInTileKey);
      expect(detoxTile, findsOneWidget);
      expect(find.text(en.dashboardOpenDetoxCheckIn), findsOneWidget);

      await tester.tap(detoxTile);
      await tester.pumpAndSettle();

      expect(find.text(en.detoxTitle), findsOneWidget);
      expect(find.byKey(dashboardDetoxCheckInTileKey), findsNothing);
    });

    testWidgets('dashboard shows committed BC_score with breakdown', (tester) async {
      const model = DiagnosticModel(
        brainPerformance: 80,
        digitalDiscipline: 70,
        healthyHabits: 75,
        consistency: 65,
      );
      final committed = composeWidgetTestCommittedSession(
        model: model,
        committedAt: DateTime(2026, 5, 20, 12, 30),
      );

      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const DashboardScreen(),
          overrides: diagnosticWidgetTestOverrides(
            committedSession: committed,
          ),
        ),
      );
      await tester.pump();

      final expectedCommittedAt = committed.committedAt
          .toLocal()
          .toString()
          .substring(0, 16);

      expect(
        find.descendant(
          of: find.byType(BcScoreHeroCard),
          matching: find.text('${committed.bcScoreRounded}%'),
        ),
        findsOneWidget,
      );
      expect(find.text(en.bcScoreBreakdownTitle), findsOneWidget);
      expect(find.text(en.dashboardCommittedAt(expectedCommittedAt)), findsOneWidget);
      expect(find.byKey(dashboardDetoxCheckInTileKey), findsOneWidget);
    });
  });

  testWidgets('BrainCleanApp hydrates then routes to home', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appHydrationProvider.overrideWith(_InstantHydration.new),
          homeStreakTickerProvider.overrideWith((ref) => Stream<int>.value(0)),
          ...diagnosticWidgetTestOverrides(),
        ],
        child: const BrainCleanApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(en.homeTitle), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('accountability modal applies −15 BCS from home', (tester) async {
    const liveModel = DiagnosticModel(
      brainPerformance: 70,
      digitalDiscipline: 70,
      healthyHabits: 70,
      consistency: 70,
    );
    final committed = composeWidgetTestCommittedSession(model: liveModel);

    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      createLocalizedProviderTestWidget(
        const HomeScreen(),
        locale: const Locale('ar'),
        overrides: [
          recoveryProtocolStorageProvider.overrideWithValue(
            RecoveryProtocolMemoryRepository(),
          ),
          ...diagnosticWidgetTestOverrides(
            liveModel: liveModel,
            committedSession: committed,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final container =
        ProviderScope.containerOf(tester.element(find.byType(HomeScreen)));
    final before = container.read(bcScoreSessionProvider)!.bcScore;

    await tester.tap(find.byKey(homeAccountabilityButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(AccountabilityBoxModal), findsOneWidget);

    await tester.tap(find.text('اللياقة البدنية'));
    await tester.pumpAndSettle();

    final firstPenalty = find.text('تمرين 30 دقيقة');
    await tester.ensureVisible(firstPenalty);
    await tester.tap(firstPenalty);
    await tester.pumpAndSettle();

    final after = container.read(bcScoreSessionProvider)!.bcScore;
    expect(before - after, 15);
    expect(find.text('تم تسجيل العقوبة ✓'), findsOneWidget);
  });

  testWidgets('breathing friction screen shows inhale phase and countdown',
      (tester) async {
    await tester.pumpWidget(
      createLocalizedTestWidget(
        const BreathingFrictionScreen(currentBhi: 70),
        locale: const Locale('ar'),
      ),
    );
    await tester.pump();

    expect(find.textContaining('استنشق'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
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
