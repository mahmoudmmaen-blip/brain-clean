import 'dart:io';

import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/core/theme/app_theme.dart';
import 'package:brain_clean_mobile/features/pro/application/subscription_service_provider.dart';
import 'package:brain_clean_mobile/features/pro/domain/subscription_plan.dart';
import 'package:brain_clean_mobile/features/pro/domain/trial_period.dart';
import 'package:brain_clean_mobile/features/v2_premium/data/premium_controller_provider.dart';
import 'package:brain_clean_mobile/features/v2_premium/domain/premium_identifiers.dart';
import 'package:brain_clean_mobile/features/v2_premium/domain/premium_offering.dart';
import 'package:brain_clean_mobile/features/v2_premium/domain/premium_store_port.dart';
import 'package:brain_clean_mobile/v3/application/v3_state_providers.dart';
import 'package:brain_clean_mobile/v3/data/clarity_result.dart';
import 'package:brain_clean_mobile/v3/data/day_progress.dart';
import 'package:brain_clean_mobile/v3/data/sos_log.dart';
import 'package:brain_clean_mobile/v3/data/v3_app_state.dart';
import 'package:brain_clean_mobile/v3/domain/program_engine.dart';
import 'package:brain_clean_mobile/v3/routing/v3_routes.dart';
import 'package:brain_clean_mobile/v3/ui/paywall/paywall_price_math.dart';
import 'package:brain_clean_mobile/v3/ui/paywall/v3_paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/test_l10n.dart';

const _offerings = [
  PremiumOffering(
    productId: PremiumIdentifiers.monthlyProductId,
    title: 'Monthly',
    priceString: '19.00 SAR',
    period: SubscriptionPeriod.monthly,
  ),
  PremiumOffering(
    productId: PremiumIdentifiers.yearlyProductId,
    title: 'Yearly',
    priceString: '99.00 SAR',
    period: SubscriptionPeriod.annual,
  ),
  PremiumOffering(
    productId: PremiumIdentifiers.lifetimeProductId,
    title: 'Lifetime',
    priceString: '249.00 SAR',
    period: SubscriptionPeriod.lifetime,
  ),
];

const _offeringsWithTrial = [
  PremiumOffering(
    productId: PremiumIdentifiers.monthlyProductId,
    title: 'Monthly',
    priceString: '19.00 SAR',
    period: SubscriptionPeriod.monthly,
  ),
  PremiumOffering(
    productId: PremiumIdentifiers.yearlyProductId,
    title: 'Yearly',
    priceString: '99.00 SAR',
    period: SubscriptionPeriod.annual,
    trialConfirmed: true,
    trialDays: 14,
  ),
  PremiumOffering(
    productId: PremiumIdentifiers.lifetimeProductId,
    title: 'Lifetime',
    priceString: '249.00 SAR',
    period: SubscriptionPeriod.lifetime,
  ),
];

class _ProHolder {
  _ProHolder(this.value);

  bool value;
}

/// Controllable [PremiumStorePort] — prices, outcomes and failures are all
/// driven by the test, mirroring the real store's behavior of reporting
/// entitlement changes after purchase/restore.
class _FakePremiumStorePort implements PremiumStorePort {
  _FakePremiumStorePort({
    required this.offerings,
    this.purchaseOutcome = PremiumPurchaseOutcome.success,
    this.restoreOutcome = PremiumRestoreOutcome.restored,
  });

  final List<PremiumOffering> offerings;
  PremiumPurchaseOutcome purchaseOutcome;
  PremiumRestoreOutcome restoreOutcome;
  bool entitled = false;
  bool online = true;
  int failOfferingsTimes = 0;
  int purchaseCalls = 0;
  int restoreCalls = 0;
  void Function()? onEntitlementChanged;

  @override
  bool get isEntitled => entitled;

  @override
  bool get hasCachedEntitlement => entitled;

  @override
  bool get isOnline => online;

  @override
  bool get isStoreConfigured => true;

  @override
  Future<List<PremiumOffering>> loadOfferings() async {
    if (failOfferingsTimes > 0) {
      failOfferingsTimes--;
      throw StateError('offerings unavailable');
    }
    return offerings;
  }

  @override
  Future<PremiumPurchaseOutcome> purchase(String productId) async {
    purchaseCalls++;
    if (purchaseOutcome == PremiumPurchaseOutcome.success ||
        purchaseOutcome == PremiumPurchaseOutcome.alreadyEntitled) {
      entitled = true;
    }
    onEntitlementChanged?.call();
    return purchaseOutcome;
  }

