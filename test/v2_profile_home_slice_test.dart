import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/services/external_link_service.dart';
import 'package:brain_clean_mobile/features/profile/ui/v2_profile_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/localized_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('V2 Profile control center hierarchy', () {
    Widget profileBody({
      required AppLocalizations loc,
      VoidCallback? onEdit,
      VoidCallback? onPrivacyPolicy,
      VoidCallback? onContact,
      String? subscription,
    }) {
      return Scaffold(
        body: V2ProfileHomeBody(
          loc: loc,
          displayName: 'Alex',
          loadingSetup: false,
          hasBrainProfile: true,
          subscriptionSubtitle: subscription ?? 'You are on the Free core',
          appVersion: '2.0.0-test',
          onEditDisplayName: onEdit ?? () {},
          onOpenBrainProfile: () {},
          onOpenSettings: () {},
          onOpenPremium: () {},
          onOpenSafa: () {},
          onOpenPrivacyPolicy: onPrivacyPolicy ?? () {},
          onOpenContact: onContact ?? () {},
        ),
      );
    }

    testWidgets(
        'Phase A hierarchy intact; trust rows wired; no execution dupes',
        (tester) async {
      final loc = AppLocalizationsEn();
      var edit = false;
      var privacy = false;
      var contact = false;

      await tester.pumpWidget(
        createLocalizedTestWidget(
          profileBody(
            loc: loc,
            onEdit: () => edit = true,
            onPrivacyPolicy: () => privacy = true,
            onContact: () => contact = true,
            subscription: loc.v2PremiumFreeStatus,
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('v2_profile_identity')), findsOneWidget);
      expect(find.text(loc.v2ProfileSectionRecovery), findsOneWidget);
      expect(find.text(loc.v2ProfileSectionPreferences), findsOneWidget);
      expect(find.text(loc.v2ProfileSectionPrivacy), findsOneWidget);
      expect(find.text(loc.v2ProfileSectionSubscription), findsOneWidget);
      expect(find.text(loc.v2ProfileSectionHelp), findsOneWidget);
      expect(find.text(loc.v2ProfileSectionAbout), findsOneWidget);
      expect(find.text(loc.v2PremiumFreeStatus), findsOneWidget);
      expect(find.text(loc.settingsPrivacyPolicy), findsOneWidget);
      expect(find.text(loc.settingsContactUs), findsOneWidget);

      expect(find.textContaining('Start Session'), findsNothing);
      expect(find.textContaining('Export my data'), findsNothing);
      expect(find.textContaining('Coming soon'), findsNothing);
      expect(find.textContaining('XP'), findsNothing);

      await tester.tap(find.byKey(const Key('v2_profile_identity')));
      await tester.pump();
      expect(edit, isTrue);

      await tester.ensureVisible(
        find.byKey(const Key('v2_profile_privacy_policy_row')),
      );
      await tester.tap(find.byKey(const Key('v2_profile_privacy_policy_row')));
      await tester.pump();
      expect(privacy, isTrue);

      await tester
          .ensureVisible(find.byKey(const Key('v2_profile_contact_row')));
      await tester.tap(find.byKey(const Key('v2_profile_contact_row')));
      await tester.pump();
      expect(contact, isTrue);
    });

    testWidgets('Arabic RTL trust labels', (tester) async {
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
                subscriptionSubtitle: loc.v2PremiumFreeStatus,
                appVersion: '1.0.0',
                onEditDisplayName: () {},
                onOpenBrainProfile: () {},
                onOpenSettings: () {},
                onOpenPremium: () {},
                onOpenSafa: () {},
                onOpenPrivacyPolicy: () {},
                onOpenContact: () {},
              ),
            ),
          ),
          locale: const Locale('ar'),
        ),
      );
      await tester.pump();
      expect(find.text(loc.settingsPrivacyPolicy), findsOneWidget);
      expect(find.text(loc.v2ProfilePrivacyHint), findsOneWidget);
      expect(find.textContaining('v2Profile'), findsNothing);
    });

    testWidgets('320dp TextScaler 2.0 scrolls About trust rows',
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
            child: profileBody(loc: loc),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('v2_profile_identity')), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const Key('v2_profile_contact_row')),
      );
      await tester.pump();
      expect(find.byKey(const Key('v2_profile_contact_row')), findsOneWidget);
    });
  });

  group('ExternalLinkService', () {
    test('privacy and contact URIs are configured', () {
      expect(ExternalLinkService.privacyPolicyUrl, startsWith('https://'));
      expect(ExternalLinkService.contactEmailUri, startsWith('mailto:'));
    });

    test('openUri invokes platform channel', () async {
      final calls = <MethodCall>[];
      const channel = MethodChannel('com.brainclean.mobile/external_links');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return true;
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      final service = ExternalLinkService(channel: channel);
      final ok = await service.openPrivacyPolicy();
      expect(ok, isTrue);
      expect(calls.single.method, 'openUri');
      expect(
        calls.single.arguments.toString(),
        contains('privacy-policy'),
      );

      calls.clear();
      final contactOk = await service.openContactEmail();
      expect(contactOk, isTrue);
      expect(calls.single.arguments.toString(), contains('mailto:'));
    });
  });
}
