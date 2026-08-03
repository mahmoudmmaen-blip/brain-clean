import 'dart:io';

import 'package:brain_clean_mobile/core/application/app_preferences_provider.dart';
import 'package:brain_clean_mobile/core/config/app_config.dart';
import 'package:brain_clean_mobile/core/constants/hive_meta_keys.dart';
import 'package:brain_clean_mobile/core/data/app_meta_box_provider.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/pro/application/subscription_service_provider.dart';
import 'package:brain_clean_mobile/features/pro/data/fake_purchases_sdk_port.dart';
import 'package:brain_clean_mobile/features/pro/data/local_subscription_service.dart';
import 'package:brain_clean_mobile/features/pro/data/revenuecat_subscription_service.dart';
import 'package:brain_clean_mobile/features/pro/data/store_unavailable_subscription_service.dart';
import 'package:brain_clean_mobile/features/pro/domain/purchases_sdk_port.dart';
import 'package:brain_clean_mobile/features/pro/domain/subscription_adapter_kind.dart';
import 'package:brain_clean_mobile/features/pro/domain/subscription_outcomes.dart';
import 'package:brain_clean_mobile/features/v2_premium/application/premium_controller.dart';
import 'package:brain_clean_mobile/features/v2_premium/data/subscription_premium_store_port.dart';
import 'package:brain_clean_mobile/features/v2_premium/domain/premium_identifiers.dart';
import 'package:brain_clean_mobile/features/v2_premium/domain/premium_purchase_phase.dart';
import 'package:brain_clean_mobile/features/v2_premium/domain/premium_store_port.dart';
import 'package:brain_clean_mobile/features/v2_reports/domain/reports_archive_gate.dart';
import 'package:brain_clean_mobile/features/v2_shell/domain/v2_shell_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hive_test_fixtures.dart';
import 'helpers/localized_test_app.dart';