  @override
  Future<PremiumRestoreOutcome> restore() async {
    restoreCalls++;
    if (restoreOutcome == PremiumRestoreOutcome.restored) {
      entitled = true;
    }
    onEntitlementChanged?.call();
    return restoreOutcome;
  }
}

DayProgress _doneDay(int day) => DayProgress(
      day: day,
      startedAt: DateTime(2026, 1, day),
      lessonDone: true,
      practiceDone: true,
      usedEasy: false,
      challengeAccepted: false,
      completedAt: DateTime(2026, 1, day, 12),
    );

ClarityResult _clarity(int day, int score) => ClarityResult(
      takenAt: DateTime(2026, 1, day),
      programDay: day,
      score: score,
      areas: const ClarityAreaScores(
        focus: 1,
        control: 1,
        sleep: 1,
        calm: 1,
      ),
      hoursEstimate: 5,
      answers: const {},
    );

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

Future<ProviderContainer> _pumpPaywall(
  WidgetTester tester, {
  required _FakePremiumStorePort fake,
  required _ProHolder proHolder,
  String source = 'day7',
  V3AppState? appState,
  bool settleCloseTimer = true,
}) async {
  final flag = Provider<bool>((ref) => proHolder.value);
  final state = appState ?? const V3AppState();
  final container = ProviderContainer(
    overrides: [
      premiumStorePortProvider.overrideWithValue(fake),
      isProUserProvider.overrideWith((ref) => ref.watch(flag)),
      v3AppStateProvider.overrideWith((ref) => Future.value(state)),
    ],
  );
  addTearDown(container.dispose);
  fake.onEntitlementChanged = () {
    proHolder.value = fake.isEntitled;
    container.invalidate(flag);
  };

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(
          body: SizedBox(key: Key('paywall_test_home')),
        ),
      ),
      GoRoute(
        path: V3Routes.today,
        builder: (_, __) => const Scaffold(
          body: SizedBox(key: Key('paywall_test_home')),
        ),
      ),
      GoRoute(
        path: V3Routes.paywall,
        builder: (_, routeState) => V3PaywallScreen(
          source: routeState.uri.queryParameters['source'],
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: supportedLocales,
        theme: AppTheme.dark,
        routerConfig: router,
      ),
    ),
  );
  // Do not await push — its Future completes only when the route is popped.
  router.push('${V3Routes.paywall}?source=$source');
  await tester.pump();
  await tester.pump(); // deliver FutureProvider + hydrate microtasks
  await tester.pump(const Duration(milliseconds: 50));
  // Fire the 2s close-button timer so tests don't leave a pending Timer.
  if (settleCloseTimer) {
    await tester.pump(const Duration(seconds: 2));
  }
  return container;
}

