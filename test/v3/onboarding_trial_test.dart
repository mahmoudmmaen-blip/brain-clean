import 'dart:io';

import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/core/theme/app_theme.dart';
import 'package:brain_clean_mobile/features/pro/application/subscription_service_provider.dart';
import 'package:brain_clean_mobile/features/pro/domain/subscription_plan.dart';
import 'package:brain_clean_mobile/features/v2_premium/data/premium_controller_provider.dart';
import 'package:brain_clean_mobile/features/v2_premium/domain/premium_identifiers.dart';
import 'package:brain_clean_mobile/features/v2_premium/domain/premium_offering.dart';
import 'package:brain_clean_mobile/features/v2_premium/domain/premium_store_port.dart';
import 'package:brain_clean_mobile/v3/application/clarity_check_session_provider.dart';
import 'package:brain_clean_mobile/v3/application/trial_status_provider.dart';
import 'package:brain_clean_mobile/v3/application/v3_state_providers.dart';
import 'package:brain_clean_mobile/v3/content/content.dart';
import 'package:brain_clean_mobile/v3/data/clarity_result.dart';
import 'package:brain_clean_mobile/v3/data/user_profile.dart';
import 'package:brain_clean_mobile/v3/data/v3_state_repository.dart';
import 'package:brain_clean_mobile/v3/domain/clarity_question_order.dart';
import 'package:brain_clean_mobile/v3/domain/clarity_scoring.dart';
import 'package:brain_clean_mobile/v3/domain/screen_time_reframe.dart';
import 'package:brain_clean_mobile/v3/domain/trial_offer_gate.dart';
import 'package:brain_clean_mobile/v3/domain/trial_status.dart';
import 'package:brain_clean_mobile/v3/routing/v3_routes.dart';
import 'package:brain_clean_mobile/v3/ui/onboarding/clarity_check_screen.dart';
import 'package:brain_clean_mobile/v3/ui/onboarding/onboarding_keys.dart';
import 'package:brain_clean_mobile/v3/ui/onboarding/result_plan_screen.dart';
import 'package:brain_clean_mobile/v3/ui/onboarding/setup_screen.dart';
import 'package:brain_clean_mobile/v3/ui/paywall/trial_offer_screen.dart';
import 'package:brain_clean_mobile/v3/ui/today/trial_ending_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/hive_test_fixtures.dart';
import '../helpers/test_l10n.dart';

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
];

const _offeringsNoTrial = [
  PremiumOffering(
    productId: PremiumIdentifiers.yearlyProductId,
    title: 'Yearly',
    priceString: '99.00 SAR',
    period: SubscriptionPeriod.annual,
  ),
];

class _FakePremiumStorePort implements PremiumStorePort {
  _FakePremiumStorePort({
    required this.offerings,
    this.storeConfigured = true,
    this.entitled = false,
  });

  final List<PremiumOffering> offerings;
  bool storeConfigured;
  bool entitled;
  int purchaseCalls = 0;

  @override
  bool get isEntitled => entitled;

  @override
  bool get hasCachedEntitlement => entitled;

  @override
  bool get isOnline => true;

  @override
  bool get isStoreConfigured => storeConfigured;

  @override
  Future<List<PremiumOffering>> loadOfferings() async => offerings;

  @override
  Future<PremiumPurchaseOutcome> purchase(String productId) async {
    purchaseCalls++;
    entitled = true;
    return PremiumPurchaseOutcome.success;
  }

  @override
  Future<PremiumRestoreOutcome> restore() async =>
      PremiumRestoreOutcome.nothingToRestore;
}

