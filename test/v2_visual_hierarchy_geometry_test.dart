import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/theme/app_design_constants.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_item_bank.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_mode.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/brain_profile_domain_result.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/measurement_confidence.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/measurement_explanation.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_pack.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_source_reference.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_version.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/recovery_score.dart';
import 'package:brain_clean_mobile/features/daily_session/data/daily_session_repository.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/daily_session.dart';
import 'package:brain_clean_mobile/features/daily_session/domain/session_marked.dart';
import 'package:brain_clean_mobile/features/daily_session/ui/today_home_screen.dart';
import 'package:brain_clean_mobile/features/profile/ui/v2_profile_home_screen.dart';
import 'package:brain_clean_mobile/features/progress/application/progress_experience_controller.dart';
import 'package:brain_clean_mobile/features/progress/data/progress_repository.dart';
import 'package:brain_clean_mobile/features/progress/domain/progress_experience_enums.dart';
import 'package:brain_clean_mobile/features/progress/domain/progress_snapshot.dart';
import 'package:brain_clean_mobile/features/progress/domain/progress_view_model.dart';
import 'package:brain_clean_mobile/features/progress/ui/progress_home_screen.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/recovery_plan_engine.dart';
import 'package:brain_clean_mobile/features/recovery_plan/ui/plan_reveal_screen.dart';
import 'package:brain_clean_mobile/features/weekly_review/data/weekly_review_repository.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_artifact.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_record.dart';
import 'package:brain_clean_mobile/features/weekly_review/domain/weekly_review_signal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Visual-hierarchy geometry gates for V2 primary tabs.
/// Bounded pumps only — no pumpAndSettle.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProfilePack pack() {
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
      id: 'pack_visual',
      source: const ProfileSourceReference(
        sessionId: 'sess_visual',
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

  Widget wrap(Widget child, {Locale locale = const Locale('en')}) {
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
        home: Scaffold(body: child),
      ),
    );
  }

  Future<void> pumpBounded(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  void expectNoOverflow(WidgetTester tester) {
    expect(tester.takeException(), isNull);
  }

  group('V2 visual hierarchy geometry', () {
    testWidgets('Today EN/AR 320 no overflow; single primary Filled',
        (tester) async {
      final plan = RecoveryPlanEngineV1.generate(pack());
      for (final locale in [const Locale('en'), const Locale('ar')]) {
        final loc = await AppLocalizations.delegate.load(locale);
        await tester.binding.setSurfaceSize(const Size(320, 640));
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(320, 640)),
            child: wrap(
              TodayHomeBody(
                loc: loc,
                languageCode: locale.languageCode,
                loading: false,
                errorKey: null,
                plan: plan,
                session: null,
                onRetry: () {},
                onBuildPlan: () {},
                onStartBrainCheck: () {},
                onPrimary: () {},
                onViewPlan: () {},
                onOpenSafa: () {},
              ),
              locale: locale,
            ),
          ),
        );
        await pumpBounded(tester);
        expectNoOverflow(tester);
        expect(find.byKey(const Key('v2_today_primary_cta')), findsOneWidget);
        expect(
          tester.getSize(find.byKey(const Key('v2_today_primary_cta'))).height,
          greaterThanOrEqualTo(AppDesignConstants.minTouchTarget),
        );
        expect(find.byType(SingleChildScrollView), findsOneWidget);
        expect(find.byKey(const Key('v2_today_safa_entry')), findsOneWidget);
      }
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('Today textScale 2.0 remains scrollable', (tester) async {
      final plan = RecoveryPlanEngineV1.generate(pack());
      final loc = AppLocalizationsEn();
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
              onStartBrainCheck: () {},
              onPrimary: () {},
              onViewPlan: () {},
              onOpenSafa: () {},
            ),
          ),
        ),
      );
      await pumpBounded(tester);
      expectNoOverflow(tester);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await pumpBounded(tester);
      expect(find.byKey(const Key('v2_today_safa_entry')), findsOneWidget);
      expectNoOverflow(tester);
    });

    testWidgets('Program shell EN/AR 320; soft secondary CTA only',
        (tester) async {
      final plan = RecoveryPlanEngineV1.generate(pack());
      for (final locale in [const Locale('en'), const Locale('ar')]) {
        final loc = await AppLocalizations.delegate.load(locale);
        await tester.binding.setSurfaceSize(const Size(320, 640));
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(320, 640)),
            child: wrap(
              PlanRevealBody(
                loc: loc,
                languageCode: locale.languageCode,
                loading: false,
                missing: false,
                plan: plan,
                hasProfilePack: true,
                presentation: PlanRevealPresentation.shellOrientation,
                onGoHome: () {},
                onContinue: () {},
                onRebuild: () {},
                onStartBrainCheck: () {},
              ),
              locale: locale,
            ),
          ),
        );
        await pumpBounded(tester);
        expectNoOverflow(tester);
        expect(find.byType(FilledButton), findsNothing);
        expect(find.byType(OutlinedButton), findsOneWidget);
        expect(find.text(loc.recoveryPlanOpenToday), findsOneWidget);
      }
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('Program long Arabic thesis wraps without overflow',
        (tester) async {
      final plan = RecoveryPlanEngineV1.generate(pack());
      final loc = AppLocalizationsAr();
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(320, 640)),
          child: wrap(
            PlanRevealBody(
              loc: loc,
              languageCode: 'ar',
              loading: false,
              missing: false,
              plan: plan,
              hasProfilePack: true,
              presentation: PlanRevealPresentation.shellOrientation,
              onGoHome: () {},
              onContinue: () {},
              onRebuild: () {},
              onStartBrainCheck: () {},
            ),
            locale: const Locale('ar'),
          ),
        ),
      );
      await pumpBounded(tester);
      expectNoOverflow(tester);
      expect(find.byType(Wrap), findsWidgets);
    });

    testWidgets('Progress empty 320 single primary CTA', (tester) async {
      final c = ProgressExperienceController(
        sessions: _EmptySessions(),
        progress: _EmptyProgress(),
        reviews: _EmptyReviews(),
        clock: () => DateTime.utc(2026, 8, 3, 12),
        timeZoneOffset: Duration.zero,
      );
      c.phase = ProgressExperiencePhase.empty;
      c.viewModel = ProgressViewModel.empty();

      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(size: Size(320, 640)),
            child: ProgressHomeBody(controller: c, onRetry: () {}),
          ),
        ),
      );
      await pumpBounded(tester);
      expectNoOverflow(tester);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Profile EN/AR 320 grouped rows reachable', (tester) async {
      for (final locale in [const Locale('en'), const Locale('ar')]) {
        final loc = await AppLocalizations.delegate.load(locale);
        await tester.binding.setSurfaceSize(const Size(320, 640));
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(320, 640)),
            child: wrap(
              V2ProfileHomeBody(
                loc: loc,
                displayName: locale.languageCode == 'ar' ? 'أحمد' : 'Alex',
                purityDays: 12,
                notificationsEnabled: true,
                loadingSetup: false,
                hasBrainProfile: true,
                daysUntilWeeklyCheck: null,
                subscriptionSubtitle: loc.v2PremiumFreeStatus,
                isPro: false,
                appVersion: '2.0.1+22',
                onEditDisplayName: () {},
                onNotificationsChanged: (_) {},
                onOpenBrainProfile: () {},
          onOpenBaselineCheck: () {},
          onOpenWeeklyCheck: () {},
          onOpenTestsCatalog: () {},
                onOpenSettings: () {},
                onOpenPremium: () {},
                onOpenSafa: () {},
                onOpenPrivacyPolicy: () {},
                onOpenContact: () {},
              ),
              locale: locale,
            ),
          ),
        );
        await pumpBounded(tester);
        expectNoOverflow(tester);
        expect(
          find.byKey(const Key('v2_profile_settings_row')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('v2_profile_contact_row')),
          findsOneWidget,
        );
        expect(find.byType(FilledButton), findsNothing);
      }
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });
  });
}