void main() {
  test('TrialPeriod parses ISO free-phase periods', () {
    expect(TrialPeriod.daysFromIso8601('P2W'), 14);
    expect(TrialPeriod.daysFromIso8601('P14D'), 14);
    expect(TrialPeriod.daysFromIso8601('P1M'), 30);
    expect(TrialPeriod.daysFromIso8601(null), isNull);
    expect(TrialPeriod.daysFromUnitValue('WEEK', 2), 14);
  });

  test('PaywallPriceMath savings and monthly equivalent for 19/99', () {
    expect(PaywallPriceMath.parseStorePrice('19.00 SAR'), 19);
    expect(PaywallPriceMath.parseStorePrice('99.00 SAR'), 99);
    expect(
      PaywallPriceMath.yearlySavingsPercent(
        monthlyPrice: 19,
        yearlyPrice: 99,
      ),
      57,
    );
    expect(PaywallPriceMath.monthlyEquivalentAmount('99.00 SAR'), '8.25');
  });

  testWidgets('shows exactly 3 benefits and none mention SOS', (tester) async {
    final fake = _FakePremiumStorePort(offerings: _offerings);
    await _pumpPaywall(tester, fake: fake, proHolder: _ProHolder(false));

    expect(find.byKey(const Key('v3_paywall_benefit')), findsNWidgets(3));
    expect(find.text(testL10n.v3PaywallBenefit1), findsOneWidget);
    expect(find.text(testL10n.v3PaywallBenefit2), findsOneWidget);
    expect(find.text(testL10n.v3PaywallBenefit3), findsOneWidget);
    expect(find.text(testL10n.v3PaywallSubDay7), findsOneWidget);

    for (final text in [
      testL10n.v3PaywallBenefit1,
      testL10n.v3PaywallBenefit2,
      testL10n.v3PaywallBenefit3,
    ]) {
      expect(text.toLowerCase().contains('sos'), isFalse);
    }
  });

  testWidgets('renders store prices with 57% save and ≈ 8.25', (tester) async {
    final fake = _FakePremiumStorePort(offerings: _offerings);
    await _pumpPaywall(tester, fake: fake, proHolder: _ProHolder(false));

    expect(find.text('19.00 SAR'), findsOneWidget);
    expect(find.text('99.00 SAR'), findsOneWidget);
    expect(find.text('249.00 SAR'), findsOneWidget);
    expect(find.text('Save 57%'), findsOneWidget);
    expect(find.textContaining('≈ 8.25'), findsOneWidget);
  });

  test('no hard-coded store price literals in lib/v3 paywall code', () {
    final paywallDir = Directory('lib/v3/ui/paywall');
    final files = paywallDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    final banned = RegExp(r'''["'](?:19|99|149|249)(?:\.\d+)?(?:\s*SAR|\s*ر\.س)?["']''');
    for (final file in files) {
      expect(
        banned.hasMatch(file.readAsStringSync()),
        isFalse,
        reason: 'Hard-coded price in ${file.path}',
      );
    }
  });

  testWidgets('no trial badge or CTA when trial not confirmed', (tester) async {
    final without = _FakePremiumStorePort(offerings: _offerings);
    await _pumpPaywall(tester, fake: without, proHolder: _ProHolder(false));
    expect(find.byKey(const Key('v3_paywall_trial_badge')), findsNothing);
    expect(find.text(testL10n.v3PaywallSubscribeCta), findsOneWidget);
    expect(find.text(testL10n.v3PaywallStartTrialCta(14)), findsNothing);
  });

  testWidgets('trial badge and CTA when trialConfirmed on yearly', (tester) async {
    final withTrial = _FakePremiumStorePort(offerings: _offeringsWithTrial);
    await _pumpPaywall(tester, fake: withTrial, proHolder: _ProHolder(false));
    expect(find.byKey(const Key('v3_paywall_trial_badge')), findsOneWidget);
    expect(find.text(testL10n.v3PaywallTrialBadge(14)), findsOneWidget);
    expect(find.text(testL10n.v3PaywallStartTrialCta(14)), findsOneWidget);
    expect(find.text(testL10n.v3PaywallTrialDisclaimer), findsOneWidget);
  });

  testWidgets('purchase success unlocks Pro and day 8', (tester) async {
    final fake = _FakePremiumStorePort(offerings: _offerings);
    final container = await _pumpPaywall(
      tester,
      fake: fake,
      proHolder: _ProHolder(false),
    );

    expect(
      ProgramEngine.isProLocked(
        day: 8,
        isPro: container.read(isProUserProvider),
      ),
      isTrue,
    );

    await _tap(tester, find.byKey(const Key('v3_paywall_subscribe')));
    await tester.pump(); // resume purchaseSelected
    await tester.pump(); // post-frame navigation
    await tester.pump(const Duration(milliseconds: 50));

    expect(fake.purchaseCalls, 1);
    expect(container.read(isProUserProvider), isTrue);
    expect(
      ProgramEngine.isProLocked(
        day: 8,
        isPro: container.read(isProUserProvider),
      ),
      isFalse,
    );
    // Success → Pro unlocked; screen pops/goes Today, or shows manage state.
    final leftPaywall = find.byType(V3PaywallScreen).evaluate().isEmpty;
    final subscribed = find.byKey(const Key('v3_paywall_manage')).evaluate().isNotEmpty;
    expect(leftPaywall || subscribed, isTrue);
  });

  testWidgets('purchase cancelled returns to idle with no error', (tester) async {
    final fake = _FakePremiumStorePort(
      offerings: _offerings,
      purchaseOutcome: PremiumPurchaseOutcome.cancelled,
    );
    final container = await _pumpPaywall(
      tester,
      fake: fake,
      proHolder: _ProHolder(false),
    );

    await _tap(tester, find.byKey(const Key('v3_paywall_subscribe')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    expect(find.text('19.00 SAR'), findsOneWidget);
    expect(find.text('99.00 SAR'), findsOneWidget);
    expect(find.text(testL10n.v2PremiumPurchaseFailed), findsNothing);
    expect(container.read(isProUserProvider), isFalse);
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('v3_paywall_subscribe')),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('restore success unlocks Pro', (tester) async {
    final fake = _FakePremiumStorePort(offerings: _offerings);
    final container = await _pumpPaywall(
      tester,
      fake: fake,
      proHolder: _ProHolder(false),
    );
    expect(container.read(isProUserProvider), isFalse);

    await _tap(tester, find.byKey(const Key('v3_paywall_restore')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    expect(fake.restoreCalls, 1);
    expect(container.read(isProUserProvider), isTrue);
    expect(find.text(testL10n.v3PaywallAlreadyPro), findsOneWidget);
    expect(find.byKey(const Key('v3_paywall_manage')), findsOneWidget);
  });

  testWidgets('offerings failure shows retry state and recovers on retry',
      (tester) async {
    final fake = _FakePremiumStorePort(offerings: _offerings)
      ..failOfferingsTimes = 1;
    await _pumpPaywall(tester, fake: fake, proHolder: _ProHolder(false));

    expect(find.text(testL10n.v3PaywallPricesFailed), findsOneWidget);
    expect(find.byKey(const Key('v3_paywall_retry')), findsOneWidget);
    expect(find.byKey(const Key('v3_paywall_subscribe')), findsNothing);

    await _tap(tester, find.byKey(const Key('v3_paywall_retry')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    expect(find.text('19.00 SAR'), findsOneWidget);
    expect(find.byKey(const Key('v3_paywall_subscribe')), findsOneWidget);
  });

  testWidgets('already Pro shows subscribed state instead of plans',
      (tester) async {
    final fake = _FakePremiumStorePort(offerings: _offerings)..entitled = true;
    await _pumpPaywall(tester, fake: fake, proHolder: _ProHolder(true));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    expect(find.text(testL10n.v3PaywallAlreadyPro), findsOneWidget);
    expect(find.byKey(const Key('v3_paywall_manage')), findsOneWidget);
    expect(find.byKey(const Key('v3_paywall_subscribe')), findsNothing);
    expect(find.byKey(const Key('v3_paywall_restore')), findsNothing);
  });

  testWidgets('day7 header shows real counts and hides zero chips',
      (tester) async {
    final now = DateTime(2026, 1, 7);
    final app = V3AppState(
      dayProgress: [_doneDay(1), _doneDay(2), _doneDay(3)],
      sosLogs: [
        SosLog(at: now, flowId: 'bored', before: 8, after: 3),
        SosLog(at: now, flowId: 'stress', before: 5, after: 6),
      ],
      clarityResults: [_clarity(1, 42), _clarity(7, 58)],
    );
    final fake = _FakePremiumStorePort(offerings: _offerings);
    await _pumpPaywall(
      tester,
      fake: fake,
      proHolder: _ProHolder(false),
      appState: app,
    );

    expect(find.text(testL10n.v3PaywallPersonalTitle), findsOneWidget);
    expect(find.text(testL10n.v3PaywallChipDays(3)), findsOneWidget);
    expect(find.text(testL10n.v3PaywallChipUrges(1)), findsOneWidget);
    expect(find.text(testL10n.v3PaywallClarityFromTo(42, 58)), findsOneWidget);
    // Zero urges would be hidden — we have 1 beaten; no hours chip (C06).
    expect(find.textContaining('Phone hours'), findsNothing);
  });

  testWidgets('day7 header with no data shows only days chip', (tester) async {
    final fake = _FakePremiumStorePort(offerings: _offerings);
    await _pumpPaywall(
      tester,
      fake: fake,
      proHolder: _ProHolder(false),
      appState: const V3AppState(),
    );

    expect(find.text(testL10n.v3PaywallChipDays(0)), findsOneWidget);
    expect(find.byKey(const Key('v3_paywall_chip_days')), findsOneWidget);
    expect(find.text(testL10n.v3PaywallClarityFromTo(42, 58)), findsNothing);
  });

  testWidgets('close X appears after 2 seconds', (tester) async {
    final fake = _FakePremiumStorePort(offerings: _offerings);
    await _pumpPaywall(
      tester,
      fake: fake,
      proHolder: _ProHolder(false),
      settleCloseTimer: false,
    );

    expect(find.byKey(const Key('v3_paywall_close')), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const Key('v3_paywall_close')), findsOneWidget);
  });
}
