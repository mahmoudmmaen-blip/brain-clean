import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/features/v2_shell/ui/v2_exercises_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child, {Locale locale = const Locale('ar')}) {
    return ProviderScope(
      child: MaterialApp(
        locale: locale,
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

  testWidgets('shows free and pro sections with filter pills at 320px RTL',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrap(const Directionality(
        textDirection: TextDirection.rtl,
        child: V2ExercisesLibraryScreen(),
      )),
    );
    await tester.pump();

    expect(find.text('مكتبة التمارين'), findsOneWidget);
    expect(find.text('مجاني'), findsOneWidget);
    expect(find.text('Pro'), findsWidgets);
    expect(find.text('N-Back'), findsOneWidget);
    expect(find.text('اختبار سترووب'), findsOneWidget);
    expect(find.text('مدى الأرقام'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);

    expect(tester.takeException(), isNull);
  });

  testWidgets('memory filter hides stroop and shows n-back + digit span',
      (tester) async {
    await tester.pumpWidget(
      wrap(const V2ExercisesLibraryScreen(), locale: const Locale('en')),
    );
    await tester.pump();

    await tester.tap(find.text('Memory'));
    await tester.pump();

    expect(find.text('N-Back'), findsOneWidget);
    expect(find.text('Stroop test'), findsNothing);
    expect(find.text('Digit span'), findsOneWidget);
  });
}