class _EmptySessions implements DailySessionRepository {
  @override
  Future<DailySession?> active() async => null;
  @override
  Future<DailySession?> findById(String id) async => null;
  @override
  Future<DailySession?> findByTodayActAndDay({
    required String todayActId,
    required String dayKey,
  }) async =>
      null;
  @override
  Future<List<DailySession>> history() async => const [];
  @override
  Future<SessionMarked?> latestMark() async => null;
  @override
  Future<DailySession> save(DailySession session) async => session;
  @override
  Future<DailySession> saveCompletion({
    required DailySession session,
    required SessionMarked mark,
  }) async =>
      session;
}

class _EmptyProgress implements ProgressRepository {
  @override
  Future<ProgressSnapshot?> latest() async => null;
  @override
  Future<List<ProgressSnapshot>> history() async => const [];
  @override
  Future<ProgressSnapshot?> findById(String id) async => null;
  @override
  Future<ProgressSnapshot> saveIfNew(ProgressSnapshot snapshot) async =>
      snapshot;
}

class _EmptyReviews implements WeeklyReviewRepository {
  @override
  Future<WeeklyReviewRecord?> findByPeriod(String periodId) async => null;
  @override
  Future<WeeklyReviewRecord?> findById(String id) async => null;
  @override
  Future<WeeklyReviewRecord?> latestCompleted() async => null;
  @override
  Future<List<WeeklyReviewRecord>> history() async => const [];
  @override
  Future<WeeklyArtifact?> artifactByReviewId(String reviewId) async => null;
  @override
  Future<WeeklyArtifact?> artifactById(String artifactId) async => null;
  @override
  Future<List<WeeklyArtifact>> listArtifacts() async => const [];
  @override
  Future<WeeklyReviewSignal?> signalByArtifactId(String artifactId) async =>
      null;
  @override
  Future<WeeklyReviewSignal?> signalById(String signalId) async => null;
  @override
  Future<WeeklyReviewRecord> saveDraft(WeeklyReviewRecord draft) async => draft;
  @override
  Future<
      ({
        WeeklyReviewRecord record,
        WeeklyArtifact artifact,
        WeeklyReviewSignal signal
      })> complete({
    required WeeklyReviewRecord record,
    required WeeklyArtifact artifact,
    required WeeklyReviewSignal signal,
  }) async =>
      (record: record, artifact: artifact, signal: signal);
}
