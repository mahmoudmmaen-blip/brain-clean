import 'package:brain_clean_mobile/features/dashboard/presentation/dashboard_screen.dart'
    show DashboardScreen, dashboardDetoxCheckInTileKey;
import 'package:brain_clean_mobile/features/detox/presentation/detox_protocol_screen.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_session.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/bc_score_provider.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/diagnostic_screen.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/widgets/bc_score_hero_card.dart';
import 'package:brain_clean_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/localized_test_app.dart';
import 'helpers/test_l10n.dart';

void main() {
  final en = testL10n;

  group('Diagnostic UI', () {
    testWidgets('diagnostic screen loads with live BC_score', (tester) async {
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(const DiagnosticScreen()),
      );
      await tester.pump();

      expect(find.text(en.diagnosticTitle), findsOneWidget);
      expect(find.text(en.bcScoreHeroLabel), findsOneWidget);
      expect(
        find.text(en.diagnosticLiveSubtitle),
        findsOneWidget,
      );
      expect(find.text(en.bcScoreBreakdownTitle), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(4));
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
        model: model,
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

  testWidgets('BrainCleanApp boots inside ProviderScope', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BrainCleanApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(en.diagnosticTitle), findsOneWidget);
    expect(find.text(en.bcScoreHeroLabel), findsOneWidget);
  });
}

class _FixedSession extends BcScoreSession {
  _FixedSession(this._session);

  final DiagnosticSession _session;

  @override
  DiagnosticSession? build() => _session;
}
