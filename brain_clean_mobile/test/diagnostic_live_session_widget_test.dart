import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/diagnostic_screen.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/widgets/brain_rot_questionnaire_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/diagnostic_provider_overrides.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/test_l10n.dart';

void main() {
  final en = testL10n;
  final ar = testL10nAr;

  group('Live Session × Brain Rot Flow (widget matrix)', () {
    Future<void> pumpDiagnostic(
      WidgetTester tester, {
      required Locale locale,
    }) async {
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const DiagnosticScreen(),
          locale: locale,
          overrides: diagnosticInteractiveOverrides(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    Future<void> tapYes(WidgetTester tester, AppLocalizations loc) async {
      await tester.tap(find.text(loc.diagnosticYes));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
    }

    testWidgets(
      'English LTR: flow provider advances live session question stream',
      (tester) async {
        await pumpDiagnostic(tester, locale: const Locale('en'));

        expect(Directionality.of(tester.element(find.byType(DiagnosticScreen))),
            TextDirection.ltr);
        expect(find.text(en.diagnosticBrainRotTitle), findsOneWidget);
        expect(find.text(en.diagnosticBrainRotQ1), findsOneWidget);
        expect(find.text(en.diagnosticYes), findsOneWidget);
        expect(find.text(en.diagnosticNo), findsOneWidget);
        expect(find.byType(BrainRotQuestionnaireView), findsOneWidget);

        await tapYes(tester, en);

        expect(find.text(en.diagnosticBrainRotQ1), findsNothing);
        expect(find.text(en.diagnosticBrainRotQ2), findsOneWidget);
        expect(find.text(en.diagnosticYes), findsOneWidget);
      },
    );

    testWidgets(
      'Arabic RTL: localized response stream renders with correct direction',
      (tester) async {
        await pumpDiagnostic(tester, locale: const Locale('ar'));

        final screen = find.byType(DiagnosticScreen);
        expect(Directionality.of(tester.element(screen)), TextDirection.rtl);
        expect(find.text(ar.diagnosticBrainRotTitle), findsOneWidget);
        expect(find.text(BrainRotTest.questionsAr[0]), findsOneWidget);
        expect(find.text(ar.diagnosticYes), findsOneWidget);
        expect(find.text(ar.diagnosticNo), findsOneWidget);

        await tapYes(tester, ar);

        expect(find.text(BrainRotTest.questionsAr[0]), findsNothing);
        expect(find.text(BrainRotTest.questionsAr[1]), findsOneWidget);
        expect(find.text(ar.diagnosticYes), findsOneWidget);
      },
    );

    testWidgets(
      'multi-answer flow keeps live session coherent through provider',
      (tester) async {
        await pumpDiagnostic(tester, locale: const Locale('en'));

        await tapYes(tester, en);
        expect(find.text(en.diagnosticBrainRotQ2), findsOneWidget);

        await tester.tap(find.text(en.diagnosticNo));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 450));

        expect(find.text(en.diagnosticBrainRotQ3), findsOneWidget);
        expect(find.text(en.diagnosticBrainRotQ2), findsNothing);
      },
    );
  });
}
