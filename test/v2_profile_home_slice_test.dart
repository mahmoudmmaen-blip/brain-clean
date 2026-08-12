import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/services/external_link_service.dart';
import 'package:brain_clean_mobile/features/profile/ui/v2_profile_home_screen.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_setup_recovery.dart';
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
      VoidCallback? onOpenBrainProfile,
      bool hasBrainProfile = true,
      String? subscription,
    }) {
      return Scaffold(
        body: V2ProfileHomeBody(
          loc: loc,
          displayName: 'Alex',
          loadingSetup: false,
          hasBrainProfile: hasBrainProfile,
          subscriptionSubtitle: subscription ?? 'You are on the Free core',
          appVersion: '2.0.0-test',
          onEditDisplayName: onEdit ?? () {},
          onOpenBrainProfile: onOpenBrainProfile ?? () {},
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
      expect(find.text(loc.v2ProfileSectionPrivacy), findsNothing);
      expect(find.byKey(const Key('v2_profile_settings_row')), findsOneWidget);
      expect(find.byKey(const Key('v2_profile_privacy_row')), findsNothing);
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

    testWidgets(
        'single Settings gateway remains; Brain Profile Premium Safa intact',
        (tester) async {
      final loc = AppLocalizationsEn();
      var settings = false;
      var brain = false;
      var premium = false;
      var safa = false;
      await tester.pumpWidget(
        createLocalizedTestWidget(
          profileBody(
            loc: loc,
            hasBrainProfile: true,
            onOpenBrainProfile: () => brain = true,
            onEdit: () {},
            onPrivacyPolicy: () {},
            onContact: () {},
          ),
        ),
      );
      // Rebuild with wired callbacks via local body.
      await tester.pumpWidget(
        createLocalizedTestWidget(
          Scaffold(
            body: V2ProfileHomeBody(
              loc: loc,
              displayName: 'Alex',
              loadingSetup: false,
              hasBrainProfile: true,
              subscriptionSubtitle: loc.v2PremiumFreeStatus,
              appVersion: '2.0.0-test',
              onEditDisplayName: () {},
              onOpenBrainProfile: () => brain = true,
              onOpenSettings: () => settings = true,
              onOpenPremium: () => premium = true,
              onOpenSafa: () => safa = true,
              onOpenPrivacyPolicy: () {},
              onOpenContact: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('v2_profile_settings_row')), findsOneWidget);
      expect(find.byKey(const Key('v2_profile_privacy_row')), findsNothing);
      await tester.tap(find.byKey(const Key('v2_profile_settings_row')));
      await tester.pump();
      expect(settings, isTrue);
      await tester.tap(find.byKey(const Key('v2_profile_brain_profile_row')));
      await tester.pump();
      expect(brain, isTrue);
      await tester
          .ensureVisible(find.byKey(const Key('v2_profile_premium_row')));
      await tester.tap(find.byKey(const Key('v2_profile_premium_row')));
      await tester.pump();
      expect(premium, isTrue);
      await tester.ensureVisible(find.byKey(const Key('v2_profile_safa_row')));
      await tester.tap(find.byKey(const Key('v2_profile_safa_row')));
      await tester.pump();
      expect(safa, isTrue);
    });

    testWidgets('missing ProfilePack row starts Brain Check, not reveal',
        (tester) async {
      final loc = AppLocalizationsEn();
      var opened = '';
      await tester.pumpWidget(
        createLocalizedTestWidget(
          profileBody(
            loc: loc,
            hasBrainProfile: false,
            onOpenBrainProfile: () {
              opened = V2SetupRecovery.profileBrainActionLocation(
                hasProfilePack: false,
              );
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.text(loc.v2ProfileBrainProfileMissing), findsOneWidget);
      await tester.tap(find.byKey(const Key('v2_profile_brain_profile_row')));
      await tester.pump();
      expect(opened, '/v2/check?mode=lite&source=profile');
      expect(opened, isNot(AppRoutes.v2BrainProfile));
    });

    testWidgets('existing ProfilePack row keeps Brain Profile reveal',
        (tester) async {
      final loc = AppLocalizationsEn();
      var opened = '';
      await tester.pumpWidget(
        createLocalizedTestWidget(
          profileBody(
            loc: loc,
            hasBrainProfile: true,
            onOpenBrainProfile: () {
              opened = V2SetupRecovery.profileBrainActionLocation(
                hasProfilePack: true,
              );
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.text(loc.v2ProfileBrainProfileReady), findsOneWidget);
      await tester.tap(find.byKey(const Key('v2_profile_brain_profile_row')));
      await tester.pump();
      expect(opened, AppRoutes.v2BrainProfile);
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
      expect(find.text(loc.v2ProfilePreferencesHint), findsOneWidget);
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
    test('privacy and contact URIs are configured; terms URL absent', () {
      expect(ExternalLinkService.privacyPolicyUrl, startsWith('https://'));
      expect(ExternalLinkService.contactEmailUri, startsWith('mailto:'));
      expect(ExternalLinkService.termsOfUseUrl, isNull);
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