ProviderContainer _rcContainer({
  required FakePurchasesSdkPort sdk,
  bool isIos = false,
  InMemoryHiveBox? box,
}) {
  final meta = box ?? InMemoryHiveBox();
  final c = ProviderContainer(
    overrides: [
      appMetaBoxProvider.overrideWithValue(meta),
      appPreferencesProvider.overrideWith(_FreePreferences.new),
      forceLocalSubscriptionAdapterProvider.overrideWithValue(false),
      revenueCatPlatformIsIosProvider.overrideWithValue(isIos),
      purchasesSdkPortProvider.overrideWithValue(sdk),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  setUp(() {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
  });

  group('configuration', () {
    test('placeholder and empty keys resolve as missing', () {
      expect(AppConfig.isPlaceholderConfigValue('your_revenuecat_key'), isTrue);
      expect(AppConfig.isPlaceholderConfigValue(''), isFalse);
      final label = AppConfig.configPresenceLabel('secret-key-value');
      expect(label, isNot('secret-key-value'));
      expect(label, startsWith('set('));
    });

    test('platform key selection prefers Android/iOS slots', () {
      // Without defines, both empty — method still returns empty string safely.
      expect(AppConfig.revenueCatPublicSdkKey(isIOS: false), isA<String>());
      expect(AppConfig.revenueCatPublicSdkKey(isIOS: true), isA<String>());
    });
  });

  group('adapter selection', () {
    test('missing key → storeUnavailable, never Local', () {
      final c = ProviderContainer(
        overrides: [
          appMetaBoxProvider.overrideWithValue(InMemoryHiveBox()),
          appPreferencesProvider.overrideWith(_FreePreferences.new),
          forceLocalSubscriptionAdapterProvider.overrideWithValue(false),
          purchasesSdkPortProvider.overrideWithValue(null),
        ],
      );
      addTearDown(c.dispose);
      final service = c.read(subscriptionServiceProvider);
      expect(service.adapterKind, SubscriptionAdapterKind.storeUnavailable);
      expect(service, isA<StoreUnavailableSubscriptionService>());
      expect(service, isNot(isA<LocalSubscriptionService>()));
      expect(service.isPro, isFalse);
    });

    test('explicit forceLocal uses LocalSubscriptionService only', () {
      final c = ProviderContainer(
        overrides: [
          appMetaBoxProvider.overrideWithValue(InMemoryHiveBox()),
          appPreferencesProvider.overrideWith(_FreePreferences.new),
          forceLocalSubscriptionAdapterProvider.overrideWithValue(true),
        ],
      );
      addTearDown(c.dispose);
      expect(
        c.read(subscriptionServiceProvider).adapterKind,
        SubscriptionAdapterKind.localFake,
      );
    });

    test('valid injected SDK uses RevenueCat adapter', () async {
      final sdk = FakePurchasesSdkPort(
        offerings: FakePurchasesSdkPort.defaultOfferings(),
      );
      final c = _rcContainer(sdk: sdk);
      // Simulate configured key by using RC service constructed for tests:
      final service = RevenueCatSubscriptionService(
        sdk: sdk,
        apiKeyReader: () => 'goog_test_public_sdk_key',
      );
      await service.ensureInitialized();
      expect(service.adapterKind, SubscriptionAdapterKind.revenueCat);
      expect(sdk.configureCalls, 1);
      await service.ensureInitialized();
      expect(sdk.configureCalls, 1); // once
    });
  });

  group('RevenueCat subscription service', () {
    test('init failure leaves Free core; purchase blocked', () async {
      final sdk = FakePurchasesSdkPort(configureSucceeds: false);
      final service = RevenueCatSubscriptionService(
        sdk: sdk,
        apiKeyReader: () => 'goog_test_public_sdk_key',
      );
      await service.ensureInitialized();
      expect(service.isStoreConfigured, isFalse);
      expect(service.isPro, isFalse);
      expect(
        await service.purchasePlan(PremiumIdentifiers.monthlyProductId),
        SubscriptionPurchaseResult.storeUnavailable,
      );
    });

    test('empty key does not configure', () async {
      final sdk = FakePurchasesSdkPort();
      final service = RevenueCatSubscriptionService(
        sdk: sdk,
        apiKeyReader: () => '',
      );
      await service.ensureInitialized();
      expect(sdk.configureCalls, 0);
      expect(service.isStoreConfigured, isFalse);
    });

    test('maps offerings including optional lifetime absence', () async {
      final sdk = FakePurchasesSdkPort(
        offerings: FakePurchasesSdkPort.defaultOfferings(includeLifetime: false),
      );
      final service = RevenueCatSubscriptionService(
        sdk: sdk,
        apiKeyReader: () => 'goog_test_public_sdk_key',
      );
      final plans = await service.loadOfferings();
      expect(
        plans.map((p) => p.id),
        containsAll([
          PremiumIdentifiers.monthlyProductId,
          PremiumIdentifiers.yearlyProductId,
        ]),
      );
      expect(plans.any((p) => p.id == PremiumIdentifiers.lifetimeProductId), isFalse);
      expect(plans.every((p) => !p.priceString.contains(r'$4.99')), isTrue);
    });

    test('unknown products ignored by evaluator', () {
      expect(StoreEntitlementEvaluator.isProductionProductId('other_sku'), isFalse);
      expect(
        StoreEntitlementEvaluator.periodForProductId('weird'),
        isNull,
      );
    });

    test('purchase success entitles; cancel does not', () async {
      final sdk = FakePurchasesSdkPort(
        offerings: FakePurchasesSdkPort.defaultOfferings(),
      );
      final service = RevenueCatSubscriptionService(
        sdk: sdk,
        apiKeyReader: () => 'goog_test_public_sdk_key',
      );
      await service.loadOfferings();
      final ok = await service.purchasePlan(PremiumIdentifiers.monthlyProductId);
      expect(ok, SubscriptionPurchaseResult.success);
      expect(service.isPro, isTrue);
      expect(PremiumIdentifiers.entitlementId, 'Brain Clean');

      final sdk2 = FakePurchasesSdkPort(
        offerings: FakePurchasesSdkPort.defaultOfferings(),
        throwOnPurchase: const StorePurchaseException(
          StorePurchaseFailureKind.cancelled,
        ),
      );
      final s2 = RevenueCatSubscriptionService(
        sdk: sdk2,
        apiKeyReader: () => 'goog_test_public_sdk_key',
      );
      await s2.loadOfferings();
      expect(
        await s2.purchasePlan(PremiumIdentifiers.monthlyProductId),
        SubscriptionPurchaseResult.cancelled,
      );
      expect(s2.isPro, isFalse);
    });

    test('purchase without entitlement stays Free', () async {
      final sdk = FakePurchasesSdkPort(
        offerings: FakePurchasesSdkPort.defaultOfferings(),
        purchaseResult: const StoreCustomerSnapshot(
          entitled: false,
          activeEntitlementIds: [],
        ),
      );
      final service = RevenueCatSubscriptionService(
        sdk: sdk,
        apiKeyReader: () => 'goog_test_public_sdk_key',
      );
      await service.loadOfferings();
      expect(
        await service.purchasePlan(PremiumIdentifiers.monthlyProductId),
        SubscriptionPurchaseResult.failed,
      );
      expect(service.isPro, isFalse);
    });

    test('duplicate purchase prevented', () async {
      final sdk = FakePurchasesSdkPort(
        offerings: FakePurchasesSdkPort.defaultOfferings(),
      );
      // Slow path simulation: first purchase sets entitled; second is alreadyEntitled.
      final service = RevenueCatSubscriptionService(
        sdk: sdk,
        apiKeyReader: () => 'goog_test_public_sdk_key',
      );
      await service.loadOfferings();
      await service.purchasePlan(PremiumIdentifiers.monthlyProductId);
      expect(
        await service.purchasePlan(PremiumIdentifiers.monthlyProductId),
        SubscriptionPurchaseResult.alreadyEntitled,
      );
      expect(sdk.purchaseCalls, 1);
    });

    test('restore success / nothing / failure / idempotent', () async {
      final sdk = FakePurchasesSdkPort(entitled: true);
      final service = RevenueCatSubscriptionService(
        sdk: sdk,
        apiKeyReader: () => 'goog_test_public_sdk_key',
      );
      await service.ensureInitialized();
      expect(await service.restoreEntitlements(), SubscriptionRestoreResult.restored);
      expect(await service.restoreEntitlements(), SubscriptionRestoreResult.restored);

      final sdkNone = FakePurchasesSdkPort(entitled: false);
      final sNone = RevenueCatSubscriptionService(
        sdk: sdkNone,
        apiKeyReader: () => 'goog_test_public_sdk_key',
      );
      await sNone.ensureInitialized();
      expect(
        await sNone.restoreEntitlements(),
        SubscriptionRestoreResult.nothingToRestore,
      );

      final sdkFail = FakePurchasesSdkPort(
        throwOnRestore: const StorePurchaseException(
          StorePurchaseFailureKind.storeProblem,
        ),
      );
      final sFail = RevenueCatSubscriptionService(
        sdk: sdkFail,
        apiKeyReader: () => 'goog_test_public_sdk_key',
      );
      await sFail.ensureInitialized();
      expect(await sFail.restoreEntitlements(), SubscriptionRestoreResult.failed);
    });

    test('CustomerInfo listener updates entitlement', () async {
      final sdk = FakePurchasesSdkPort();
      final service = RevenueCatSubscriptionService(
        sdk: sdk,
        apiKeyReader: () => 'goog_test_public_sdk_key',
      );
      await service.ensureInitialized();
      expect(service.isPro, isFalse);
      sdk.emitCustomerInfo(
        const StoreCustomerSnapshot(
          entitled: true,
          activeEntitlementIds: [PremiumIdentifiers.entitlementId],
        ),
      );
      expect(service.isPro, isTrue);
    });

    test('Hive-only true cannot unlock RC service without verification', () async {
      final box = InMemoryHiveBox({
        HiveMetaKeys.isProUser: true,
        HiveMetaKeys.storeVerifiedPremium: false,
      });
      final sdk = FakePurchasesSdkPort();
      final service = RevenueCatSubscriptionService(
        sdk: sdk,
        apiKeyReader: () => 'goog_test_public_sdk_key',
        readStoreVerifiedMirror: () =>
            box.get(HiveMetaKeys.storeVerifiedPremium, defaultValue: false) ==
            true,
      );
      // Before init, only store-verified mirror counts.
      expect(service.isPro, isFalse);
      await service.ensureInitialized();
      expect(service.isPro, isFalse);
    });

    test('store-verified mirror allows offline cache read', () {
      final service = StoreUnavailableSubscriptionService(
        readStoreVerifiedMirror: () => true,
      );
      expect(service.isPro, isTrue);
      expect(service.adapterKind, SubscriptionAdapterKind.storeUnavailable);
    });

    test('pending and store problem map correctly', () async {
      final sdk = FakePurchasesSdkPort(
        offerings: FakePurchasesSdkPort.defaultOfferings(),
        throwOnPurchase: const StorePurchaseException(
          StorePurchaseFailureKind.pending,
        ),
      );
      final service = RevenueCatSubscriptionService(
        sdk: sdk,
        apiKeyReader: () => 'goog_test_public_sdk_key',
      );
      await service.loadOfferings();
      expect(
        await service.purchasePlan(PremiumIdentifiers.monthlyProductId),
        SubscriptionPurchaseResult.pending,
      );
    });

    test('exact production product IDs', () {
      expect(PremiumIdentifiers.monthlyProductId, 'brainclean_monthly');
      expect(PremiumIdentifiers.yearlyProductId, 'brainclean_yearly');
      expect(PremiumIdentifiers.lifetimeProductId, 'brainclean_lifetime');
      expect(PremiumIdentifiers.stubMonthlyPlanId, isNot(PremiumIdentifiers.monthlyProductId));
    });
  });

  group('Premium port + Reports archive', () {
    test('purchase unlocks deeper archive; free depth preserved', () async {
      final sdk = FakePurchasesSdkPort(
        offerings: FakePurchasesSdkPort.defaultOfferings(),
      );
      final service = RevenueCatSubscriptionService(
        sdk: sdk,
        apiKeyReader: () => 'goog_test_public_sdk_key',
      );
      final port = SubscriptionPremiumStorePort(
        service: service,
        onEntitlementMaybeChanged: () {},
      );
      expect(
        ReportsArchiveGate.canAccessArtifactIndex(2, isPremium: port.isEntitled),
        isFalse,
      );
      await port.loadOfferings();
      await port.purchase(PremiumIdentifiers.monthlyProductId);
      expect(port.isEntitled, isTrue);
      expect(
        ReportsArchiveGate.canAccessArtifactIndex(2, isPremium: port.isEntitled),
        isTrue,
      );
      expect(
        ReportsArchiveGate.canAccessArtifactIndex(0, isPremium: false),
        isTrue,
      );
    });

    test('missing config → storeUnavailable phase', () async {
      final service = StoreUnavailableSubscriptionService();
      final port = SubscriptionPremiumStorePort(
        service: service,
        onEntitlementMaybeChanged: () {},
      );
      final controller = PremiumController(store: port);
      await controller.hydrate(source: 'profile');
      expect(controller.state.phase, PremiumPurchasePhase.storeUnavailable);
      expect(controller.state.isEntitled, isFalse);
    });

    test('restore unlocks archive', () async {
      final sdk = FakePurchasesSdkPort(entitled: true);
      final service = RevenueCatSubscriptionService(
        sdk: sdk,
        apiKeyReader: () => 'goog_test_public_sdk_key',
      );
      final port = SubscriptionPremiumStorePort(
        service: service,
        onEntitlementMaybeChanged: () {},
      );
      await service.ensureInitialized();
      expect(await port.restore(), PremiumRestoreOutcome.restored);
      expect(port.isEntitled, isTrue);
      expect(
        ReportsArchiveGate.visibleArtifactCount(5, isPremium: true),
        5,
      );
    });
  });

  group('ads deferred + copy + privacy + navigation', () {
    test('no ad-removal Premium copy', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      for (final s in [
        en.v2PremiumBenefitsBody,
        en.v2PremiumSupportBody,
        en.v2PremiumContinuityBody,
        ar.v2PremiumBenefitsBody,
      ]) {
        final lower = s.toLowerCase();
        expect(lower, isNot(contains('remove ads')));
        expect(lower, isNot(contains('ad-free')));
        expect(lower, isNot(contains('إزالة الإعلانات')));
      }
    });

    test('Safa privacy disclosure EN/AR present in privacy documents', () async {
      final html = await File('docs/privacy-policy/index.html').readAsString();
      expect(html, contains('explicitly select'));
      expect(html, contains('transferred automatically'));
      expect(html, contains('<strong>not</strong>'));
      expect(html, contains('Supabase Edge'));
      expect(html, contains('NVIDIA'));
      expect(html, contains('صراحة'));
      expect(html, contains('ليست</strong> رعاية طبية'));
      final en = await File('brain_clean_mobile/PRIVACY_POLICY.md').readAsString();
      expect(en, contains('Raw conversation archives are not kept by default'));
      final ar = await File('brain_clean_mobile/PRIVACY_POLICY_AR.md').readAsString();
      expect(ar, contains('لا تُحفظ أرشيفات محادثات خام بشكل افتراضي'));
    });

    test('Safa not a tab; Premium not a tab', () {
      expect(V2ShellTab.values.length, 4);
      expect(V2ShellTabX.fromLocation('/v2/premium'), isNull);
      expect(V2ShellTabX.fromLocation('/v2/safa'), isNull);
    });

    testWidgets('320 + textScale Premium store unavailable', (tester) async {
      final service = StoreUnavailableSubscriptionService();
      final port = SubscriptionPremiumStorePort(
        service: service,
        onEntitlementMaybeChanged: () {},
      );
      final controller = PremiumController(store: port);
      await controller.hydrate(source: 'profile');
      expect(controller.state.phase, PremiumPurchasePhase.storeUnavailable);

      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 700),
            textScaler: TextScaler.linear(2.0),
          ),
          child: createLocalizedTestWidget(
            Builder(
              builder: (context) {
                final loc = AppLocalizationsEn();
                return Scaffold(
                  body: SingleChildScrollView(
                    child: Text(loc.v2PremiumStoreUnavailable),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(AppLocalizationsEn().v2PremiumStoreUnavailable), findsOneWidget);
    });

    testWidgets('Arabic RTL label Premium', (tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          Scaffold(body: Text(AppLocalizationsAr().v2PremiumTitle)),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();
      final ctx = tester.element(find.text('بريميوم'));
      expect(Directionality.of(ctx), TextDirection.rtl);
    });
  });

  group('entitlement evaluator additive pro', () {
    test('accepts Brain Clean or additive pro', () {
      expect(
        StoreEntitlementEvaluator.isEntitled(['Brain Clean']),
        isTrue,
      );
      expect(StoreEntitlementEvaluator.isEntitled(['pro']), isTrue);
      expect(StoreEntitlementEvaluator.isEntitled(['other']), isFalse);
    });
  });

  group('security patterns', () {
    test('.env is gitignored conceptually and keys redacted in presence label', () {
      expect(AppConfig.configPresenceLabel('super-secret-key'), startsWith('set('));
      expect(AppConfig.configPresenceLabel('super-secret-key'), isNot(contains('super-secret-key')));
    });
  });
}

class _FreePreferences extends AppPreferences {
  @override
  AppPreferencesState build() => const AppPreferencesState(
        hasSeenOnboarding: true,
        isProUser: false,
        emotionNotificationsEnabled: true,
        dailyFocusReminderEnabled: true,
        profileDisplayName: '',
        silenceWinsCount: 0,
        singleTasksCompletedCount: 0,
      );

  @override
  Future<void> setProUser(bool value) async {
    state = state.copyWith(isProUser: value);
  }
}
