import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/pro/domain/subscription_plan.dart';
import 'package:brain_clean_mobile/features/v2_premium/application/premium_controller.dart';
import 'package:brain_clean_mobile/features/v2_premium/data/premium_controller_provider.dart';
import 'package:brain_clean_mobile/features/v2_premium/domain/premium_eligibility.dart';
import 'package:brain_clean_mobile/features/v2_premium/domain/premium_identifiers.dart';
import 'package:brain_clean_mobile/features/v2_premium/domain/premium_offering.dart';
import 'package:brain_clean_mobile/features/v2_premium/domain/premium_purchase_phase.dart';
import 'package:brain_clean_mobile/features/v2_premium/domain/premium_store_port.dart';
import 'package:brain_clean_mobile/features/v2_premium/ui/premium_overview_screen.dart';
import 'package:brain_clean_mobile/features/v2_premium/ui/premium_plans_screen.dart';
import 'package:brain_clean_mobile/features/v2_premium/ui/premium_status_screen.dart';
import 'package:brain_clean_mobile/features/v2_premium/ui/premium_success_screen.dart';
import 'package:brain_clean_mobile/features/v2_reports/domain/reports_archive_gate.dart';
import 'package:brain_clean_mobile/features/v2_shell/domain/v2_shell_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/localized_test_app.dart';

class FakePremiumStore implements PremiumStorePort {
  FakePremiumStore({
    this.entitled = false,
    this.online = true,
    this.storeConfigured = true,
    this.offerings = const [],
    this.purchaseOutcome = PremiumPurchaseOutcome.success,
    this.restoreOutcome = PremiumRestoreOutcome.nothingToRestore,
    this.throwOnLoad = false,
  });

  bool entitled;
  bool online;
  bool storeConfigured;
  List<PremiumOffering> offerings;
  PremiumPurchaseOutcome purchaseOutcome;
  PremiumRestoreOutcome restoreOutcome;
  bool throwOnLoad;
  int purchaseCalls = 0;
  int restoreCalls = 0;

  @override
  bool get isEntitled => entitled;

  @override
  bool get hasCachedEntitlement => entitled;

  @override
  bool get isOnline => online;

  @override
  bool get isStoreConfigured => storeConfigured;

  @override
  Future<List<PremiumOffering>> loadOfferings() async {
    if (throwOnLoad) throw StateError('store down');
    if (!online) return const [];
    return offerings;
  }

  @override
  Future<PremiumPurchaseOutcome> purchase(String productId) async {
    purchaseCalls++;
    if (entitled) return PremiumPurchaseOutcome.alreadyEntitled;
    if (purchaseOutcome == PremiumPurchaseOutcome.success) {
      entitled = true;
    }
    return purchaseOutcome;
  }

  @override
  Future<PremiumRestoreOutcome> restore() async {
    restoreCalls++;
    if (restoreOutcome == PremiumRestoreOutcome.restored) {
      entitled = true;
    }
    return restoreOutcome;
  }
}

List<PremiumOffering> sampleOfferings({bool withTrial = false}) {
  return [
    PremiumOffering(
      productId: PremiumIdentifiers.monthlyProductId,
      title: 'Monthly',
      priceString: 'SAR 18.99',
      period: SubscriptionPeriod.monthly,
      trialConfirmed: withTrial,
      trialLabel: withTrial ? '7-day trial' : null,
    ),
    PremiumOffering(
      productId: PremiumIdentifiers.yearlyProductId,
      title: 'Annual',
      priceString: 'SAR 149.99',
      period: SubscriptionPeriod.annual,
    ),
    PremiumOffering(
      productId: PremiumIdentifiers.lifetimeProductId,
      title: 'Lifetime',
      priceString: 'SAR 399.99',
      period: SubscriptionPeriod.lifetime,
    ),
  ];
}

