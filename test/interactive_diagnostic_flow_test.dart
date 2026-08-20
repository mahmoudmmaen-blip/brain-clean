import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/features/interactive_diagnostic/application/interactive_diagnostic_controller.dart';
import 'package:brain_clean_mobile/features/interactive_diagnostic/application/interactive_diagnostic_controller_provider.dart';
import 'package:brain_clean_mobile/features/interactive_diagnostic/ui/interactive_diagnostic_flow_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('DiagIntro shows metrics and starts questions', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrap(const Directionality(
        textDirection: TextDirection.rtl,
        child: InteractiveDiagnosticFlowScreen(),
      )),
    );
    await tester.pump();

    expect(find.text('5 أسئلة سريعة'), findsOneWidget);
    expect(find.text('مدى الانتباه'), findsOneWidget);
    expect(find.text('عادات الشاشة'), findsOneWidget);

    await tester.tap(find.text('ابدأ التشخيص'));
    await tester.pumpAndSettle();

    expect(find.textContaining('السؤال 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('controller advances through all questions to result', () {
    final controller = InteractiveDiagnosticController();
    controller.startQuestions();
    for (var i = 0; i < 5; i++) {
      controller.selectAnswer(3);
      controller.advance();
    }
    expect(controller.phase, InteractiveDiagnosticPhase.result);
    expect(controller.result, isNotNull);
    expect(controller.result!.overallPercent, 50);
  });
}