void main() {
  late ContentBundle contentBundle;
  late InMemoryHiveBox v3Box;

  setUpAll(() async {
    final repo = ContentRepository(
      assetLoader: (path) => File(path).readAsString(),
    );
    contentBundle = await repo.load();
  });

  setUp(() {
    v3Box = InMemoryHiveBox();
  });

  group('Clarity Check order', () {
    test('screen-time is the first question after intro (step 1)', () {
      // Session step after intro continue is 1 = screen time (separate from scored items).
      expect(contentBundle.clarityCheck.screenTimeQuestion.id, 'q_hours');
      expect(contentBundle.clarityCheck.questions.first.id, isNot('q_hours'));
    });

    test('re-check order differs from baseline; scores match for same answers',
        () {
      final questions = contentBundle.clarityCheck.questions;
      final baseline = ClarityQuestionOrder.ordered(
        questions: questions,
        mode: ClarityCheckMode.baseline,
        checkDate: DateTime(2026, 10, 18),
      );
      final recheck = ClarityQuestionOrder.ordered(
        questions: questions,
        mode: ClarityCheckMode.recheck,
        checkDate: DateTime(2026, 10, 18),
      );

      expect(baseline.map((q) => q.id).toList(),
          questions.map((q) => q.id).toList());
      expect(recheck.map((q) => q.id).toList(),
          isNot(baseline.map((q) => q.id).toList()));

      final answers = <String, int>{
        for (final q in questions) q.id: 2,
      };
      final scoreA = ClarityScoring.compute(
        content: contentBundle.clarityCheck,
        answers: answers,
        hoursEstimate: 5,
      );
      final scoreB = ClarityScoring.compute(
        content: contentBundle.clarityCheck,
        answers: answers,
        hoursEstimate: 5,
      );
      expect(scoreA.score, scoreB.score);
      expect(scoreA.areas.focus, scoreB.areas.focus);
    });
  });

  group('Screen time reframe', () {
    test('6 h a day → 91 full days a year', () {
      expect(ScreenTimeReframe.yearlyFullDays(6), 91);
    });
  });

  group('TrialOfferGate', () {
    test('shown when not Pro, store configured, yearly trial confirmed', () {
      expect(
        TrialOfferGate.shouldShow(
          alreadyShown: false,
          isPro: false,
          storeConfigured: true,
          yearlyTrialConfirmed: true,
        ),
        isTrue,
      );
    });

    test('skipped when Pro / no trial / store not configured / already shown',
        () {
      expect(
        TrialOfferGate.shouldShow(
          alreadyShown: false,
          isPro: true,
          storeConfigured: true,
          yearlyTrialConfirmed: true,
        ),
        isFalse,
      );
      expect(
        TrialOfferGate.shouldShow(
          alreadyShown: false,
          isPro: false,
          storeConfigured: false,
          yearlyTrialConfirmed: true,
        ),
        isFalse,
      );
      expect(
        TrialOfferGate.shouldShow(
          alreadyShown: false,
          isPro: false,
          storeConfigured: true,
          yearlyTrialConfirmed: false,
        ),
        isFalse,
      );
      expect(
        TrialOfferGate.shouldShow(
          alreadyShown: true,
          isPro: false,
          storeConfigured: true,
          yearlyTrialConfirmed: true,
        ),
        isFalse,
      );
      expect(TrialOfferGate.yearlyHasConfirmedTrial(_offeringsNoTrial), isFalse);
      expect(
        TrialOfferGate.yearlyHasConfirmedTrial(_offeringsWithTrial),
        isTrue,
      );
    });
  });

  group('TrialStatus ending notice', () {
    final expiresSoon = DateTime(2026, 10, 20, 12);
    final now = DateTime(2026, 10, 18, 18);

    test('appears when trial and expiration within 48 h', () {
      final status = TrialStatus(
        isTrialPeriod: true,
        expiresAt: expiresSoon,
        yearlyPriceString: '99.00 SAR',
      );
      expect(status.shouldShowEndingNotice(now: now), isTrue);
    });

    test('does not appear at 5 days remaining', () {
      final status = TrialStatus(
        isTrialPeriod: true,
        expiresAt: now.add(const Duration(days: 5)),
        yearlyPriceString: '99.00 SAR',
      );
      expect(status.shouldShowEndingNotice(now: now), isFalse);
    });

    test('appears only once per trial expiration', () {
      final key = TrialStatus.expirationKey(expiresSoon);
      final status = TrialStatus(
        isTrialPeriod: true,
        expiresAt: expiresSoon,
        yearlyPriceString: '99.00 SAR',
        endingNoticeShownKey: key,
      );
      expect(status.shouldShowEndingNotice(now: now), isFalse);
    });
  });

  group('widgets', () {
    Future<void> pumpScoped(
      WidgetTester tester, {
      required Widget home,
      List<Override> overrides = const [],
      String initialLocation = '/',
      List<RouteBase> extraRoutes = const [],
    }) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      final router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(path: '/', builder: (_, __) => home),
          GoRoute(
            path: V3Routes.session,
            builder: (_, __) =>
                const Scaffold(body: SizedBox(key: Key('day1'))),
          ),
          GoRoute(
            path: V3Routes.offer,
            builder: (_, __) => const V3TrialOfferScreen(),
          ),
          GoRoute(
            path: V3Routes.setup,
            builder: (_, __) => const V3SetupScreen(),
          ),
          ...extraRoutes,
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            v3ContentProvider.overrideWith((ref) async => contentBundle),
            v3StateRepositoryProvider.overrideWithValue(
              V3StateLocalRepository(box: v3Box),
            ),
            ...overrides,
          ],
          child: MaterialApp.router(
            locale: const Locale('en'),
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: supportedLocales,
            theme: AppTheme.dark,
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    testWidgets('first question after intro is screen time', (tester) async {
      await pumpScoped(
        tester,
        home: const V3ClarityCheckScreen(mode: ClarityCheckMode.baseline),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(V3OnboardingKeys.checkContinue));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(V3OnboardingKeys.checkScreenTime), findsOneWidget);
      // Screen-time step is immediately after intro (before scored items).
      expect(find.byKey(V3OnboardingKeys.checkOption), findsOneWidget);
    });

    testWidgets('no name field on setup', (tester) async {
      await pumpScoped(tester, home: const V3SetupScreen());
      expect(find.byKey(V3OnboardingKeys.setupScreen), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text(testL10n.v3SetupNameHint), findsNothing);
      expect(find.text(testL10n.v3SetupGoalTitle), findsOneWidget);
    });

    testWidgets('result reframe shows 6 h → 91 days', (tester) async {
      final repo = V3StateLocalRepository(box: v3Box);
      await repo.appendClarityResult(
        ClarityResult(
          takenAt: DateTime(2026, 10, 1),
          programDay: 1,
          score: 50,
          areas: const ClarityAreaScores(
            focus: 50,
            control: 50,
            sleep: 50,
            calm: 50,
          ),
          hoursEstimate: 6,
          answers: const {},
        ),
      );
      await repo.saveProfile(
        UserProfile(
          goal: 'focus',
          reminderTime: '20:00',
          eveningCheckIn: true,
          onboardingDone: true,
          createdAt: DateTime(2026, 10, 1),
          locale: 'en',
        ),
      );

      final fake = _FakePremiumStorePort(
        offerings: _offeringsNoTrial,
        storeConfigured: false,
      );

      await pumpScoped(
        tester,
        home: const V3ResultPlanScreen(),
        overrides: [
          premiumStorePortProvider.overrideWithValue(fake),
          isProUserProvider.overrideWith((ref) => false),
          v3AppStateProvider.overrideWith(
            (ref) => repo.load(),
          ),
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(V3OnboardingKeys.resultReframe), findsOneWidget);
      expect(find.text(testL10n.v3ResultReframe('6', 91)), findsOneWidget);
    });

    testWidgets('offer shown once then never', (tester) async {
      final fake = _FakePremiumStorePort(offerings: _offeringsWithTrial);
      final repo = V3StateLocalRepository(box: v3Box);

      await pumpScoped(
        tester,
        home: const V3TrialOfferScreen(),
        overrides: [
          premiumStorePortProvider.overrideWithValue(fake),
          isProUserProvider.overrideWith((ref) => false),
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(V3OnboardingKeys.trialOfferScreen), findsOneWidget);
      expect(find.byKey(V3OnboardingKeys.trialOfferStart), findsOneWidget);

      await tester.tap(find.byKey(V3OnboardingKeys.trialOfferFree));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final state = await repo.load();
      expect(state.trialOfferShown, isTrue);

      // Gate refuses a second show.
      expect(
        TrialOfferGate.shouldShow(
          alreadyShown: state.trialOfferShown,
          isPro: false,
          storeConfigured: true,
          yearlyTrialConfirmed: true,
        ),
        isFalse,
      );
    });

    Future<void> tapResultContinue(WidgetTester tester) async {
      final finder = find.byKey(V3OnboardingKeys.resultStartDay1);
      await tester.ensureVisible(finder);
      await tester.pump();
      await tester.tap(finder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    Future<void> seedResult(V3StateLocalRepository repo) async {
      await repo.appendClarityResult(
        ClarityResult(
          takenAt: DateTime(2026, 10, 1),
          programDay: 1,
          score: 40,
          areas: const ClarityAreaScores(
            focus: 40,
            control: 40,
            sleep: 40,
            calm: 40,
          ),
          hoursEstimate: 5,
          answers: const {},
        ),
      );
      await repo.saveProfile(
        UserProfile(
          goal: 'focus',
          reminderTime: '20:00',
          eveningCheckIn: true,
          onboardingDone: true,
          createdAt: DateTime(2026, 10, 1),
          locale: 'en',
        ),
      );
    }

    testWidgets('offer skipped when Pro', (tester) async {
      final fake = _FakePremiumStorePort(offerings: _offeringsWithTrial);
      final repo = V3StateLocalRepository(box: v3Box);
      await seedResult(repo);

      await pumpScoped(
        tester,
        home: const V3ResultPlanScreen(),
        overrides: [
          premiumStorePortProvider.overrideWithValue(fake),
          isProUserProvider.overrideWith((ref) => true),
          v3AppStateProvider.overrideWith((ref) => repo.load()),
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tapResultContinue(tester);

      expect(find.byKey(V3OnboardingKeys.trialOfferScreen), findsNothing);
      expect(find.byKey(const Key('day1')), findsOneWidget);
      expect((await repo.load()).trialOfferShown, isTrue);
    });

    testWidgets('offer skipped when store not configured', (tester) async {
      final fake = _FakePremiumStorePort(
        offerings: _offeringsWithTrial,
        storeConfigured: false,
      );
      final repo = V3StateLocalRepository(box: v3Box);
      await seedResult(repo);

      await pumpScoped(
        tester,
        home: const V3ResultPlanScreen(),
        overrides: [
          premiumStorePortProvider.overrideWithValue(fake),
          isProUserProvider.overrideWith((ref) => false),
          v3AppStateProvider.overrideWith((ref) => repo.load()),
        ],
      );
      await tester.pump();
      await tapResultContinue(tester);

      expect(find.byKey(V3OnboardingKeys.trialOfferScreen), findsNothing);
      expect(find.byKey(const Key('day1')), findsOneWidget);
    });

    testWidgets('offer skipped when yearly has no trial', (tester) async {
      final fake = _FakePremiumStorePort(offerings: _offeringsNoTrial);
      final repo = V3StateLocalRepository(box: v3Box);
      await seedResult(repo);

      await pumpScoped(
        tester,
        home: const V3ResultPlanScreen(),
        overrides: [
          premiumStorePortProvider.overrideWithValue(fake),
          isProUserProvider.overrideWith((ref) => false),
          v3AppStateProvider.overrideWith((ref) => repo.load()),
        ],
      );
      await tester.pump();
      await tapResultContinue(tester);

      expect(find.byKey(V3OnboardingKeys.trialOfferScreen), findsNothing);
      expect(find.byKey(const Key('day1')), findsOneWidget);
    });

    testWidgets('trial-ending sheet at <48h, not at 5 days, only once',
        (tester) async {
      final repo = V3StateLocalRepository(box: v3Box);
      await repo.saveProfile(
        UserProfile(
          goal: 'focus',
          reminderTime: '20:00',
          eveningCheckIn: true,
          onboardingDone: true,
          createdAt: DateTime(2026, 10, 1),
          locale: 'en',
        ),
      );

      final now = DateTime(2026, 10, 18, 12);
      final expiresSoon = now.add(const Duration(hours: 36));
      final expiresLater = now.add(const Duration(days: 5));
      final app = await repo.load();

      // Gate: 5 days out — no show.
      expect(
        TrialStatus(
          isTrialPeriod: true,
          expiresAt: expiresLater,
          yearlyPriceString: '99.00 SAR',
        ).shouldShowEndingNotice(now: now),
        isFalse,
      );

      // Within 48 h — host shows the sheet once.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            v3StateRepositoryProvider.overrideWithValue(repo),
            v3AppStateProvider.overrideWith((ref) async => app),
            trialStatusNowProvider.overrideWithValue(now),
            trialStatusProvider.overrideWith(
              (ref) async => TrialStatus(
                isTrialPeriod: true,
                expiresAt: expiresSoon,
                yearlyPriceString: '99.00 SAR',
              ),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: supportedLocales,
            theme: AppTheme.dark,
            home: const TrialEndingHost(
              child: Scaffold(
                body: Text('today_host', key: Key('today_host')),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(); // post-frame
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(V3OnboardingKeys.trialEndingSheet), findsOneWidget);
      expect(find.text(testL10n.v3TrialEndingTitle), findsOneWidget);

      await tester.tap(find.byKey(const Key('v3_trial_ending_continue')));
      await tester.pumpAndSettle();

      final after = await repo.load();
      expect(after.trialEndingNoticeKey, isNotNull);

      // Same expiration key → gate refuses a second show.
      expect(
        TrialStatus(
          isTrialPeriod: true,
          expiresAt: expiresSoon,
          yearlyPriceString: '99.00 SAR',
          endingNoticeShownKey: after.trialEndingNoticeKey,
        ).shouldShowEndingNotice(now: now),
        isFalse,
      );

      // Rebuild host with notice already recorded — no sheet.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            v3StateRepositoryProvider.overrideWithValue(repo),
            v3AppStateProvider.overrideWith((ref) async => after),
            trialStatusNowProvider.overrideWithValue(now),
            trialStatusProvider.overrideWith(
              (ref) async => TrialStatus(
                isTrialPeriod: true,
                expiresAt: expiresSoon,
                yearlyPriceString: '99.00 SAR',
                endingNoticeShownKey: after.trialEndingNoticeKey,
              ),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: supportedLocales,
            theme: AppTheme.dark,
            home: const TrialEndingHost(
              child: Scaffold(
                body: Text('today_host', key: Key('today_host')),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(V3OnboardingKeys.trialEndingSheet), findsNothing);
    });
  });
}
