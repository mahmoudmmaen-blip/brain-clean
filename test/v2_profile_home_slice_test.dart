import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/features/profile/ui/v2_profile_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/localized_test_app.dart';

void main() {
  group('V2 Profile control center hierarchy', () {
    testWidgets('identity first, then grouped controls; no Today/Plan/Progress',
        (tester) async {
      final loc = AppLocalizationsEn();
      var brain = false;
      var settings = false;
      var premium = false;
      var safa = false;

      await tester.pumpWidget(
        createLocalizedTestWidget(
          Scaffold(
            body: V2ProfileHomeBody(
              loc: loc,
              displayName: 'Alex',
              loadingSetup: false,
              hasBrainProfile: true,
              appVersion: '2.0.0-test',
              onOpenBrainProfile: () => brain = true,
              onOpenSettings: () => settings = true,
              onOpenPremium: () => premium = true,
              onOpenSafa: () => safa = true,
            ),
          ),
        ),
      );
      await tester.pump();

      final identity = find.byKey(const Key('v2_profile_identity'));
      final recovery = find.byKey(const Key('v2_profile_brain_profile_row'));
      final prefs = find.byKey(const Key('v2_profile_preferences_row'));
      final privacy = find.byKey(const Key('v2_profile_privacy_row'));
      final sub = find.byKey(const Key('v2_profile_premium_row'));
      final help = find.byKey(const Key('v2_profile_safa_row'));
      final version = find.byKey(const Key('v2_profile_version_row'));

      expect(identity, findsOneWidget);
      expect(tester.getTopLeft(identity).dy < tester.getTopLeft(recovery).dy,
          isTrue);
      expect(
          tester.getTopLeft(recovery).dy < tester.getTopLeft(prefs).dy, isTrue);
      expect(
          tester.getTopLeft(prefs).dy < tester.getTopLeft(privacy).dy, isTrue);
      expect(tester.getTopLeft(privacy).dy < tester.getTopLeft(sub).dy, isTrue);
      expect(tester.getTopLeft(sub).dy < tester.getTopLeft(help).dy, isTrue);
      expect(
          tester.getTopLeft(help).dy < tester.getTopLeft(version).dy, isTrue);

      expect(find.text(loc.v2ProfileSectionRecovery), findsOneWidget);
      expect(find.text(loc.v2ProfileSectionPreferences), findsOneWidget);
      expect(find.text(loc.v2ProfileSectionPrivacy), findsOneWidget);
      expect(find.text(loc.v2ProfileSectionSubscription), findsOneWidget);
      expect(find.text(loc.v2ProfileSectionHelp), findsOneWidget);
      expect(find.text(loc.v2ProfileSectionAbout), findsOneWidget);
      expect(find.text('2.0.0-test'), findsOneWidget);

      expect(find.textContaining('Start Session'), findsNothing);
      expect(find.textContaining('Continue Session'), findsNothing);
      expect(find.textContaining('Main Focus'), findsNothing);
      expect(find.textContaining('Weekly Review'), findsNothing);
      expect(find.textContaining('XP'), findsNothing);
      expect(find.textContaining('streak'), findsNothing);

      await tester.tap(recovery);
      await tester.pump();
      expect(brain, isTrue);
      await tester.tap(prefs);
      await tester.pump();
      expect(settings, isTrue);
      await tester.ensureVisible(sub);
      await tester.tap(sub);
      await tester.pump();
      expect(premium, isTrue);
      await tester.ensureVisible(help);
      await tester.tap(help);
      await tester.pump();
      expect(safa, isTrue);
    });

    testWidgets('Arabic RTL labels and hierarchy', (tester) async {
      final loc = AppLocalizationsAr();
      await tester.pumpWidget(
        createLocalizedTestWidget(
          Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: V2ProfileHomeBody(
                loc: loc,
                displayName: loc.v2ProfileDefaultIdentity,
                loadingSetup: false,
                hasBrainProfile: false,
                appVersion: '1.0.0',
                onOpenBrainProfile: () {},
                onOpenSettings: () {},
                onOpenPremium: () {},
                onOpenSafa: () {},
              ),
            ),
          ),
          locale: const Locale('ar'),
        ),
      );
      await tester.pump();

      expect(find.text(loc.v2ProfileDefaultIdentity), findsOneWidget);
      expect(find.text(loc.v2ProfileSectionRecovery), findsOneWidget);
      expect(find.text(loc.v2ProfileBrainProfileMissing), findsOneWidget);
      expect(find.text(loc.v2ProfileOrientation), findsOneWidget);
      expect(find.textContaining('v2Profile'), findsNothing);
    });

    testWidgets('narrow 320dp + TextScaler 2.0 scrolls without overflow',
        (tester) async {
      final loc = AppLocalizationsEn();
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        createLocalizedTestWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(2.0),
            ),
            child: Scaffold(
              body: V2ProfileHomeBody(
                loc: loc,
                displayName: loc.v2ProfileDefaultIdentity,
                loadingSetup: false,
                hasBrainProfile: true,
                appVersion: '9.9.9',
                onOpenBrainProfile: () {},
                onOpenSettings: () {},
                onOpenPremium: () {},
                onOpenSafa: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      await tester
          .ensureVisible(find.byKey(const Key('v2_profile_version_row')));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('v2_profile_identity')), findsOneWidget);
    });

    testWidgets('TextScaler 1.3 keeps rows tappable', (tester) async {
      final loc = AppLocalizationsEn();
      await tester.binding.setSurfaceSize(const Size(411, 891));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        createLocalizedTestWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(411, 891),
              textScaler: TextScaler.linear(1.3),
            ),
            child: Scaffold(
              body: V2ProfileHomeBody(
                loc: loc,
                displayName: 'Sam',
                loadingSetup: false,
                hasBrainProfile: true,
                appVersion: '1.2.3',
                onOpenBrainProfile: () {},
                onOpenSettings: () {},
                onOpenPremium: () {},
                onOpenSafa: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      final tile =
          tester.getSize(find.byKey(const Key('v2_profile_preferences_row')));
      expect(tile.height, greaterThanOrEqualTo(48));
    });
  });
}
