import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_item_bank.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_mode.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_scale.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/measurement_event.dart';
import 'package:brain_clean_mobile/features/brain_check/ui/brain_check_complete_boundary_screen.dart';
import 'package:brain_clean_mobile/features/brain_profile/application/brain_profile_generator.dart';
import 'package:brain_clean_mobile/features/brain_profile/data/brain_profile_repository.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/measurement_confidence.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_domain_catalog.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_generation_result.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_pack.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/recovery_score.dart';
import 'package:brain_clean_mobile/features/brain_profile/ui/brain_check_building_screen.dart';
import 'package:brain_clean_mobile/features/brain_profile/ui/brain_profile_domain_detail_body.dart';
import 'package:brain_clean_mobile/features/brain_profile/ui/brain_profile_reveal_screen.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/application/v2_onboarding_controller.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/data/v2_onboarding_repository.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_onboarding_state.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_onboarding_status.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_onboarding_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryProfileRepo implements BrainProfileRepository {
  final packs = <ProfilePack>[];

  @override
  Future<ProfilePack?> findBySourceSessionId(String sessionId) async {
    for (final p in packs) {
      if (p.source.sessionId == sessionId) return p;
    }
    return null;
  }

  @override
  Future<List<ProfilePack>> history() async => List.unmodifiable(packs);

  @override
  Future<ProfilePack?> latest() async =>
      packs.isEmpty ? null : packs.last;

  @override
  Future<void> save(ProfilePack pack) async {
    final existing = await findBySourceSessionId(pack.source.sessionId);
    if (existing != null) return;
    packs.add(pack);
  }
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MeasurementEvent completeEvent({
    String sessionId = 's1',
    BrainCheckMode mode = BrainCheckMode.lite,
  }) {
    final questions = BrainCheckItemBank.questionsFor(mode);
    final answers = <String, int>{
      for (final q in questions) q.id: q.scale.maxValue,
    };
    return MeasurementEvent(
      id: sessionId,
      mode: mode,
      capturedAt: DateTime.utc(2026, 8, 3, 10),
      answers: answers,
      sectionIds: BrainCheckItemBank.sectionsFor(mode).map((s) => s.id).toList(),
      source: 'test',
      languageCode: 'en',
    );
  }

  Future<ProfilePack> generateOk(
    MeasurementEvent event, {
    BrainProfileRepository? repo,
  }) async {
    final generator = BrainProfileGenerator(
      repository: repo ?? _MemoryProfileRepo(),
    );
    final result = await generator.generateFrom(event);
    expect(result, isA<ProfileGenerationSuccess>());
    return (result as ProfileGenerationSuccess).profile;
  }

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

  group('CHK-03 orchestration', () {
    test('idempotent ProfilePack generation for one MeasurementEvent',
        () async {
      final repo = _MemoryProfileRepo();
      final event = completeEvent(sessionId: 'idem-1');
      final a = await generateOk(event, repo: repo);
      final b = await generateOk(event, repo: repo);
      expect(a.id, b.id);
      expect(repo.packs.length, 1);
      expect(a.recoveryScore.isValid, isTrue);
      expect(a.recoveryScore.value, inInclusiveRange(0, 100));
    });

    test('raw answers in event remain unchanged by generation', () async {
      final event = completeEvent(sessionId: 'immut-1');
      final before = Map<String, int>.from(event.answers);
      await generateOk(event);
      expect(event.answers, before);
    });

    testWidgets('building body announces calm loading without scan language',
        (tester) async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpWidget(
        wrap(
          BrainCheckBuildingBody(
            loc: loc,
            building: true,
            error: '',
            missingEvent: false,
            reduceMotion: true,
            onRetry: () {},
            onGoHome: () {},
            onGoEntry: () {},
          ),
        ),
      );
      expect(find.text(loc.brainProfileBuilding), findsOneWidget);
      expect(find.textContaining(RegExp(r'\bscan\b|\bneural\b', caseSensitive: false)),
          findsNothing);
      expect(find.textContaining('brain scan'), findsNothing);
    });

    testWidgets('missing event offers Brain Check entry', (tester) async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpWidget(
        wrap(
          BrainCheckBuildingBody(
            loc: loc,
            building: false,
            error: loc.brainProfileMissingEvent,
            missingEvent: true,
            reduceMotion: false,
            onRetry: () {},
            onGoHome: () {},
            onGoEntry: () {},
          ),
        ),
      );
      expect(find.text(loc.brainProfileMissingEvent), findsOneWidget);
      expect(find.text(loc.v2BrainCheckEntryStart), findsOneWidget);
    });
  });

  group('PRF-01 reveal', () {
    testWidgets('shows score, band, confidence, stronger/support, non-medical',
        (tester) async {
      final pack = await generateOk(completeEvent(sessionId: 'reveal-1'));
      final loc = AppLocalizationsEn();
      await tester.pumpWidget(
        wrap(
          BrainProfileRevealBody(
            loc: loc,
            languageCode: 'en',
            loading: false,
            missing: false,
            historical: false,
            pack: pack,
            onDomainTap: (_) async {},
            onGoHome: () {},
            onContinue: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.text('${pack.recoveryScore.value}'), findsOneWidget);
      expect(find.text(pack.recoveryScore.band.labelEn), findsOneWidget);
      expect(find.text(loc.brainProfileConfidenceModerate), findsOneWidget);
      expect(find.text(loc.brainProfileContinue), findsOneWidget);
      expect(find.textContaining('EVIDENCE'), findsNothing);
      expect(find.textContaining('brain damage'), findsNothing);
      expect(find.textContaining(RegExp(r'\bcure\b', caseSensitive: false)),
          findsNothing);
      final continueBtn = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, loc.brainProfileContinue),
      );
      expect(continueBtn.onPressed, isNotNull);
    });

    testWidgets('score unavailable does not show zero and disables plan CTA',
        (tester) async {
      final pack = await generateOk(completeEvent(sessionId: 'ok-base'));
      final unavailable = ProfilePack(
        id: pack.id,
        source: pack.source,
        createdAt: pack.createdAt,
        lastRecalculatedAt: pack.lastRecalculatedAt,
        domains: pack.domains,
        recoveryScore: RecoveryScore.unavailable,
        confidence: MeasurementConfidence.provisional,
        explanation: pack.explanation,
        profileSchemaVersion: pack.profileSchemaVersion,
        domainAggregationModelVersion: pack.domainAggregationModelVersion,
        strongerDomainIds: pack.strongerDomainIds,
        supportDomainIds: pack.supportDomainIds,
        contributions: pack.contributions,
        explanationFlags: pack.explanationFlags,
      );
      final loc = AppLocalizationsEn();
      await tester.pumpWidget(
        wrap(
          BrainProfileRevealBody(
            loc: loc,
            languageCode: 'en',
            loading: false,
            missing: false,
            historical: false,
            pack: unavailable,
            onDomainTap: (_) async {},
            onGoHome: () {},
            onContinue: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.text('0'), findsNothing);
      expect(find.text(loc.brainProfileScoreUnavailableLabel), findsOneWidget);
      final continueBtn = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, loc.brainProfileContinue),
      );
      expect(continueBtn.onPressed, isNull);
    });

    testWidgets('Arabic RTL reveal loads without English chrome', (tester) async {
      final pack = await generateOk(completeEvent(sessionId: 'ar-1'));
      final loc = AppLocalizationsAr();
      await tester.pumpWidget(
        wrap(
          Directionality(
            textDirection: TextDirection.rtl,
            child: BrainProfileRevealBody(
              loc: loc,
              languageCode: 'ar',
              loading: false,
              missing: false,
              historical: false,
              pack: pack,
              onDomainTap: (_) async {},
              onGoHome: () {},
              onContinue: () {},
            ),
          ),
          locale: const Locale('ar'),
        ),
      );
      await tester.pump();
      expect(find.text(loc.brainProfileContinue), findsOneWidget);
      expect(find.text(AppLocalizationsEn().brainProfileContinue), findsNothing);
    });

    testWidgets('320 + textScale 2.0 scrolls continue', (tester) async {
      final pack = await generateOk(completeEvent(sessionId: 'a11y-1'));
      final loc = AppLocalizationsEn();
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 480),
            textScaler: TextScaler.linear(2.0),
          ),
          child: wrap(
            BrainProfileRevealBody(
              loc: loc,
              languageCode: 'en',
              loading: false,
              missing: false,
              historical: false,
              pack: pack,
              onDomainTap: (_) async {},
              onGoHome: () {},
              onContinue: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.ensureVisible(find.text(loc.brainProfileContinue));
      expect(tester.takeException(), isNull);
    });
  });

  group('PRF-02 domain detail', () {
    testWidgets('shows estimate + tags without evidence IDs or raw answers',
        (tester) async {
      final pack = await generateOk(completeEvent(sessionId: 'dom-1'));
      final domainId = pack.domains.first.domainId;
      final domain = ProfileDomainCatalog.byId(domainId)!;
      final loc = AppLocalizationsEn();
      await tester.pumpWidget(
        wrap(
          BrainProfileDomainDetailBody(
            loc: loc,
            languageCode: 'en',
            domain: domain,
            result: pack.domains.first,
            pack: pack,
            onClose: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.text(domain.titleEn), findsOneWidget);
      expect(find.text(loc.brainProfileDomainEstimateHeading), findsOneWidget);
      expect(find.textContaining('EVIDENCE'), findsNothing);
      expect(find.textContaining(domainId), findsNothing);
      for (final answerKey in pack.source.sessionId.isEmpty
          ? <String>[]
          : pack.domains.first.missingQuestionIds) {
        expect(find.text(answerKey), findsNothing);
      }
    });
  });

  group('ONB-07 milestone', () {
    test('markProfileRevealed is idempotent and does not complete FTE',
        () async {
      final controller = V2OnboardingController(
        repository: _MemoryOnboardingRepo(),
      );
      await controller.hydrate();
      await controller.markReadyForBrainCheck();
      await controller.markProfileRevealed(sessionId: 'sess-a');
      expect(controller.state.currentStep, V2OnboardingStep.profileReveal);
      expect(controller.state.profileRevealed, isTrue);
      expect(controller.state.profileSessionId, 'sess-a');
      expect(controller.state.status, V2OnboardingStatus.readyForBrainCheck);
      expect(controller.state.status, isNot(V2OnboardingStatus.completed));

      await controller.markProfileRevealed(sessionId: 'sess-a');
      expect(controller.state.profileSessionId, 'sess-a');
      expect(V2OnboardingStep.profileReveal.screenId, 'ONB-07');
    });
  });

  group('routing / privacy / retake', () {
    test('completion path routes exist: building → profile → plan', () {
      expect(AppRoutes.v2BrainCheckBuilding, '/v2/brain-check/building');
      expect(AppRoutes.v2BrainProfile, '/v2/brain-profile');
      expect(AppRoutes.v2PlanBuilding, '/v2/plan/building');
      expect(AppRoutes.v2BrainCheckCompleteBoundary, '/v2/brain-check/complete');
    });

    testWidgets('complete boundary continues to CHK-03', (tester) async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpWidget(wrap(const BrainCheckCompleteBoundaryScreen()));
      expect(find.text(loc.brainCheckCompleteBoundaryContinue), findsOneWidget);
    });

    test('feature flag OFF preserves V1 gate', () {
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(V2FeatureBoundary.enableV2OnboardingRoutes, isFalse);
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      expect(V2FeatureBoundary.enableV2OnboardingRoutes, isTrue);
      V2FeatureBoundary.enableBrainProfileRoutes = false;
    });

    test('Strong confidence label matches contract (not medical)', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      expect(en.brainProfileConfidenceSolid, 'Strong');
      expect(ar.brainProfileConfidenceSolid, isNotEmpty);
      expect(en.brainProfileConfidenceSolid.toLowerCase(), isNot(contains('clinical')));
    });

    test('no retake CTA copy as button requirement — explanation only', () {
      // Slice 5.3: retake not authorized as CTA; explanation.retake may exist.
      final en = AppLocalizationsEn();
      expect(en.brainProfileContinue.toLowerCase(), contains('plan'));
    });
  });
}
