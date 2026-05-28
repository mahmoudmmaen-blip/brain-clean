import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_session.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/widgets/bc_score_breakdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpBreakdown(
    WidgetTester tester, {
    required Locale locale,
    required DiagnosticSession session,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: supportedLocales,
        home: Scaffold(
          body: BcScoreBreakdown.fromSession(session: session),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('BcScoreBreakdown l10n & RTL', () {
    const model = DiagnosticModel(
      brainPerformance: 80,
      digitalDiscipline: 75,
      healthyHabits: 70,
      consistency: 65,
    );

  testWidgets('English LTR shows accountability equation labels', (tester) async {
      final session = DiagnosticSession.fromAssessment(
        model: model,
        metrics: const DiagnosticMetrics(),
        brainRot: DiagnosticModel.evaluateBrainRot(List<bool>.filled(10, false)),
        brainRotAnswers: List<bool>.filled(10, false),
      ).withRecoveryPenaltyTotal(15);

      await pumpBreakdown(tester, locale: const Locale('en'), session: session);

      final loc = lookupAppLocalizations(const Locale('en'));
      expect(find.text(loc.accountabilityAdjustment), findsOneWidget);
      expect(find.text(loc.bhiScoreLabel), findsOneWidget);
      expect(find.text(loc.finalBcScoreLabel), findsWidgets);
    });

    testWidgets('Arabic RTL shows localized accountability labels', (tester) async {
      final session = DiagnosticSession.fromAssessment(
        model: model,
        metrics: const DiagnosticMetrics(),
        brainRot: DiagnosticModel.evaluateBrainRot(List<bool>.filled(10, false)),
        brainRotAnswers: List<bool>.filled(10, false),
      ).withRecoveryPenaltyTotal(15);

      await pumpBreakdown(tester, locale: const Locale('ar'), session: session);

      expect(Directionality.of(tester.element(find.byType(BcScoreBreakdown))),
          TextDirection.rtl);

      final loc = lookupAppLocalizations(const Locale('ar'));
      expect(find.text(loc.accountabilityAdjustment), findsOneWidget);
      expect(find.text(loc.bhiScoreLabel), findsOneWidget);
    });
  });
}
