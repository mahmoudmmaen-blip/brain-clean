import 'package:brain_clean_mobile/features/dashboard/presentation/dashboard_screen.dart'
    show DashboardScreen, dashboardDetoxCheckInTileKey;
import 'package:brain_clean_mobile/features/detox/presentation/detox_protocol_screen.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_bhi_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_session.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/bc_score_provider.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/brain_rot_questionnaire_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/diagnostic_session_flow_provider.dart';
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

import 'helpers/localized_test_app.dart';
import 'helpers/test_l10n.dart';

void main() {
  final en = testL10n;

  group('Diagnostic UI', () {
    testWidgets('diagnostic screen starts Brain Rot questionnaire', (tester) async {
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(const DiagnosticScreen()),
      );
      await tester.pump();

      expect(find.text(en.diagnosticBrainRotTitle), findsOneWidget);
      expect(find.text(en.diagnosticYes), findsOneWidget);
      expect(find.text(en.diagnosticNo), findsOneWidget);
      expect(find.text(en.diagnosticBrainRotQ1), findsOneWidget);
    });

    testWidgets('diagnostic BHI sliders after questionnaire override', (tester) async {
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const DiagnosticScreen(),
          overrides: [
            diagnosticSessionFlowProvider.overrideWith(_BhiPhaseFlow.new),
          ],
        ),
      );
      await tester.pump();

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
        createLocalizedProviderTestWidget(const DashboardScreen()),
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
        createLocalizedProviderTestWidget(const DetoxProtocolScreen()),
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
      final session = DiagnosticSession(
        bhi: DiagnosticBhiSnapshot.compose(
          metrics: const DiagnosticMetrics(),
          model: model,
        ),
        committedAt: DateTime(2026, 5, 20, 12, 30),
      );

      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const DashboardScreen(),
          overrides: [
            bcScoreSessionProvider.overrideWith(
              () => _FixedSession(session),
            ),
          ],
        ),
      );
      await tester.pump();

      final expectedCommittedAt = session.committedAt
          .toLocal()
          .toString()
          .substring(0, 16);

      expect(
        find.descendant(
          of: find.byType(BcScoreHeroCard),
          matching: find.text('${session.bcScoreRounded}%'),
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
        ],
        child: const BrainCleanApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(en.homeTitle), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
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

class _BhiPhaseFlow extends DiagnosticSessionFlow {
  @override
  BrainRotQuestionnaireSnapshot build() => BrainRotQuestionnaireSnapshot(
        answers: List<bool?>.filled(10, false),
        currentIndex: 9,
        phase: BrainRotFlowPhase.bhiSliders,
      );
}

class _FixedSession extends BcScoreSession {
  _FixedSession(this._session);

  final DiagnosticSession _session;

  @override
  DiagnosticSession? build() => _session;
}
