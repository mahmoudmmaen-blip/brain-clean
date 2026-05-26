import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_session.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/bc_score_provider.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/diagnostic_screen.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/widgets/bc_score_hero_card.dart';
import 'package:brain_clean_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget localizedTestApp({required Widget home}) {
  return MaterialApp(
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: supportedLocales,
    localeResolutionCallback: resolveAppLocale,
    home: home,
  );
}

void main() {
  group('Diagnostic UI', () {
    testWidgets('diagnostic screen loads with live BC_score', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: DiagnosticScreen())),
      );
      await tester.pump();

      expect(find.text('Diagnostic 6-Point Test'), findsOneWidget);
      expect(find.text('BRAIN CLARITY SCORE'), findsOneWidget);
      expect(find.textContaining('Live'), findsOneWidget);
      expect(find.text('BHI · BC_score breakdown'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(4));
    });

    testWidgets('dashboard shows empty state without session', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: localizedTestApp(home: const DashboardScreen())),
      );
      await tester.pump();

      expect(find.text('Brain Clean Dashboard'), findsOneWidget);
      expect(
        find.text('Complete the diagnostic to see your BC_score.'),
        findsOneWidget,
      );
      expect(find.text('7-Day Detox Check-in'), findsOneWidget);
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
        ProviderScope(
          overrides: [
            bcScoreSessionProvider.overrideWith(
              () => _FixedSession(session),
            ),
          ],
          child: localizedTestApp(home: const DashboardScreen()),
        ),
      );
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(BcScoreHeroCard),
          matching: find.text('${session.bcScoreRounded}%'),
        ),
        findsOneWidget,
      );
      expect(find.text('BHI · BC_score breakdown'), findsOneWidget);
      expect(find.textContaining('Committed'), findsOneWidget);
    });
  });

  testWidgets('BrainCleanApp boots inside ProviderScope', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BrainCleanApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Diagnostic 6-Point Test'), findsOneWidget);
    expect(find.text('BRAIN CLARITY SCORE'), findsOneWidget);
  });
}

class _FixedSession extends BcScoreSession {
  _FixedSession(this._session);

  final DiagnosticSession _session;

  @override
  DiagnosticSession? build() => _session;
}
