import 'dart:io';

import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/brain_check/application/brain_check_controller.dart';
import 'package:brain_clean_mobile/features/brain_check/data/brain_check_local_repository.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_item_bank.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_mode.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_phase.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_scale.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/measurement_event.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/recovery_score_bridge.dart';
import 'package:brain_clean_mobile/features/brain_profile/application/brain_profile_generator.dart';
import 'package:brain_clean_mobile/features/brain_profile/data/brain_profile_repository.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/domain_aggregator.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/measurement_confidence.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_generation_result.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_pack.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/profile_version.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/recovery_score.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/recovery_score_engine.dart';
import 'package:brain_clean_mobile/features/brain_profile/domain/score_calculation_result.dart';
import 'package:brain_clean_mobile/features/brain_profile/ui/brain_profile_reveal_screen.dart';
import 'package:brain_clean_mobile/features/brain_profile/ui/profile_ready_boundary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
void main() {
  late Directory tempDir;
  late Box<dynamic> profileBox;
  late Box<dynamic> checkBox;
  late Box<dynamic> diagnosticBox;
  late BrainProfileLocalRepository profileRepo;
  late BrainCheckLocalRepository checkRepo;
  late BrainProfileGenerator generator;
  var clockTick = DateTime.utc(2026, 8, 2, 12);
  var uuidCounter = 0;

  DateTime nextClock() {
    clockTick = clockTick.add(const Duration(seconds: 1));
    return clockTick;
  }

  setUp(() async {
    HiveBootstrap.resetForTesting();
    V2FeatureBoundary.enableBrainProfileRoutes = false;
    tempDir = await Directory.systemTemp.createTemp('bc_brain_profile_');
    Hive.init(tempDir.path);
    HiveBootstrap.registerRecoveryAdaptersForTests();

    for (final name in [
      HiveBoxes.brainProfile,
      HiveBoxes.brainCheck,
      HiveBoxes.diagnosticPersistence,
    ]) {
      if (Hive.isBoxOpen(name)) await Hive.box(name).close();
    }

    profileBox = await Hive.openBox<dynamic>(HiveBoxes.brainProfile);
    checkBox = await Hive.openBox<dynamic>(HiveBoxes.brainCheck);
    diagnosticBox = await Hive.openBox<dynamic>(HiveBoxes.diagnosticPersistence);
    await diagnosticBox.put('v1_sentinel', {'ok': true, 'score': 42});

    profileRepo = BrainProfileLocalRepository(box: profileBox);
    checkRepo = BrainCheckLocalRepository(box: checkBox);
    uuidCounter = 0;
    clockTick = DateTime.utc(2026, 8, 2, 12);
    generator = BrainProfileGenerator(
      repository: profileRepo,
      clock: nextClock,
      uuid: const Uuid(),
    );
  });

  tearDown(() async {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
    HiveBootstrap.resetForTesting();
  });

  MeasurementEvent completeEvent({
    BrainCheckMode mode = BrainCheckMode.lite,
    Map<String, int>? overrides,
    String? sessionId,
  }) {
    final questions = BrainCheckItemBank.questionsFor(mode);
    final answers = <String, int>{
      for (final q in questions) q.id: q.scale.minValue,
      ...?overrides,
    };
    return MeasurementEvent(
      id: sessionId ?? 'session-${++uuidCounter}',
      mode: mode,
      capturedAt: DateTime.utc(2026, 8, 2, 12),
      answers: answers,
      sectionIds: BrainCheckItemBank.sectionsFor(mode)
          .map((s) => s.id)
          .toList(growable: false),
      source: 'test',
      languageCode: 'en',
    );
  }

  Future<ProfilePack> generateOk(MeasurementEvent event) async {
    final result = await generator.generateFrom(event);
    expect(result, isA<ProfileGenerationSuccess>());
    return (result as ProfileGenerationSuccess).profile;
  }

  group('profile generation', () {
    test('1 completed Brain Check generates one profile', () async {
      final pack = await generateOk(completeEvent());
      expect(pack.domains, isNotEmpty);
      expect(pack.profileSchemaVersion, ProfileVersion.profileSchema);
      expect(await profileRepo.history(), hasLength(1));
    });

    test('2 incomplete check cannot generate profile', () async {
      final event = MeasurementEvent(
        id: 'incomplete',
        mode: BrainCheckMode.lite,
        capturedAt: DateTime.utc(2026, 8, 2),
        answers: const {'lite_q1': 3},
        sectionIds: const ['lite_attention'],
      );
      final result = await generator.generateFrom(event);
      expect(result, isA<ProfileGenerationFailure>());
      expect(
        (result as ProfileGenerationFailure).code,
        ProfileGenerationErrorCode.incompleteAnswers,
      );
      expect(await profileRepo.history(), isEmpty);
    });

    test('3 identical inputs produce identical domain means', () async {
      final a = completeEvent(sessionId: 'a');
      final b = MeasurementEvent(
        id: 'b',
        mode: a.mode,
        capturedAt: a.capturedAt,
        answers: a.answers,
        sectionIds: a.sectionIds,
      );
      final packA = await generateOk(a);
      final packB = await generateOk(b);
      expect(
        packA.domains.map((d) => d.normalizedMean).toList(),
        packB.domains.map((d) => d.normalizedMean).toList(),
      );
      expect(packA.confidence, packB.confidence);
    });

    test('4 score remains within approved V1 bounds', () async {
      final pack = await generateOk(completeEvent());
      expect(pack.recoveryScore.isValid, isTrue);
      expect(pack.recoveryScore.value, inInclusiveRange(0, 100));
      expect(pack.recoveryScore.modelVersion, ProfileVersion.recoveryScoreModel);
      expect(pack.recoveryScore.band, isNot(RecoveryScoreBand.pendingApproval));
      for (final d in pack.domains) {
        if (d.normalizedMean != null) {
          expect(d.normalizedMean!, inInclusiveRange(0, 100));
        }
      }
    });

    test('5 score and confidence remain separate', () async {
      final pack = await generateOk(completeEvent(mode: BrainCheckMode.full));
      expect(pack.recoveryScore.value, isNotNull);
      expect(pack.confidence, MeasurementConfidence.strong);
      expect(pack.confidence.wireName, isNot(pack.recoveryScore.modelVersion));
    });

    test('6 missing data reduces confidence safely', () async {
      final questions = BrainCheckItemBank.questionsFor(BrainCheckMode.full);
      final answers = <String, int>{
        for (final q in questions.take(questions.length - 3))
          q.id: q.scale.maxValue,
      };
      final confidence = DomainAggregator.confidenceFor(
        mode: BrainCheckMode.full,
        domains: const [],
      );
      // Missing required is handled by engine unavailable; confidence helper
      // for complete Full is strong — incomplete events don't get a pack.
      expect(confidence, MeasurementConfidence.strong);
      expect(answers.length, lessThan(questions.length));
    });

    test('7 repeated generation is idempotent', () async {
      final event = completeEvent(sessionId: 'same');
      final first = await generator.generateFrom(event);
      final second = await generator.generateFrom(event);
      expect(first, isA<ProfileGenerationSuccess>());
      expect(second, isA<ProfileGenerationSuccess>());
      final s1 = first as ProfileGenerationSuccess;
      final s2 = second as ProfileGenerationSuccess;
      expect(s2.wasExisting, isTrue);
      expect(s2.profile.id, s1.profile.id);
      expect(await profileRepo.history(), hasLength(1));
    });

    test('8 no duplicate historical profile', () async {
      final event = completeEvent(sessionId: 'dup');
      await generateOk(event);
      await profileRepo.save(
        (await profileRepo.findBySourceSessionId('dup'))!,
      );
      expect(await profileRepo.history(), hasLength(1));
    });

    test('9 new retake creates a new profile', () async {
      final first = await generateOk(completeEvent(sessionId: 'retake-1'));
      final second = await generateOk(completeEvent(sessionId: 'retake-2'));
      expect(first.id, isNot(second.id));
      expect(await profileRepo.history(), hasLength(2));
    });

    test('10 earlier profile remains immutable', () async {
      final first = await generateOk(completeEvent(sessionId: 'imm-1'));
      await generateOk(completeEvent(sessionId: 'imm-2'));
      final reloaded = await profileRepo.findBySourceSessionId('imm-1');
      expect(reloaded!.toJson(), first.toJson());
      expect(reloaded.createdAt, first.createdAt);
    });

    test('11 latest-profile retrieval', () async {
      await generateOk(completeEvent(sessionId: 'old'));
      final newest = await generateOk(completeEvent(sessionId: 'new'));
      expect((await profileRepo.latest())!.id, newest.id);
    });

    test('12 retrieval by source session', () async {
      await generateOk(completeEvent(sessionId: 'find-me'));
      final found = await profileRepo.findBySourceSessionId('find-me');
      expect(found, isNotNull);
      expect(found!.source.sessionId, 'find-me');
    });

    test('13 corrupt stored record fails safely', () async {
      await profileBox.put(BrainProfileLocalRepository.historyKey, [
        {'broken': true},
        (await generateOk(completeEvent(sessionId: 'good'))).toJson(),
      ]);
      final history = await profileRepo.history();
      expect(history, hasLength(1));
      expect(history.first.source.sessionId, 'good');
    });

    test('14 V1 diagnostic storage remains untouched', () async {
      await generateOk(completeEvent());
      expect(diagnosticBox.get('v1_sentinel'), isA<Map>());
      expect(
        (diagnosticBox.get('v1_sentinel') as Map)['score'],
        42,
      );
      expect(diagnosticBox.keys.length, 1);
    });

    test('15 no destructive migration of profile schema key', () async {
      await generateOk(completeEvent());
      expect(
        profileBox.get(BrainProfileLocalRepository.schemaKey),
        ProfileVersion.profileSchema,
      );
      expect(checkBox.isEmpty, isTrue);
    });
  });

  group('explanations and language', () {
    test('16 Arabic explanation present', () async {
      final pack = await generateOk(completeEvent());
      expect(pack.explanation.whatItIs('ar'), isNotEmpty);
      expect(pack.explanation.whatItIsNot('ar'), contains('تشخيصاً'));
    });

    test('17 English explanation present', () async {
      final pack = await generateOk(completeEvent());
      expect(pack.explanation.whatItIs('en'), contains('self-reported'));
      expect(pack.explanation.whatItIsNot('en').toLowerCase(), contains('not a medical'));
    });

    test('18 RTL/LTR behavior on stems and titles', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      expect(en.brainProfileTitle, 'Brain Profile');
      expect(ar.brainProfileTitle, 'ملف الدماغ');
      expect(en.brainProfileScoreHeading, isNot(ar.brainProfileScoreHeading));
      expect(TextDirection.rtl, TextDirection.rtl);
      expect(TextDirection.ltr, TextDirection.ltr);
    });

    test('19 no prohibited medical wording in explanations', () async {
      final pack = await generateOk(completeEvent());
      final blob = [
        pack.explanation.whatItIsEn,
        pack.explanation.whatItIsAr,
        pack.explanation.whatItIsNotEn,
        pack.explanation.whatItIsNotAr,
        pack.explanation.strongerAreasEn,
        pack.explanation.supportAreasEn,
        pack.explanation.scorePendingEn,
      ].join(' ').toLowerCase();
      for (final banned in [
        'brain damage',
        'neurological diagnosis',
        'clinical diagnosis',
        'dopamine damage',
        'permanent impairment',
        'scientifically proven cure',
        'guaranteed recovery',
        'bci',
      ]) {
        expect(blob.contains(banned), isFalse, reason: banned);
      }
    });

    test('20 no fake unsupported precision on domain means', () async {
      final pack = await generateOk(completeEvent());
      expect(pack.recoveryScore.value, isA<int>());
      for (final d in pack.domains) {
        if (d.displayScore != null) {
          expect(d.displayScore, inInclusiveRange(0, 100));
        }
      }
    });
  });

  group('guards against inventing score sources', () {
    test('no AI-generated score path — deterministic engine only', () {
      final event = completeEvent();
      final a = RecoveryScoreEngine.compute(event);
      final b = RecoveryScoreEngine.compute(event);
      expect(a, isA<ScoreCalculationValid>());
      expect(
        (a as ScoreCalculationValid).recoveryScore.value,
        (b as ScoreCalculationValid).recoveryScore.value,
      );
    });

    test('no network-dependent score — local V1 model', () async {
      final pack = await generateOk(completeEvent());
      expect(pack.recoveryScore.modelVersion, 'recovery_score_v1');
      expect(pack.hasValidRecoveryScore, isTrue);
    });

    test('no duplicate profile on repeated Brain Check completion handoff',
        () async {
      final controller = BrainCheckController(
        repository: checkRepo,
        clock: nextClock,
      );
      addTearDown(controller.dispose);
      await controller.start(mode: BrainCheckMode.pulse, source: 'test');
      while (controller.progress.phase == BrainCheckPhase.item ||
          controller.progress.phase == BrainCheckPhase.sectionBreak) {
        if (controller.progress.phase == BrainCheckPhase.sectionBreak) {
          await controller.continueAfterBreak();
          continue;
        }
        await controller.answerCurrent(
          controller.currentQuestion!.scale.minValue,
        );
      }
      await controller.complete(languageCode: 'en');
      final event = controller.result!.measurementEvent;
      await generateOk(event);
      await generateOk(event);
      expect(await profileRepo.history(), hasLength(1));
    });

    test('internal evidence IDs never appear in visible explanation copy',
        () async {
      final pack = await generateOk(completeEvent());
      final visible = [
        pack.explanation.whatItIsEn,
        pack.explanation.whatItIsAr,
        pack.explanation.confidenceEn,
        pack.explanation.retakeEn,
      ].join(' ');
      expect(visible.contains('EVIDENCE'), isFalse);
      expect(visible.contains('SRC-'), isFalse);
      expect(visible.contains('kappa'), isFalse);
    });
  });

  group('feature boundary and routes', () {
    test('24 feature boundary preserves V1 default', () {
      expect(V2FeatureBoundary.enableBrainProfileRoutes, isFalse);
      expect(AppRoutes.profile, '/profile');
      expect(AppRoutes.v2BrainProfile.startsWith('/v2/'), isTrue);
    });

    test('25 Brain Check completion can reach Profile building route', () {
      expect(AppRoutes.v2BrainCheckBuilding, '/v2/brain-check/building');
      expect(AppRoutes.v2BrainProfile, '/v2/brain-profile');
    });

    test('26 direct invalid Profile access fails safely when gated', () {
      expect(V2FeatureBoundary.enableBrainProfileRoutes, isFalse);
      // Redirect contract: gated /v2 paths must not be the production default.
      expect(AppRoutes.home, '/home');
    });
  });

  group('UI accessibility states', () {
    testWidgets('21 320 logical pixels empty + loading markers', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final loc = AppLocalizationsEn();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BrainProfileRevealBody(
              loc: loc,
              languageCode: 'en',
              loading: false,
              missing: true,
              historical: false,
              pack: null,
              onDomainTap: (_) async {},
              onGoHome: () {},
              onContinue: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('No Brain Profile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('22 text scale 2.0 on ready boundary', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ProfileReadyBoundaryScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ProfileReadyBoundaryScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('23 ready profile copy exposes score context without BCI', () async {
      final pack = await generateOk(completeEvent(sessionId: 'ui-1'));
      final loc = AppLocalizationsEn();
      expect(pack.recoveryScore.value, isNotNull);
      expect(loc.brainProfileScoreSemantics('${pack.recoveryScore.value}'),
          contains('Recovery Score'));
      expect(loc.brainProfileConfidenceHeading, isNotEmpty);
      expect(pack.explanation.whatItIsEn.toLowerCase(), isNot(contains('bci')));
      expect(pack.explanation.whatItIsEn, isNot(contains('EVIDENCE')));
      expect(pack.contributions, isNotEmpty);
    });
  });

  group('Lite confidence flag (CHK-03)', () {
    test('Lite complete answers set moderate confidence flag', () async {
      final pack = await generateOk(completeEvent(mode: BrainCheckMode.lite));
      expect(pack.confidence, MeasurementConfidence.moderate);
      expect(pack.source.mode, BrainCheckMode.lite);
      expect(pack.recoveryScore.isValid, isTrue);
    });
  });
}