GoRouter premiumTestRouter({
  required bool flagOn,
  String initial = AppRoutes.v2Premium,
}) {
  return GoRouter(
    initialLocation: initial,
    redirect: (context, state) {
      final path = state.uri.path;
      if (path.startsWith('/v2/') && !flagOn) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Scaffold(body: Text('V1_HOME')),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const Scaffold(body: Text('SETTINGS')),
      ),
      GoRoute(
        path: AppRoutes.v2Reports,
        builder: (context, state) => const Scaffold(body: Text('REPORTS')),
      ),
      GoRoute(
        path: AppRoutes.v2Profile,
        builder: (context, state) => const Scaffold(body: Text('PROFILE')),
      ),
      GoRoute(
        path: AppRoutes.v2Home,
        builder: (context, state) => const Scaffold(body: Text('TODAY')),
      ),
      GoRoute(
        path: AppRoutes.v2Premium,
        builder: (context, state) {
          final source = state.uri.queryParameters['source'];
          return PremiumOverviewScreen(source: source);
        },
        routes: [
          GoRoute(
            path: 'plans',
            builder: (context, state) => PremiumPlansScreen(
              source: state.uri.queryParameters['source'],
            ),
          ),
          GoRoute(
            path: 'success',
            builder: (context, state) => PremiumSuccessScreen(
              source: state.uri.queryParameters['source'],
            ),
          ),
          GoRoute(
            path: 'status',
            builder: (context, state) => PremiumStatusScreen(
              source: state.uri.queryParameters['source'],
            ),
          ),
          GoRoute(
            path: 'restore',
            builder: (context, state) => PremiumStatusScreen(
              source: state.uri.queryParameters['source'] ?? 'restore',
              autoRestore: true,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget pumpPremiumApp({
  required GoRouter router,
  required FakePremiumStore store,
  PremiumController? controller,
  Locale locale = const Locale('en'),
}) {
  final c = controller ?? PremiumController(store: store);
  return createLocalizedRouterTestWidget(
    router: router,
    locale: locale,
    overrides: [
      premiumStorePortProvider.overrideWithValue(store),
      premiumControllerProvider.overrideWithValue(c),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
  });

  tearDown(() {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
  });

  group('Contract constants / eligibility', () {
    test('entitlement and product identifiers preserved', () {
      expect(PremiumIdentifiers.entitlementId, 'Brain Clean');
      expect(PremiumIdentifiers.monthlyProductId, 'brainclean_monthly');
      expect(PremiumIdentifiers.yearlyProductId, 'brainclean_yearly');
      expect(PremiumIdentifiers.lifetimeProductId, 'brainclean_lifetime');
    });

    test('Pro is a shell tab; contextual /v2/premium remains separate', () {
      expect(V2ShellTab.values.map((e) => e.name), contains('pro'));
      expect(V2ShellPaths.roots, contains('/v2/pro'));
      expect(V2ShellTabX.fromLocation('/v2/premium'), isNull);
      expect(V2ShellPaths.isKnownV2Location('/v2/premium'), isTrue);
      expect(V2ShellPaths.isKnownV2Location('/v2/premium/plans'), isTrue);
    });

    test('forbidden auto sources blocked; explicit allowed', () {
      expect(PremiumEligibility.allowsExplicitEntry('profile'), isTrue);
      expect(PremiumEligibility.allowsExplicitEntry('reports_archive'), isTrue);
      expect(PremiumEligibility.allowsExplicitEntry('settings'), isTrue);
      expect(PremiumEligibility.allowsExplicitEntry('pro_gate'), isTrue);
      expect(PremiumEligibility.allowsExplicitEntry('legacy_paywall'), isTrue);
      expect(PremiumEligibility.allowsExplicitEntry('theme'), isTrue);
      expect(PremiumEligibility.allowsExplicitEntry('chart'), isTrue);
      expect(PremiumEligibility.allowsExplicitEntry('onboarding'), isFalse);
      expect(PremiumEligibility.allowsExplicitEntry('session'), isFalse);
      expect(PremiumEligibility.allowsExplicitEntry('sos'), isFalse);
      expect(PremiumEligibility.allowsExplicitEntry('weekly_review'), isFalse);
      expect(
        PremiumEligibility.allowsSoftAppreciation(
          hasCompletedWeeklyArtifact: true,
          cooldownClear: true,
          underWeeklyCap: true,
        ),
        isTrue,
      );
      expect(
        PremiumEligibility.allowsSoftAppreciation(
          hasCompletedWeeklyArtifact: false,
          cooldownClear: true,
          underWeeklyCap: true,
        ),
        isFalse,
      );
    });
  });

  group('Reports archive gate (unchanged depths)', () {
    test('latest and previous Free; older Premium', () {
      expect(
        ReportsArchiveGate.canAccessArtifactIndex(0, isPremium: false),
        isTrue,
      );
      expect(
        ReportsArchiveGate.canAccessArtifactIndex(1, isPremium: false),
        isTrue,
      );
      expect(
        ReportsArchiveGate.canAccessArtifactIndex(2, isPremium: false),
        isFalse,
      );
      expect(
        ReportsArchiveGate.canAccessArtifactIndex(2, isPremium: true),
        isTrue,
      );
      expect(
        ReportsArchiveGate.canAccessMeasurementIndex(1, isPremium: false),
        isTrue,
      );
      expect(
        ReportsArchiveGate.canAccessMeasurementIndex(2, isPremium: false),
        isFalse,
      );
    });
  });

  group('PremiumController', () {
    test('valid offerings → offering_ready; no hardcoded arb prices', () async {
      final store = FakePremiumStore(offerings: sampleOfferings());
      final c = PremiumController(store: store);
      await c.hydrate(source: 'profile');
      expect(c.state.phase, PremiumPurchasePhase.offeringReady);
      expect(c.state.offerings, hasLength(3));
      expect(
          c.state.offerings.any((o) => o.priceString.contains('SAR')), isTrue);

      final en = AppLocalizationsEn();
      expect(en.v2PremiumTitle, 'Premium');
      expect(en.v2PremiumOrientation.contains(r'$'), isFalse);
      expect(en.v2PremiumViewPlans.contains(r'$'), isFalse);
    });

    test('empty offerings → no_offering', () async {
      final c = PremiumController(store: FakePremiumStore());
      await c.hydrate(source: 'profile');
      expect(c.state.phase, PremiumPurchasePhase.noOffering);
    });

    test('store throw → store_unavailable', () async {
      final c = PremiumController(
        store:
            FakePremiumStore(offerings: sampleOfferings(), throwOnLoad: true),
      );
      await c.hydrate(source: 'profile');
      expect(c.state.phase, PremiumPurchasePhase.storeUnavailable);
    });

    test('purchase success / cancel / fail / pending / already', () async {
      final store = FakePremiumStore(offerings: sampleOfferings());
      final c = PremiumController(store: store);
      await c.hydrate(source: 'profile');
      c.selectProduct(PremiumIdentifiers.stubMonthlyPlanId);
      await c.purchaseSelected();
      expect(c.state.phase, PremiumPurchasePhase.purchased);
      expect(c.state.isEntitled, isTrue);

      final cancel = PremiumController(
        store: FakePremiumStore(
          offerings: sampleOfferings(),
          purchaseOutcome: PremiumPurchaseOutcome.cancelled,
        ),
      );
      await cancel.hydrate(source: 'profile');
      cancel.selectProduct(PremiumIdentifiers.stubMonthlyPlanId);
      await cancel.purchaseSelected();
      expect(cancel.state.phase, PremiumPurchasePhase.cancelled);

      final fail = PremiumController(
        store: FakePremiumStore(
          offerings: sampleOfferings(),
          purchaseOutcome: PremiumPurchaseOutcome.failed,
        ),
      );
      await fail.hydrate(source: 'profile');
      fail.selectProduct(PremiumIdentifiers.stubMonthlyPlanId);
      await fail.purchaseSelected();
      expect(fail.state.phase, PremiumPurchasePhase.failed);

      final pending = PremiumController(
        store: FakePremiumStore(
          offerings: sampleOfferings(),
          purchaseOutcome: PremiumPurchaseOutcome.pending,
        ),
      );
      await pending.hydrate(source: 'profile');
      pending.selectProduct(PremiumIdentifiers.stubMonthlyPlanId);
      await pending.purchaseSelected();
      expect(pending.state.phase, PremiumPurchasePhase.pending);

      final already = PremiumController(
        store: FakePremiumStore(entitled: true, offerings: sampleOfferings()),
      );
      await already.hydrate(source: 'profile');
      expect(already.state.phase, PremiumPurchasePhase.alreadyEntitled);
    });

    test('restore success / nothing / failure / idempotent', () async {
      final store = FakePremiumStore(
        offerings: sampleOfferings(),
        restoreOutcome: PremiumRestoreOutcome.restored,
      );
      final c = PremiumController(store: store);
      await c.hydrate(source: 'profile');
      await c.restore();
      expect(c.state.phase, PremiumPurchasePhase.restored);
      expect(c.state.isEntitled, isTrue);
      await c.restore();
      expect(store.restoreCalls, 2);
      expect(c.state.isEntitled, isTrue);

      final none = PremiumController(
        store: FakePremiumStore(
          offerings: sampleOfferings(),
          restoreOutcome: PremiumRestoreOutcome.nothingToRestore,
        ),
      );
      await none.hydrate(source: 'profile');
      await none.restore();
      expect(none.state.phase, PremiumPurchasePhase.nothingToRestore);

      final fail = PremiumController(
        store: FakePremiumStore(
          offerings: sampleOfferings(),
          restoreOutcome: PremiumRestoreOutcome.failed,
        ),
      );
      await fail.hydrate(source: 'profile');
      await fail.restore();
      expect(fail.state.phase, PremiumPurchasePhase.failed);
    });

    test('offline cached / offline unknown', () async {
      final cached = PremiumController(
        store: FakePremiumStore(entitled: true, online: false),
      );
      await cached.hydrate(source: 'profile');
      expect(
        cached.state.phase,
        PremiumPurchasePhase.offlineCachedEntitlement,
      );

      final unknown = PremiumController(
        store: FakePremiumStore(online: false),
      );
      await unknown.hydrate(source: 'profile');
      expect(unknown.state.phase, PremiumPurchasePhase.offlineUnknown);
    });

    test('blocked forbidden source', () async {
      final c = PremiumController(
        store: FakePremiumStore(offerings: sampleOfferings()),
      );
      await c.hydrate(source: 'session');
      expect(c.state.messageKey, 'blocked_source');
    });

    test('trial only when confirmed', () {
      final withTrial = sampleOfferings(withTrial: true).first;
      expect(withTrial.trialConfirmed, isTrue);
      expect(withTrial.trialLabel, isNotNull);
      final without = sampleOfferings().first;
      expect(without.trialConfirmed, isFalse);
      expect(without.trialLabel, isNull);
    });

    test('subscription state does not mutate archive depths', () async {
      final before = ReportsArchiveGate.freeArtifactDepth;
      final store = FakePremiumStore(offerings: sampleOfferings());
      final c = PremiumController(store: store);
      await c.hydrate(source: 'profile');
      c.selectProduct(PremiumIdentifiers.stubAnnualPlanId);
      await c.purchaseSelected();
      expect(ReportsArchiveGate.freeArtifactDepth, before);
      expect(ReportsArchiveGate.freeMeasurementDepth, 2);
    });
  });

  group('Routing / widgets', () {
    testWidgets('explicit Premium entry shows PRE-01 reassurance + capitals', (
      tester,
    ) async {
      final store = FakePremiumStore(offerings: sampleOfferings());
      final controller = PremiumController(store: store);
      await controller.hydrate(source: 'profile');
      expect(controller.state.phase, PremiumPurchasePhase.offeringReady);
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          PremiumOverviewScreen(source: 'profile'),
          overrides: [
            premiumStorePortProvider.overrideWithValue(store),
            premiumControllerProvider.overrideWithValue(controller),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Premium'), findsWidgets);
      expect(find.textContaining('Free core'), findsOneWidget);
      expect(find.textContaining('current progress'), findsOneWidget);
      expect(find.text('Continuity'), findsOneWidget);
      expect(find.text('Interpretation'), findsOneWidget);
      expect(find.text('Fit'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Included with Premium now'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Included with Premium now'), findsOneWidget);
      expect(find.textContaining('Older Reports archive'), findsOneWidget);
      expect(find.textContaining('Not active yet'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('v2_premium_view_plans')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('View plans'), findsWidgets);
      expect(find.byKey(const Key('v2_premium_restore')), findsOneWidget);
      expect(find.byKey(const Key('v2_premium_privacy')), findsOneWidget);
      expect(find.text(AppLocalizationsEn().v2PremiumTermsLink), findsNothing);
      expect(find.textContaining('Unlock recovery'), findsNothing);
      expect(find.textContaining('Don’t lose'), findsNothing);
      expect(find.textContaining('full potential'), findsNothing);
      expect(find.textContaining('cloud sync'), findsNothing);
      expect(find.textContaining('Brain Clean Pro'), findsNothing);
      expect(find.textContaining('free trial'), findsNothing);
      expect(find.textContaining('Free trial'), findsNothing);
    });

    testWidgets('flag OFF preserves V1 for /v2/premium', (tester) async {
      final store = FakePremiumStore(offerings: sampleOfferings());
      final router = premiumTestRouter(flagOn: false);
      await tester.pumpWidget(pumpPremiumApp(router: router, store: store));
      await tester.pumpAndSettle();
      expect(find.text('V1_HOME'), findsOneWidget);
    });

    testWidgets('plans show store prices; purchase success → success route', (
      tester,
    ) async {
      final store = FakePremiumStore(offerings: sampleOfferings());
      final controller = PremiumController(store: store);
      await controller.hydrate(source: 'profile');
      final router = premiumTestRouter(
        flagOn: true,
        initial: '${AppRoutes.v2PremiumPlans}?source=profile',
      );
      await tester.pumpWidget(
        pumpPremiumApp(router: router, store: store, controller: controller),
      );
      await tester.pumpAndSettle();
      expect(find.text('SAR 18.99'), findsOneWidget);
      expect(find.text(r'$4.99'), findsNothing);
      await tester.tap(find.byKey(const Key('v2_premium_purchase')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Purchase completed'), findsWidgets);
    });

    testWidgets('Arabic labels', (tester) async {
      final store = FakePremiumStore(offerings: sampleOfferings());
      final controller = PremiumController(store: store);
      await controller.hydrate(source: 'profile');
      final ar = AppLocalizationsAr();
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          PremiumOverviewScreen(source: 'profile'),
          locale: const Locale('ar'),
          overrides: [
            premiumStorePortProvider.overrideWithValue(store),
            premiumControllerProvider.overrideWithValue(controller),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(ar.v2PremiumTitle), findsWidgets);
      expect(find.text(ar.v2PremiumContinuity), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('v2_premium_restore')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(ar.v2PremiumRestorePurchases), findsWidgets);
      expect(find.text(ar.v2PremiumViewPlans), findsWidgets);
    });

    testWidgets('320 width + textScale 2.0', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 720));
      final store = FakePremiumStore(offerings: sampleOfferings());
      final controller = PremiumController(store: store);
      await controller.hydrate(source: 'profile');
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 720),
            textScaler: TextScaler.linear(2),
          ),
          child: createLocalizedProviderTestWidget(
            PremiumOverviewScreen(source: 'profile'),
            overrides: [
              premiumStorePortProvider.overrideWithValue(store),
              premiumControllerProvider.overrideWithValue(controller),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('v2_premium_restore')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('v2_premium_restore')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('v2_premium_restore'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(tester.takeException(), isNull);
      await tester.binding.setSurfaceSize(null);
    });

    test('EN/AR parity for Premium copy', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      expect(en.v2PremiumTitle, 'Premium');
      expect(ar.v2PremiumTitle, 'بريميوم');
      expect(en.v2PremiumRestorePurchases, isNotEmpty);
      expect(ar.v2PremiumRestorePurchases, isNotEmpty);
      expect(en.v2PremiumManage, contains('Premium'));
      expect(ar.v2PremiumManage, contains('بريميوم'));
    });
  });

  group('Ads / archive invariants', () {
    test('premium routes contextual; depths unchanged', () {
      expect(AppRoutes.v2Premium, '/v2/premium');
      expect(AppRoutes.v2PremiumPlans, '/v2/premium/plans');
      expect(AppRoutes.v2PremiumStatus, '/v2/premium/status');
      expect(AppRoutes.v2PremiumRestore, '/v2/premium/restore');
      expect(
        ReportsArchiveGate.canAccessArtifactIndex(2, isPremium: false),
        isFalse,
      );
      expect(
        ReportsArchiveGate.canAccessArtifactIndex(0, isPremium: false),
        isTrue,
      );
    });
  });
}
