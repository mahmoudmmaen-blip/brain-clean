import 'dart:io';

import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_item_bank.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_mode.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_phase.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_progress.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/measurement_event.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/brain_profile_domain_result.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/measurement_confidence.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/measurement_explanation.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_pack.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_source_reference.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_version.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/recovery_score.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/recovery_score_engine.dart';
import 'package:brain_clean_mobile/features/recovery_plan/data/recovery_plan_repository.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/recovery_plan_engine.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/recovery_plan_status.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/recovery_plan_versions.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/today_act_presentation.dart';
import 'package:brain_clean_mobile/features/recovery_plan/ui/plan_reveal_screen.dart';
import 'package:brain_clean_mobile/features/recovery_plan/ui/plan_today_preview_screen.dart';
import 'package:brain_clean_mobile/features/recovery_plan/ui/plan_today_ready_boundary_screen.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/application/v2_onboarding_controller.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/data/v2_onboarding_repository.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_first_time_journey_resolver.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_onboarding_state.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_onboarding_status.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_onboarding_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);
  final String root;
  @override
  Future<String?> getApplicationDocumentsPath() async => root;
  @override
  Future<String?> getTemporaryPath() async => root;
}

class _MemoryOnboardingRepo implements V2OnboardingRepository {
  V2OnboardingState _state = V2OnboardingState.fresh();

  @override
  Future<V2OnboardingState> load() async => _state;

  @override
  Future<V2OnboardingState> save(V2OnboardingState state) async {
    _state = state;
    return _state;
  }

  @override
  Future<V2OnboardingState> restart({String? languageCode}) async {
    _state = V2OnboardingState.fresh(languageCode: languageCode);
    return _state;
  }
}

ProfilePack _pack({
  String id = 'pack_ft',
  String sessionId = 'sess_ft',
}) {
  final domains = <BrainProfileDomainResult>[];
  for (final section in BrainCheckItemBank.sectionsFor(BrainCheckMode.full)) {
    final score = switch (section.id) {
      'full_attention' => 30,
      'full_mood' => 55,
      'full_habits' => 60,
      _ => 70,
    };
    domains.add(
      BrainProfileDomainResult(
        domainId: section.id,
        titleEn: section.titleEn,
        titleAr: section.titleAr,
        answeredCount: 3,
        expectedCount: 3,
        missingQuestionIds: const [],
        normalizedMean: score.toDouble(),
        displayScore: score,
      ),
    );
  }
  return ProfilePack(
    id: id,
    source: ProfileSourceReference(
      sessionId: sessionId,
      mode: BrainCheckMode.full,
      brainCheckSchemaVersion: 'brain_check_measurement_v1',
    ),
    createdAt: DateTime.utc(2026, 8, 2),
    lastRecalculatedAt: DateTime.utc(2026, 8, 2),
    domains: domains,
    recoveryScore: const RecoveryScore(
      modelVersion: 'recovery_score_v1',
      band: RecoveryScoreBand.findingSteadiness,
      value: 54,
      valueInternal: 54,
      weightSetVersion: 'weight_set_equal_v1',
    ),
    confidence: MeasurementConfidence.strong,
    explanation: ProfileExplanationCatalog.build(
      strongerTitlesEn: const [],
      strongerTitlesAr: const [],
      supportTitlesEn: const [],
      supportTitlesAr: const [],
      confidence: MeasurementConfidence.strong,
      scorePending: false,
    ),
    profileSchemaVersion: ProfileVersion.profileSchema,
    domainAggregationModelVersion: ProfileVersion.domainAggregationModel,
  );
}

