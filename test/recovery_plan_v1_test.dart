import 'dart:io';

import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_item_bank.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_mode.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/brain_profile_domain_result.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/item_polarity.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/measurement_confidence.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/measurement_explanation.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_pack.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_source_reference.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_version.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/recovery_score.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/recovery_score_engine.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/score_calculation_result.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/measurement_event.dart';
import 'package:brain_clean_mobile/features/recovery_plan/data/recovery_plan_repository.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/intensity_selector.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/plan_because.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/priority_selector.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/recovery_plan.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/recovery_plan_engine.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/recovery_plan_intensity.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/recovery_plan_status.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/recovery_plan_versions.dart';
import 'package:brain_clean_mobile/features/recovery_plan/domain/recovery_practice_catalog.dart';
import 'package:brain_clean_mobile/features/recovery_plan/ui/plan_building_screen.dart';
import 'package:brain_clean_mobile/features/recovery_plan/ui/plan_reveal_screen.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String tempDir;

  setUp(() async {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
    tempDir =
        '${Directory.systemTemp.path}/rp_${DateTime.now().microsecondsSinceEpoch}';
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

  MeasurementEvent eventFor(
    BrainCheckMode mode,
    Map<String, int> answers, {
    String id = 'sess',
  }) {
    return MeasurementEvent(
      id: id,
      mode: mode,
      capturedAt: DateTime.utc(2026, 8, 2),
      answers: answers,
      sectionIds: BrainCheckItemBank.sectionsFor(mode)
          .map((s) => s.id)
          .toList(growable: false),
    );
  }

  Map<String, int> allAt(BrainCheckMode mode, int Function(String id) picker) {
    final map = <String, int>{};
    for (final q in BrainCheckItemBank.questionsFor(mode)) {
      map[q.id] = picker(q.id);
    }
    return map;
  }

  ProfilePack packFromAnswers(
    BrainCheckMode mode,
    Map<String, int> answers, {
    String id = 'pack1',
    String sessionId = 'sess1',
    MeasurementConfidence? forceConfidence,
  }) {
    final event = eventFor(mode, answers, id: sessionId);
    final result = RecoveryScoreEngine.compute(event);
    expect(result, isA<ScoreCalculationValid>());
    final valid = result as ScoreCalculationValid;
    return ProfilePack(
      id: id,
      source: ProfileSourceReference(
        sessionId: sessionId,
        mode: mode,
        brainCheckSchemaVersion: 'brain_check_measurement_v1',
      ),
      createdAt: DateTime.utc(2026, 8, 2),
      lastRecalculatedAt: DateTime.utc(2026, 8, 2),
      domains: valid.domains,
      recoveryScore: valid.recoveryScore,
      confidence: forceConfidence ?? valid.confidence,
      explanation: ProfileExplanationCatalog.build(
        strongerTitlesEn: const [],
        strongerTitlesAr: const [],
        supportTitlesEn: const [],
        supportTitlesAr: const [],
        confidence: forceConfidence ?? valid.confidence,
        scorePending: false,
      ),
      profileSchemaVersion: ProfileVersion.profileSchema,
      domainAggregationModelVersion: ProfileVersion.domainAggregationModel,
      strongerDomainIds: valid.strongerDomainIds,
      supportDomainIds: valid.supportDomainIds,
      contributions: valid.contributions,
    );
  }

  ProfilePack syntheticFull({
    required Map<String, int> domainScores,
    required int overall,
    required RecoveryScoreBand band,
    required MeasurementConfidence confidence,
    String id = 'pack_syn',
    String sessionId = 'sess_syn',
  }) {
    final domains = <BrainProfileDomainResult>[];
    for (final section in BrainCheckItemBank.sectionsFor(BrainCheckMode.full)) {
      final score = domainScores[section.id] ?? 50;
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
      recoveryScore: RecoveryScore(
        modelVersion: 'recovery_score_v1',
        band: band,
        value: overall,
        valueInternal: overall.toDouble(),
        weightSetVersion: 'weight_set_equal_v1',
      ),
      confidence: confidence,
      explanation: ProfileExplanationCatalog.build(
        strongerTitlesEn: const [],
        strongerTitlesAr: const [],
        supportTitlesEn: const [],
        supportTitlesAr: const [],
        confidence: confidence,
        scorePending: false,
      ),
      profileSchemaVersion: ProfileVersion.profileSchema,
      domainAggregationModelVersion: ProfileVersion.domainAggregationModel,
    );
  }

  group('catalog', () {
    test('has exactly 11 stable practice IDs', () {
      expect(RecoveryPracticeCatalog.allIds.length, 11);
      expect(
        RecoveryPracticeCatalog.allIds.toSet(),
        {
          'prac_single_task',
          'prac_notify_friction',
          'prac_settle_breath',
          'prac_screen_pause',
          'prac_offline_interval',
          'prac_body_move',
          'prac_sleep_winddown',
          'prac_one_change',
          'prac_env_reset',
          'prac_awareness_check',
          'prac_starter_calm',
        },
      );
      for (final id in RecoveryPracticeCatalog.allIds) {
        final p = RecoveryPracticeCatalog.byId(id);
        expect(p.accessibilityAltEn, isNotEmpty);
        expect(p.skipBehavior, 'allowed_no_penalty');
        expect(p.offline, isTrue);
      }
    });
  });

  group('engine generation', () {
    test('valid ProfilePack generates ready plan', () {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 35,
          'full_mood': 50,
          'full_habits': 55,
          'full_intention': 70,
        },
        overall: 52,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.strong,
      );
      final plan = RecoveryPlanEngineV1.generate(
        pack,
        createdAt: DateTime.utc(2026, 8, 2),
      );
      expect(plan.isStarterFallback, isFalse);
      expect(plan.generationStatus, RecoveryPlanStatus.ready);
      expect(plan.engineVersion, RecoveryPlanVersions.engine);
      expect(plan.steps, isNotEmpty);
      expect(plan.dayTemplate.todayPreview.id, startsWith('tact_'));
      expect(plan.cadence.standardPathMinutesMax, lessThanOrEqualTo(20));
      expect(plan.steps.length, lessThanOrEqualTo(3));
    });

    test('unavailable score → starter fallback', () {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 40,
          'full_mood': 50,
          'full_habits': 60,
          'full_intention': 70,
        },
        overall: 0,
        band: RecoveryScoreBand.unavailable,
        confidence: MeasurementConfidence.provisional,
      );
      // Force unavailable score object
      final forced = ProfilePack(
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
      );
      final plan = RecoveryPlanEngineV1.generate(forced);
      expect(plan.isStarterFallback, isTrue);
      expect(plan.steps.single.practiceId, 'prac_starter_calm');
      expect(plan.todayBecause.templateKey, PlanBecauseTemplates.starter);
      expect(plan.intensity, RecoveryPlanIntensity.light);
    });

    test('unsupported engine version → starter', () {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 40,
          'full_mood': 50,
          'full_habits': 60,
          'full_intention': 70,
        },
        overall: 55,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.strong,
      );
      final plan = RecoveryPlanEngineV1.generate(
        pack,
        requestedEngineVersion: 'recovery_plan_engine_v9',
      );
      expect(plan.isStarterFallback, isTrue);
    });

    test('identical inputs → identical plan id/hash', () {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 30,
          'full_mood': 55,
          'full_habits': 60,
          'full_intention': 70,
        },
        overall: 54,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.strong,
      );
      final a = RecoveryPlanEngineV1.generate(
        pack,
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final b = RecoveryPlanEngineV1.generate(
        pack,
        createdAt: DateTime.utc(2026, 2, 2),
      );
      expect(a.id, b.id);
      expect(a.contentHash, b.contentHash);
      expect(
          a.steps.map((s) => s.practiceId), b.steps.map((s) => s.practiceId));
    });

    test('Free and Premium produce identical core plan', () {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 30,
          'full_mood': 55,
          'full_habits': 60,
          'full_intention': 70,
        },
        overall: 54,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.strong,
      );
      final free = RecoveryPlanEngineV1.generate(pack, isPremium: false);
      final premium = RecoveryPlanEngineV1.generate(pack, isPremium: true);
      expect(free.contentHash, premium.contentHash);
      expect(free.intensity, premium.intensity);
      expect(
        free.priority.priorities.map((p) => p.domainId),
        premium.priority.priorities.map((p) => p.domainId),
      );
    });

    test('no medical wording in because / explanation', () {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 25,
          'full_mood': 50,
          'full_habits': 55,
          'full_intention': 60,
        },
        overall: 48,
        band: RecoveryScoreBand.buildingRhythm,
        confidence: MeasurementConfidence.moderate,
      );
      final plan = RecoveryPlanEngineV1.generate(pack);
      final blob = '${plan.todayBecause.textEn} ${plan.todayBecause.textAr} '
          '${plan.explanation.whyFitsEn} ${plan.explanation.nonMedicalBoundaryEn}';
      for (final bad in [
        'diagnosis',
        'cure you',
        'ADHD',
        'AI recommends',
        'severe',
        'clinical',
      ]) {
        expect(blob.toLowerCase().contains(bad.toLowerCase()), isFalse);
      }
      expect(plan.explanation.nonMedicalBoundaryEn, contains('not medical'));
    });
  });

  group('priority selection', () {
    test('up to 2 priorities, lowest first', () {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 20,
          'full_mood': 25,
          'full_habits': 80,
          'full_intention': 90,
        },
        overall: 54,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.strong,
      );
      final pri = PrioritySelector.select(pack);
      expect(pri.priorities.length, 2);
      expect(pri.priorities[0].domainId, 'full_attention');
      expect(pri.priorities[1].domainId, 'full_mood');
      expect(pri.strongerDomainId, 'full_intention');
    });

    test('all-close ≤5 → one priority', () {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 50,
          'full_mood': 52,
          'full_habits': 53,
          'full_intention': 54,
        },
        overall: 52,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.strong,
      );
      final pri = PrioritySelector.select(pack);
      expect(pri.priorities.length, 1);
    });

    test('canonical tie-break when equal scores', () {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 40,
          'full_mood': 40,
          'full_habits': 40,
          'full_intention': 80,
        },
        overall: 50,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.strong,
      );
      final pri = PrioritySelector.select(pack);
      expect(pri.priorities.length, lessThanOrEqualTo(2));
      expect(pri.priorities.first.domainId, 'full_attention');
    });

    test('unavailable domain excluded', () {
      final domains = <BrainProfileDomainResult>[
        const BrainProfileDomainResult(
          domainId: 'full_attention',
          titleEn: 'Attention',
          titleAr: 'انتباه',
          answeredCount: 0,
          expectedCount: 3,
          missingQuestionIds: ['full_q1'],
        ),
        const BrainProfileDomainResult(
          domainId: 'full_mood',
          titleEn: 'Mood',
          titleAr: 'مزاج',
          answeredCount: 3,
          expectedCount: 3,
          missingQuestionIds: [],
          normalizedMean: 40,
          displayScore: 40,
        ),
        const BrainProfileDomainResult(
          domainId: 'full_habits',
          titleEn: 'Habits',
          titleAr: 'عادات',
          answeredCount: 3,
          expectedCount: 3,
          missingQuestionIds: [],
          normalizedMean: 70,
          displayScore: 70,
        ),
        const BrainProfileDomainResult(
          domainId: 'full_intention',
          titleEn: 'Intention',
          titleAr: 'نية',
          answeredCount: 3,
          expectedCount: 3,
          missingQuestionIds: [],
          normalizedMean: 80,
          displayScore: 80,
        ),
      ];
      final pack = ProfilePack(
        id: 'p',
        source: const ProfileSourceReference(
          sessionId: 's',
          mode: BrainCheckMode.full,
          brainCheckSchemaVersion: 'brain_check_measurement_v1',
        ),
        createdAt: DateTime.utc(2026, 8, 2),
        lastRecalculatedAt: DateTime.utc(2026, 8, 2),
        domains: domains,
        recoveryScore: const RecoveryScore(
          modelVersion: 'recovery_score_v1',
          band: RecoveryScoreBand.findingSteadiness,
          value: 60,
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
      final pri = PrioritySelector.select(pack);
      expect(pri.priorities.map((p) => p.domainId),
          isNot(contains('full_attention')));
      expect(pri.priorities.first.domainId, 'full_mood');
    });
  });

  group('intensity', () {
    test('provisional → LIGHT', () {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 40,
          'full_mood': 50,
          'full_habits': 55,
          'full_intention': 60,
        },
        overall: 51,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.provisional,
      );
      final pri = PrioritySelector.select(pack);
      expect(
        IntensitySelector.select(
            pack: pack, priorityCount: pri.priorities.length),
        RecoveryPlanIntensity.light,
      );
    });

    test('gathering_footing → LIGHT', () {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 10,
          'full_mood': 20,
          'full_habits': 15,
          'full_intention': 18,
        },
        overall: 16,
        band: RecoveryScoreBand.gatheringFooting,
        confidence: MeasurementConfidence.strong,
      );
      expect(
        IntensitySelector.select(pack: pack, priorityCount: 2),
        RecoveryPlanIntensity.light,
      );
    });

    test('SUPPORTED when two priorities + strong + eligible band', () {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 20,
          'full_mood': 28,
          'full_habits': 80,
          'full_intention': 90,
        },
        overall: 55,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.strong,
      );
      final plan = RecoveryPlanEngineV1.generate(pack);
      expect(plan.priority.priorities.length, 2);
      expect(plan.intensity, RecoveryPlanIntensity.supported);
      expect(plan.steps.length, lessThanOrEqualTo(3));
      expect(plan.requiredSteps.length, 2);
    });

    test('low confidence omits optionals', () {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 20,
          'full_mood': 30,
          'full_habits': 80,
          'full_intention': 90,
        },
        overall: 20,
        band: RecoveryScoreBand.gatheringFooting,
        confidence: MeasurementConfidence.provisional,
      );
      final plan = RecoveryPlanEngineV1.generate(pack);
      expect(plan.intensity, RecoveryPlanIntensity.light);
      expect(plan.optionalSteps, isEmpty);
      expect(plan.requiredSteps.length, 1);
    });
  });

  group('because templates', () {
    test('priority / lowconf / strength / pulse / starter AR+EN', () {
      final priority = PlanBecauseTemplates.resolve(
        templateKey: PlanBecauseTemplates.priority,
        domainEn: 'Attention',
        domainAr: 'الانتباه',
      );
      expect(priority.textEn, contains('Attention'));
      expect(priority.textAr, contains('الانتباه'));

      final low = PlanBecauseTemplates.resolve(
        templateKey: PlanBecauseTemplates.priorityLowConf,
        domainEn: 'Mood',
        domainAr: 'المزاج',
      );
      expect(low.textEn.toLowerCase(), contains('early'));

      final strength = PlanBecauseTemplates.resolve(
        templateKey: PlanBecauseTemplates.withStrength,
        domainEn: 'Attention',
        domainAr: 'الانتباه',
        strengthEn: 'Intention',
        strengthAr: 'النية',
      );
      expect(strength.textEn, contains('Intention'));

      final pulse = PlanBecauseTemplates.resolve(
        templateKey: PlanBecauseTemplates.pulse,
      );
      expect(pulse.textEn, isNotEmpty);
      expect(pulse.textAr, isNotEmpty);

      final starter = PlanBecauseTemplates.resolve(
        templateKey: PlanBecauseTemplates.starter,
      );
      expect(starter.textEn.toLowerCase(), contains('starter'));
    });
  });

  group('persistence', () {
    test('idempotent save + history immutability + retrieval', () async {
      final box = await Hive.openBox<dynamic>('recovery_plan_test');
      final repo = RecoveryPlanLocalRepository(box: box);
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 30,
          'full_mood': 55,
          'full_habits': 60,
          'full_intention': 70,
        },
        overall: 54,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.strong,
        id: 'pack_a',
      );
      final plan = RecoveryPlanEngineV1.generate(
        pack,
        createdAt: DateTime.utc(2026, 8, 2),
      );
      final saved1 = await repo.saveIfNew(plan);
      final saved2 = await repo.saveIfNew(plan);
      expect(saved1.id, saved2.id);
      expect((await repo.history()).length, 1);

      final pack2 = syntheticFull(
        domainScores: {
          'full_attention': 10,
          'full_mood': 20,
          'full_habits': 30,
          'full_intention': 40,
        },
        overall: 25,
        band: RecoveryScoreBand.buildingRhythm,
        confidence: MeasurementConfidence.moderate,
        id: 'pack_b',
        sessionId: 'sess_b',
      );
      final plan2 = RecoveryPlanEngineV1.generate(
        pack2,
        createdAt: DateTime.utc(2026, 8, 3),
      );
      await repo.saveIfNew(plan2);
      final hist = await repo.history();
      expect(hist.length, 2);
      expect(hist.first.id, saved1.id);
      expect((await repo.active())!.id, plan2.id);
      expect((await repo.findByProfilePackId('pack_a'))!.id, saved1.id);

      // Corrupt record skipped
      await box.put(RecoveryPlanLocalRepository.historyKey, [
        'corrupt',
        {'not': 'a plan'},
        RecoveryPlanPack(
          plan: plan2,
          schemaVersion: RecoveryPlanVersions.schema,
        ).toJson(),
      ]);
      final recovered = await repo.history();
      expect(recovered.length, 1);
      expect(recovered.first.id, plan2.id);

      expect(HiveBoxes.recoveryPlan, 'recovery_plan_v1');
      expect(HiveBoxes.diagnosticPersistence, isNot(HiveBoxes.recoveryPlan));
      await box.close();
    });
  });

  group('UI + boundary', () {
    testWidgets('PLN-00 missing profile state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: PlanBuildingBody(
            loc: await AppLocalizations.delegate.load(const Locale('en')),
            loading: false,
            errorKey: 'missing_profile',
            plan: null,
            onRetry: () {},
            onStartBrainCheck: () {},
            onGoHome: () {},
          ),
        ),
      );
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(loc.recoveryPlanMissingProfile), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, loc.v2BrainCheckEntryStart),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(FilledButton, loc.recoveryPlanRetry),
        findsNothing,
      );
      expect(find.text(loc.recoveryPlanGoHome), findsOneWidget);
    });

    testWidgets('PLN-00 missing_profile Start Brain Check does not Retry-loop',
        (tester) async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      var retries = 0;
      var checks = 0;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: PlanBuildingBody(
            loc: loc,
            loading: false,
            errorKey: 'missing_profile',
            plan: null,
            onRetry: () => retries++,
            onStartBrainCheck: () => checks++,
            onGoHome: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('v2_plan_building_primary_cta')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('v2_plan_building_primary_cta')));
      await tester.pump();
      expect(checks, 2);
      expect(retries, 0);
      expect(find.text(loc.recoveryPlanRetry), findsNothing);
    });

    testWidgets('PLN-01 ready shows because without internal ids',
        (tester) async {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 30,
          'full_mood': 55,
          'full_habits': 60,
          'full_intention': 70,
        },
        overall: 54,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.strong,
      );
      final plan = RecoveryPlanEngineV1.generate(pack);
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: PlanRevealBody(
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
        ),
      );
      expect(find.textContaining(plan.todayBecause.textEn), findsWidgets);
      expect(find.textContaining('prac_'), findsNothing);
      expect(find.textContaining('rplan_'), findsNothing);
      expect(find.textContaining('hypothesis'), findsNothing);
    });

    testWidgets('320px + textScale 2.0', (tester) async {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 30,
          'full_mood': 55,
          'full_habits': 60,
          'full_intention': 70,
        },
        overall: 54,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.strong,
      );
      final plan = RecoveryPlanEngineV1.generate(pack);
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(2.0),
          ),
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: PlanRevealBody(
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
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('RTL Arabic loads', (tester) async {
      final loc = await AppLocalizations.delegate.load(const Locale('ar'));
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: PlanBuildingBody(
            loc: loc,
            loading: true,
            errorKey: null,
            plan: null,
            onRetry: () {},
            onStartBrainCheck: () {},
            onGoHome: () {},
          ),
        ),
      );
      expect(find.text(loc.recoveryPlanBuilding), findsOneWidget);
    });

    testWidgets('shell Plan thesis early, paths collapsed, soft Open Today',
        (tester) async {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 30,
          'full_mood': 55,
          'full_habits': 60,
          'full_intention': 70,
        },
        overall: 54,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.strong,
      );
      final plan = RecoveryPlanEngineV1.generate(pack);
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      var continued = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: PlanRevealBody(
              loc: loc,
              languageCode: 'en',
              loading: false,
              missing: false,
              plan: plan,
              presentation: PlanRevealPresentation.shellOrientation,
              onGoHome: () {},
              onContinue: () => continued = true,
              onRebuild: () {},
            ),
          ),
        ),
      );
      expect(find.text(loc.recoveryPlanMainFocus), findsOneWidget);
      expect(find.text(loc.recoveryPlanPrioritiesHeading), findsOneWidget);
      expect(find.text(loc.recoveryPlanTimeHeading), findsOneWidget);
      expect(find.text(loc.recoveryPlanTodayFitHeading), findsOneWidget);
      expect(find.text(loc.recoveryPlanPathDetails), findsOneWidget);
      expect(find.text(loc.recoveryPlanAboutDetails), findsOneWidget);
      // Full path dumps / a11y alts are not expanded in the first viewport.
      expect(find.text(loc.recoveryPlanSkipHint), findsNothing);
      expect(
        find.widgetWithText(FilledButton, loc.recoveryPlanContinueToday),
        findsNothing,
      );
      expect(
        find.widgetWithText(OutlinedButton, loc.recoveryPlanOpenToday),
        findsOneWidget,
      );
      expect(
        find.text(plan.explanation.mainFocusForLocale('en')),
        findsWidgets,
      );
      await tester.ensureVisible(find.text(loc.recoveryPlanOpenToday));
      await tester.pumpAndSettle();
      await tester.tap(find.text(loc.recoveryPlanOpenToday));
      expect(continued, isTrue);
      // No session execution controls.
      expect(find.text(loc.v2TodayHomeCtaStart), findsNothing);
      expect(find.text(loc.v2TodayHomeCtaContinue), findsNothing);
    });

    testWidgets('shell Plan Arabic RTL + 320 width scrolls', (tester) async {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 30,
          'full_mood': 55,
          'full_habits': 60,
          'full_intention': 70,
        },
        overall: 54,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.strong,
      );
      final plan = RecoveryPlanEngineV1.generate(pack);
      final loc = await AppLocalizations.delegate.load(const Locale('ar'));
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(320, 640)),
          child: MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: PlanRevealBody(
                loc: loc,
                languageCode: 'ar',
                loading: false,
                missing: false,
                plan: plan,
                presentation: PlanRevealPresentation.shellOrientation,
                onGoHome: () {},
                onContinue: () {},
                onRebuild: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text(loc.recoveryPlanTodayFitHeading), findsOneWidget);
      final ctx = tester.element(find.text(loc.recoveryPlanTodayFitHeading));
      expect(Directionality.of(ctx), TextDirection.rtl);
    });

    testWidgets('shell Plan tolerates larger text scale at 320',
        (tester) async {
      final pack = syntheticFull(
        domainScores: {
          'full_attention': 30,
          'full_mood': 55,
          'full_habits': 60,
          'full_intention': 70,
        },
        overall: 54,
        band: RecoveryScoreBand.findingSteadiness,
        confidence: MeasurementConfidence.strong,
      );
      final plan = RecoveryPlanEngineV1.generate(pack);
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(1.3),
          ),
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: PlanRevealBody(
                loc: loc,
                languageCode: 'en',
                loading: false,
                missing: false,
                plan: plan,
                presentation: PlanRevealPresentation.shellOrientation,
                onGoHome: () {},
                onContinue: () {},
                onRebuild: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(loc.recoveryPlanMainFocus), findsOneWidget);
      expect(find.text(loc.recoveryPlanOpenToday), findsOneWidget);
    });

    testWidgets('shell empty Plan offers Build without session CTAs',
        (tester) async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      var rebuild = false;
      var home = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: PlanRevealBody(
              loc: loc,
              languageCode: 'en',
              loading: false,
              missing: true,
              plan: null,
              presentation: PlanRevealPresentation.shellOrientation,
              onGoHome: () => home = true,
              onContinue: () {},
              onRebuild: () => rebuild = true,
            ),
          ),
        ),
      );
      expect(find.text(loc.recoveryPlanMissing), findsOneWidget);
      expect(find.text(loc.recoveryPlanBuildCta), findsOneWidget);
      await tester.tap(find.text(loc.recoveryPlanBuildCta));
      expect(rebuild, isTrue);
      await tester.tap(find.text(loc.recoveryPlanGoHome));
      expect(home, isTrue);
      expect(find.text(loc.v2TodayHomeCtaStart), findsNothing);
    });

    test('shell empty go-home target is V2 Today not legacy /home', () {
      expect(AppRoutes.v2Home, '/v2/home');
      expect(AppRoutes.home, isNot(AppRoutes.v2Home));
    });

    test('feature boundary keeps V1 default', () {
      expect(V2FeatureBoundary.enableBrainProfileRoutes, isFalse);
      expect(V2FeatureBoundary.enableRecoveryPlanRoutes, isFalse);
      expect(AppRoutes.v2PlanBuilding, '/v2/plan/building');
      expect(AppRoutes.v2PlanReveal, '/v2/plan');
    });

    test('domain mapping attention → single_task primary', () {
      expect(
        RecoveryPracticeCatalog.primaryForDomain('full_attention').first,
        'prac_single_task',
      );
      expect(
        RecoveryPracticeCatalog.primaryForDomain('full_habits').first,
        'prac_body_move',
      );
    });
  });
}
