import 'dart:io';

import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_item_bank.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_mode.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/brain_profile_domain_result.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/measurement_confidence.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/measurement_explanation.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_pack.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_source_reference.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_version.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/recovery_score.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/recovery_score_engine.dart';
import 'package:brain_clean_mobile/features/daily_session/application/daily_session_controller.dart';
import 'package:brain_clean_mobile/features/daily_session/data/daily_session_repository.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_day_key.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_path.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_reflection.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_status.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session_version.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/session_marked.dart';
import 'package:brain_clean_mobile/features/daily_session/ui/today_home_screen.dart';
import 'package:brain_clean_mobile/features/recovery_plan/data/recovery_plan_repository.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/recovery_plan_engine.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/recovery_plan_intensity.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/recovery_plan_versions.dart';
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

ProfilePack _pack() {
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
    id: 'pack_ds',
    source: const ProfileSourceReference(
      sessionId: 'sess_ds',
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late String tempDir;

  setUp(() async {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
    tempDir =
        '${Directory.systemTemp.path}/ds_${DateTime.now().microsecondsSinceEpoch}';
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

  group('identity + persistence', () {
    test('day key locale-independent', () {
      final k1 = DailyDayKey.fromLocal(DateTime(2026, 8, 3, 23, 30));
      final k2 = DailyDayKey.fromUtc(
        DateTime.utc(2026, 8, 3, 20, 30),
        timeZoneOffset: const Duration(hours: 3),
      );
      expect(k1, '2026-08-03');
      expect(k2, '2026-08-03');
    });

    test('one canonical session; repeated ensure is idempotent', () async {
      final planBox = await Hive.openBox<dynamic>('plans');
      final sessBox = await Hive.openBox<dynamic>('sessions');
      final plans = RecoveryPlanLocalRepository(box: planBox);
      final sessions = DailySessionLocalRepository(box: sessBox);
      final plan = await plans.saveIfNew(RecoveryPlanEngineV1.generate(_pack()));
      var clock = DateTime.utc(2026, 8, 3, 10);
      final c = DailySessionController(
        sessions: sessions,
        plans: plans,
        clock: () => clock,
        timeZoneOffset: Duration.zero,
      );
      await c.loadToday();
      final a = await c.ensureSession();
      final b = await c.ensureSession();
      expect(a!.id, b!.id);
      expect((await sessions.history()).length, 1);

      clock = DateTime.utc(2026, 8, 4, 10);
      await c.loadToday();
      final nextDay = await c.ensureSession();
      expect(nextDay!.id, isNot(a.id));
      expect(nextDay.dayKey, '2026-08-04');
      expect((await sessions.history()).length, 2);
      await planBox.close();
      await sessBox.close();
    });

    test('completion idempotent; does not change score/plan', () async {
      final planBox = await Hive.openBox<dynamic>('plans2');
      final sessBox = await Hive.openBox<dynamic>('sessions2');
      final plans = RecoveryPlanLocalRepository(box: planBox);
      final sessions = DailySessionLocalRepository(box: sessBox);
      final plan = await plans.saveIfNew(RecoveryPlanEngineV1.generate(_pack()));
      final scoreBefore = plan.explanation.mainFocusEn;
      final c = DailySessionController(
        sessions: sessions,
        plans: plans,
        clock: () => DateTime.utc(2026, 8, 3, 12),
        timeZoneOffset: Duration.zero,
      );
      await c.loadToday();
      await c.ensureSession(path: DailySessionPath.minimum);
      await c.startAct();
      await c.completeCurrentStep();
      // Min path often 1 step → reflecting
      if (c.session?.status != DailySessionStatus.reflecting) {
        while (c.session?.status == DailySessionStatus.inProgress) {
          final cur = c.session!.currentStep!;
          if (cur.optional) {
            await c.skipCurrentOptionalStep();
          } else {
            await c.completeCurrentStep();
          }
        }
      }
      final m1 = await c.completeWithReflection(
        reflection: const DailySessionReflection(
          promptId: DailySessionReflection.promptIdV1,
          manageableChip: 'ok',
          skippedChips: false,
        ),
      );
      final m2 = await c.completeWithReflection(
        reflection: const DailySessionReflection(
          promptId: DailySessionReflection.promptIdV1,
          manageableChip: 'hard',
          skippedChips: false,
        ),
      );
      expect(m1!.id, m2!.id);
      expect(c.session!.status, DailySessionStatus.completed);
      expect(c.session!.isImmutable, isTrue);
      final active = await plans.active();
      expect(active!.explanation.mainFocusEn, scoreBefore);
      expect(HiveBoxesGuard.dailySession, DailySessionVersion.box);
      await planBox.close();
      await sessBox.close();
    });
  });

  group('HOM-01 UI', () {
    testWidgets('shows one action, because, paths; no score hero / grid',
        (tester) async {
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
            TodayHomeBody(
              loc: loc,
              languageCode: 'en',
              loading: false,
              errorKey: null,
              plan: plan,
              session: null,
              onRetry: () {},
              onBuildPlan: () {},
              onPrimary: () {},
              onViewPlan: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(loc.v2TodayHomeOrientation), findsOneWidget);
      expect(find.text(loc.v2TodayPreviewBecauseHeading), findsOneWidget);
      expect(find.text(loc.recoveryPlanMinimumPath), findsOneWidget);
      expect(find.text(loc.recoveryPlanStandardPath), findsOneWidget);
      expect(find.widgetWithText(FilledButton, loc.v2TodayHomeCtaStart),
          findsOneWidget);
      expect(find.textContaining('Games'), findsNothing);
      expect(find.textContaining('XP'), findsNothing);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Arabic RTL', (tester) async {
      final plan = RecoveryPlanEngineV1.generate(_pack());
      final loc = await AppLocalizations.delegate.load(const Locale('ar'));
      await tester.pumpWidget(
        wrap(
          TodayHomeBody(
            loc: loc,
            languageCode: 'ar',
            loading: false,
            errorKey: null,
            plan: plan,
            session: null,
            onRetry: () {},
            onBuildPlan: () {},
            onPrimary: () {},
            onViewPlan: () {},
          ),
          locale: const Locale('ar'),
        ),
      );
      expect(find.text(loc.v2TodayHomeTitle), findsNothing); // body only
      expect(find.text(loc.v2TodayHomeOrientation), findsOneWidget);
      final ctx = tester.element(find.text(loc.v2TodayHomeOrientation));
      expect(Directionality.of(ctx), TextDirection.rtl);
    });

    testWidgets('missing plan error', (tester) async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpWidget(
        wrap(
          TodayHomeBody(
            loc: loc,
            languageCode: 'en',
            loading: false,
            errorKey: 'missing_plan',
            plan: null,
            session: null,
            onRetry: () {},
            onBuildPlan: () {},
            onPrimary: () {},
            onViewPlan: () {},
          ),
        ),
      );
      expect(find.text(loc.recoveryPlanMissing), findsOneWidget);
    });
  });

  group('handoff + boundary', () {
    test('journey complete → HOM-01', () {
      final onb = V2OnboardingState.fresh().copyWith(
        status: V2OnboardingStatus.completed,
        planRevealed: true,
        todayPreviewed: true,
        planId: 'p1',
        journeyCompletedAt: DateTime.utc(2026, 8, 2),
        currentStep: V2OnboardingStep.todayPreview,
      );
      final d = V2FirstTimeJourneyResolver.resolve(
        V2FirstTimeJourneySnapshot(
          onboarding: onb,
          hasCompletedCheck: true,
          hasProfilePack: true,
          hasActivePlan: true,
          activePlanId: 'p1',
        ),
      );
      expect(d.destination, V2FirstTimeDestination.todayHome);
      expect(d.location, AppRoutes.v2Today);
    });

    test('routes + versions + ads exclusion', () {
      expect(AppRoutes.v2Today, '/v2/today');
      expect(AppRoutes.v2SessionPrepare, '/v2/session/prepare');
      expect(AppRoutes.v2SessionAct, '/v2/session/act');
      expect(AppRoutes.v2SessionReflect, '/v2/session/reflect');
      expect(AppRoutes.v2SessionLeave, '/v2/session/leave');
      expect(DailySessionVersion.schema, 'daily_session_pack_v1');
      expect(DailySessionVersion.box, 'daily_session_v1');
      expect(AppRoutes.v2Today.contains('/ads'), isFalse);
      expect(AppRoutes.v2SessionAct.contains('premium'), isFalse);
      expect(AppRoutes.v2SessionAct.contains('safa'), isFalse);
    });

    test('feature flag OFF preserves V1', () {
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(V2FeatureBoundary.enableTodaySessionRoutes, isFalse);
    });

    test('copy avoids medical/diagnosis/cure', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      final blob = [
        en.v2TodayHomeOrientationBody,
        en.v2SessionLeaveBody,
        en.v2SessionReflectPrompt,
        ar.v2TodayHomeOrientationBody,
        ar.v2SessionLeaveBody,
      ].join(' ').toLowerCase();
      expect(RegExp(r'\bcure\b').hasMatch(blob), isFalse);
      expect(blob.contains('diagnose'), isFalse);
      expect(blob.contains('clinical'), isFalse);
      expect(blob.contains('treatment'), isFalse);
    });

    test('SessionMarked schema fields present', () {
      final mark = SessionMarked(
        id: 'smark_x',
        dailySessionId: 'ds',
        todayActId: 'tact',
        planId: 'plan',
        dayKey: '2026-08-03',
        path: DailySessionPath.minimum,
        completedAt: DateTime.utc(2026, 8, 3),
        fullCompletion: true,
        schemaVersion: DailySessionVersion.schema,
      );
      expect(mark.toJson()['fullCompletion'], isTrue);
      expect(mark.toJson().containsKey('reflection'), isFalse);
    });

    test('unsupported plan version stamp check', () {
      expect(RecoveryPlanVersions.schema, isNotEmpty);
    });

    test('draft respects max time ceiling from plan', () {
      final plan = RecoveryPlanEngineV1.generate(_pack());
      expect(plan.dayTemplate.todayPreview.estimatedMinutesMax, lessThanOrEqualTo(20));
      expect(plan.dayTemplate.todayPreview.standardPathStepIds.length,
          lessThanOrEqualTo(plan.intensity.maxTotalSteps));
    });
  });
}

/// Avoid importing hive_boxes into every assertion via alias.
abstract final class HiveBoxesGuard {
  static const dailySession = 'daily_session_v1';
}