BrainCheckProgress _draft() => BrainCheckProgress(
      mode: BrainCheckMode.lite,
      phase: BrainCheckPhase.item,
      currentQuestionIndex: 2,
      currentSectionIndex: 0,
      answers: const {},
      startedAt: DateTime.utc(2026, 8, 1),
      updatedAt: DateTime.utc(2026, 8, 1),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late String tempDir;

  setUp(() async {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
    tempDir =
        '${Directory.systemTemp.path}/ftj_${DateTime.now().microsecondsSinceEpoch}';
    await Directory(tempDir).create(recursive: true);
    PathProviderPlatform.instance = _FakePathProvider(tempDir);
    HiveBootstrap.resetForTesting();
    await Hive.initFlutter(tempDir);
  });

  tearDown(() async {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
    await Hive.close();
    HiveBootstrap.resetForTesting();
    try {
      await Directory(tempDir).delete(recursive: true);
    } catch (_) {}
  });

  Widget wrap(Widget child, {Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('plan continuity', () {
    test('existing plan reused; missing generated once; no duplicate history',
        () async {
      final box = await Hive.openBox<dynamic>('ft_plan');
      final repo = RecoveryPlanLocalRepository(box: box);
      final pack = _pack();
      final plan = RecoveryPlanEngineV1.generate(pack);
      final a = await repo.saveIfNew(plan);
      final b = await repo.saveIfNew(plan);
      expect(a.id, b.id);
      expect((await repo.history()).length, 1);
      expect((await repo.findByProfilePackId(pack.id))?.id, a.id);
      expect((await repo.active())?.id, a.id);
      await box.close();
    });

    test('score unavailable cannot generate normal ready plan', () {
      final base = _pack();
      final pack = ProfilePack(
        id: base.id,
        source: base.source,
        createdAt: base.createdAt,
        lastRecalculatedAt: base.lastRecalculatedAt,
        domains: base.domains,
        recoveryScore: RecoveryScore.unavailable,
        confidence: MeasurementConfidence.provisional,
        explanation: base.explanation,
        profileSchemaVersion: base.profileSchemaVersion,
        domainAggregationModelVersion: base.domainAggregationModelVersion,
      );
      final plan = RecoveryPlanEngineV1.generate(pack);
      expect(plan.isStarterFallback, isTrue);
      expect(plan.generationStatus, RecoveryPlanStatus.starterFallback);
      expect(plan.generationStatus, isNot(RecoveryPlanStatus.ready));
    });

    test('Profile → PLN-00 / PLN-01 routes exist', () {
      expect(AppRoutes.v2PlanBuilding, '/v2/plan/building');
      expect(AppRoutes.v2PlanReveal, '/v2/plan');
      expect(AppRoutes.v2PlanTodayPreview, '/v2/plan/today-preview');
      expect(AppRoutes.v2PlanTodayReady, '/v2/plan/today-ready');
    });
  });

  group('ONB-08 / ONB-09 / ONB-10 milestones', () {
    test('plan reveal persists; journey not complete yet', () async {
      final c = V2OnboardingController(repository: _MemoryOnboardingRepo());
      await c.hydrate();
      await c.markReadyForBrainCheck();
      await c.markProfileRevealed(sessionId: 'sess_ft');
      await c.markPlanRevealed(planId: 'plan_1');
      expect(c.state.currentStep, V2OnboardingStep.planReveal);
      expect(c.state.planRevealed, isTrue);
      expect(c.state.planId, 'plan_1');
      expect(c.state.status, isNot(V2OnboardingStatus.completed));
      await c.markPlanRevealed(planId: 'plan_1');
      expect(c.state.planId, 'plan_1');
      expect(V2OnboardingStep.planReveal.screenId, 'ONB-08');
    });

    test('today preview milestone persists', () async {
      final c = V2OnboardingController(repository: _MemoryOnboardingRepo());
      await c.hydrate();
      await c.markReadyForBrainCheck();
      await c.markProfileRevealed(sessionId: 'sess_ft');
      await c.markPlanRevealed(planId: 'plan_1');
      await c.markTodayPreviewed(planId: 'plan_1');
      expect(c.state.currentStep, V2OnboardingStep.todayPreview);
      expect(c.state.todayPreviewed, isTrue);
      expect(c.state.status, isNot(V2OnboardingStatus.completed));
      expect(V2OnboardingStep.todayPreview.screenId, 'ONB-09');
    });

    test('journey completion requires plan reveal; is idempotent', () async {
      final c = V2OnboardingController(repository: _MemoryOnboardingRepo());
      await c.hydrate();
      await c.markReadyForBrainCheck();
      await c.markJourneyCompleted(planId: 'plan_premature');
      expect(c.state.status, isNot(V2OnboardingStatus.completed));

      await c.markProfileRevealed(sessionId: 'sess_ft');
      await c.markPlanRevealed(planId: 'plan_1');
      await c.markTodayPreviewed(planId: 'plan_1');
      await c.markJourneyCompleted(planId: 'plan_1');
      final first = c.state.journeyCompletedAt;
      expect(c.state.isJourneyComplete, isTrue);
      expect(c.state.status, V2OnboardingStatus.completed);
      await c.markJourneyCompleted(planId: 'plan_1');
      expect(c.state.journeyCompletedAt, first);
      await c.markReadyForBrainCheck();
      expect(c.state.status, V2OnboardingStatus.completed);
    });

    test('locale switch fields persist with milestone', () async {
      final repo = _MemoryOnboardingRepo();
      final c1 = V2OnboardingController(repository: repo);
      await c1.hydrate(languageCode: 'en');
      await c1.markReadyForBrainCheck();
      await c1.markPlanRevealed(planId: 'plan_1');
      await repo.save(c1.state.copyWith(languageCode: 'ar'));
      final c2 = V2OnboardingController(repository: repo);
      await c2.hydrate(languageCode: 'ar');
      expect(c2.state.planRevealed, isTrue);
      expect(c2.state.planId, 'plan_1');
      expect(c2.state.languageCode, 'ar');
    });

    test('controller recreation preserves state', () async {
      final repo = _MemoryOnboardingRepo();
      final c1 = V2OnboardingController(repository: repo);
      await c1.hydrate();
      await c1.markReadyForBrainCheck();
      await c1.markPlanRevealed(planId: 'plan_x');
      await c1.markTodayPreviewed(planId: 'plan_x');
      final c2 = V2OnboardingController(repository: repo);
      await c2.hydrate();
      expect(c2.state.todayPreviewed, isTrue);
      expect(c2.state.planId, 'plan_x');
    });
  });

  group('returning-user routing', () {
    test('not started → onboarding', () {
      final d = V2FirstTimeJourneyResolver.resolve(
        V2FirstTimeJourneySnapshot(onboarding: V2OnboardingState.fresh()),
      );
      expect(d.destination, V2FirstTimeDestination.onboarding);
    });

    test('brain check draft → entry', () {
      final onb = V2OnboardingState.fresh().copyWith(
        status: V2OnboardingStatus.readyForBrainCheck,
        brainCheckReady: true,
        currentStep: V2OnboardingStep.checkIntro,
      );
      final d = V2FirstTimeJourneyResolver.resolve(
        V2FirstTimeJourneySnapshot(
          onboarding: onb,
          checkProgress: _draft(),
        ),
      );
      expect(d.destination, V2FirstTimeDestination.brainCheckEntry);
      expect(d.reason, 'brain_check_draft');
    });

    test('completed check missing profile → building', () {
      final onb = V2OnboardingState.fresh().copyWith(
        status: V2OnboardingStatus.readyForBrainCheck,
        brainCheckReady: true,
        currentStep: V2OnboardingStep.checkIntro,
      );
      final d = V2FirstTimeJourneyResolver.resolve(
        V2FirstTimeJourneySnapshot(
          onboarding: onb,
          hasCompletedCheck: true,
        ),
      );
      expect(d.destination, V2FirstTimeDestination.brainCheckBuilding);
    });

    test('profile missing plan → PLN-00', () {
      final onb = V2OnboardingState.fresh().copyWith(
        status: V2OnboardingStatus.readyForBrainCheck,
        brainCheckReady: true,
        profileRevealed: true,
        currentStep: V2OnboardingStep.profileReveal,
      );
      final d = V2FirstTimeJourneyResolver.resolve(
        V2FirstTimeJourneySnapshot(
          onboarding: onb,
          hasCompletedCheck: true,
          hasProfilePack: true,
        ),
      );
      expect(d.destination, V2FirstTimeDestination.planBuilding);
    });

    test('plan ready incomplete → PLN-01', () {
      final onb = V2OnboardingState.fresh().copyWith(
        status: V2OnboardingStatus.readyForBrainCheck,
        brainCheckReady: true,
        profileRevealed: true,
      );
      final d = V2FirstTimeJourneyResolver.resolve(
        V2FirstTimeJourneySnapshot(
          onboarding: onb,
          hasCompletedCheck: true,
          hasProfilePack: true,
          hasActivePlan: true,
          activePlanId: 'plan_1',
        ),
      );
      expect(d.destination, V2FirstTimeDestination.planReveal);
      expect(d.location, contains('plan_1'));
    });

    test('plan revealed → today preview', () {
      final onb = V2OnboardingState.fresh().copyWith(
        status: V2OnboardingStatus.readyForBrainCheck,
        brainCheckReady: true,
        profileRevealed: true,
        planRevealed: true,
        planId: 'plan_1',
        currentStep: V2OnboardingStep.planReveal,
      );
      final d = V2FirstTimeJourneyResolver.resolve(
        V2FirstTimeJourneySnapshot(
          onboarding: onb,
          hasCompletedCheck: true,
          hasProfilePack: true,
          hasActivePlan: true,
          activePlanId: 'plan_1',
        ),
      );
      expect(d.destination, V2FirstTimeDestination.todayPreview);
    });

    test('journey complete → today ready', () {
      final onb = V2OnboardingState.fresh().copyWith(
        status: V2OnboardingStatus.completed,
        brainCheckReady: true,
        profileRevealed: true,
        planRevealed: true,
        todayPreviewed: true,
        planId: 'plan_1',
        journeyCompletedAt: DateTime.utc(2026, 8, 2),
        currentStep: V2OnboardingStep.todayPreview,
      );
      final d = V2FirstTimeJourneyResolver.resolve(
        V2FirstTimeJourneySnapshot(
          onboarding: onb,
          hasCompletedCheck: true,
          hasProfilePack: true,
          hasActivePlan: true,
          activePlanId: 'plan_1',
        ),
      );
      expect(d.destination, V2FirstTimeDestination.todayHome);
      expect(d.reason, 'journey_complete');
    });

    test('invalid / calm recovery when flags inconsistent', () {
      final onb = V2OnboardingState.fresh().copyWith(
        status: V2OnboardingStatus.readyForBrainCheck,
        brainCheckReady: false,
        currentStep: V2OnboardingStep.profileReveal,
      );
      final d = V2FirstTimeJourneyResolver.resolve(
        V2FirstTimeJourneySnapshot(onboarding: onb),
      );
      expect(
        d.destination == V2FirstTimeDestination.calmRecovery ||
            d.destination == V2FirstTimeDestination.planBuilding ||
            d.destination == V2FirstTimeDestination.brainCheckEntry,
        isTrue,
      );
    });
  });

  group('PLN-01 + ONB-09 + Today-ready UI', () {
    testWidgets('PLN-01 shows focus, priorities, stronger, confidence, time, paths, because, TodayAct',
        (tester) async {
      final plan = RecoveryPlanEngineV1.generate(_pack());
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpWidget(
        wrap(
          PlanRevealBody(
            loc: loc,
            languageCode: 'en',
            loading: false,
            missing: false,
            plan: plan,
            onGoHome: () {},
            onContinue: () {},
            onRebuild: () {},
          ),
        ),
      );
      expect(find.text(loc.recoveryPlanCalmOrientation), findsOneWidget);
      expect(find.text(loc.recoveryPlanMainFocus), findsOneWidget);
      expect(find.text(loc.recoveryPlanFitsProfile), findsOneWidget);
      expect(find.text(loc.recoveryPlanPrioritiesHeading), findsOneWidget);
      expect(find.text(loc.recoveryPlanStrongerHeading), findsOneWidget);
      expect(find.text(loc.recoveryPlanConfidenceHeading), findsOneWidget);
      expect(find.text(loc.recoveryPlanTimeHeading), findsOneWidget);
      expect(find.text(loc.recoveryPlanMinimumPath), findsOneWidget);
      expect(find.text(loc.recoveryPlanStandardPath), findsOneWidget);
      expect(find.text(loc.recoveryPlanTodayPreview), findsOneWidget);
      expect(find.textContaining(plan.todayBecause.textEn), findsWidgets);
      final title = resolveTodayActTitle(plan, 'en');
      expect(title, isNotNull);
      expect(find.text(title!), findsWidgets);
      expect(find.widgetWithText(FilledButton, loc.recoveryPlanContinueToday),
          findsOneWidget);
    });

    testWidgets('ONB-09 preview body fields', (tester) async {
      final plan = RecoveryPlanEngineV1.generate(_pack());
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpWidget(
        wrap(
          PlanTodayPreviewBody(
            loc: loc,
            languageCode: 'en',
            loading: false,
            errorKey: null,
            plan: plan,
            onRetry: () {},
            onRebuildPlan: () {},
            onContinue: () {},
          ),
        ),
      );
      expect(find.text(loc.v2TodayPreviewHeading), findsOneWidget);
      expect(find.text(loc.v2TodayPreviewCompletionMeaning), findsOneWidget);
      expect(find.textContaining(plan.dayTemplate.todayPreview.because.textEn),
          findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, loc.v2TodayPreviewContinueCta),
        findsOneWidget,
      );
    });

    testWidgets('Today-ready first step ready + a11y scroll', (tester) async {
      final plan = RecoveryPlanEngineV1.generate(_pack());
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.binding.setSurfaceSize(const Size(320, 480));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 480),
            textScaler: TextScaler.linear(2.0),
          ),
          child: wrap(
            PlanTodayReadyBody(
              loc: loc,
              languageCode: 'en',
              loading: false,
              errorKey: null,
              plan: plan,
              journeyMarked: true,
              onRetry: () {},
              onRebuildPlan: () {},
              onStay: () {},
              onOpenPreview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(loc.v2TodayReadyFirstStepTitle), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
      final targets = tester.widgetList<FilledButton>(find.byType(FilledButton));
      for (final b in targets) {
        expect(b, isNotNull);
      }
      expect(find.byType(FilledButton), findsWidgets);
    });

    testWidgets('Arabic RTL loads on Today-ready', (tester) async {
      final plan = RecoveryPlanEngineV1.generate(_pack());
      final loc = await AppLocalizations.delegate.load(const Locale('ar'));
      await tester.pumpWidget(
        wrap(
          PlanTodayReadyBody(
            loc: loc,
            languageCode: 'ar',
            loading: false,
            errorKey: null,
            plan: plan,
            journeyMarked: true,
            onRetry: () {},
            onRebuildPlan: () {},
            onStay: () {},
            onOpenPreview: () {},
          ),
          locale: const Locale('ar'),
        ),
      );
      expect(find.text(loc.v2TodayReadyFirstStepTitle), findsOneWidget);
      final ctx = tester.element(find.text(loc.v2TodayReadyFirstStepTitle));
      expect(Directionality.of(ctx), TextDirection.rtl);
    });

    testWidgets('missing plan error offers rebuild', (tester) async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpWidget(
        wrap(
          PlanTodayReadyBody(
            loc: loc,
            languageCode: 'en',
            loading: false,
            errorKey: 'missing_plan',
            plan: null,
            journeyMarked: false,
            onRetry: () {},
            onRebuildPlan: () {},
            onStay: () {},
            onOpenPreview: () {},
          ),
        ),
      );
      expect(find.text(loc.recoveryPlanMissing), findsOneWidget);
      expect(find.text(loc.recoveryPlanBuildCta), findsOneWidget);
    });
  });

  group('boundary / privacy / V1', () {
    test('feature flag OFF preserves V1 gate', () {
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(V2FeatureBoundary.enableV2OnboardingRoutes, isFalse);
      expect(V2FeatureBoundary.enableRecoveryPlanRoutes, isFalse);
    });

    test('no HOM-01 / SES player / ads / premium / safa routes in Slice 5.4', () {
      expect(AppRoutes.v2PlanTodayReady.contains('session'), isFalse);
      expect(AppRoutes.v2PlanTodayPreview.contains('safa'), isFalse);
      expect(AppRoutes.v2PlanTodayReady.contains('premium'), isFalse);
      expect(AppRoutes.v2PlanTodayReady.contains('/ads'), isFalse);
      expect(AppRoutes.v2PlanTodayPreview.endsWith('today-preview'), isTrue);
      expect(AppRoutes.v2PlanTodayReady.endsWith('today-ready'), isTrue);
    });

    test('copy avoids diagnosis/treatment/cure wording', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      final blob = [
        en.recoveryPlanCalmOrientationBody,
        en.v2TodayReadyFirstStepBody,
        en.v2TodayPreviewOrientation,
        ar.recoveryPlanCalmOrientationBody,
        ar.v2TodayReadyFirstStepBody,
      ].join(' ').toLowerCase();
      expect(blob.contains('diagnose you'), isFalse);
      expect(RegExp(r'\bcure\b').hasMatch(blob), isFalse);
      expect(blob.contains('clinical'), isFalse);
      expect(en.recoveryPlanCalmOrientationBody.toLowerCase(),
          contains('not a diagnosis'));
    });

    test('MeasurementEvent type unchanged for V1 storage', () {
      final e = MeasurementEvent(
        id: 'v1',
        mode: BrainCheckMode.lite,
        capturedAt: DateTime.utc(2026, 1, 1),
        answers: const {},
        sectionIds: const [],
      );
      expect(e.toJson()['id'], 'v1');
      expect(e.mode, BrainCheckMode.lite);
    });

    test('Recovery Plan schema version stamp preserved', () {
      final plan = RecoveryPlanEngineV1.generate(_pack());
      expect(plan.schemaVersion, RecoveryPlanVersions.schema);
      expect(plan.engineVersion, RecoveryPlanVersions.engine);
    });
  });
}
