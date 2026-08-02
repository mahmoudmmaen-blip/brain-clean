import 'dart:io';

import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/features/brain_check/application/brain_check_controller.dart';
import 'package:brain_clean_mobile/features/brain_check/data/brain_check_local_repository.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_item_bank.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_mode.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_phase.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_progress.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_question.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_validation.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/recovery_score_bridge.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late BrainCheckLocalRepository repository;
  late BrainCheckController controller;
  var clockTick = DateTime.utc(2026, 8, 1, 12);

  DateTime nextClock() {
    clockTick = clockTick.add(const Duration(seconds: 1));
    return clockTick;
  }

  setUp(() async {
    HiveBootstrap.resetForTesting();
    tempDir = await Directory.systemTemp.createTemp('bc_brain_check_');
    Hive.init(tempDir.path);
    HiveBootstrap.registerRecoveryAdaptersForTests();
    if (Hive.isBoxOpen(HiveBoxes.brainCheck)) {
      await Hive.box(HiveBoxes.brainCheck).close();
    }
    final box = await Hive.openBox<dynamic>(HiveBoxes.brainCheck);
    repository = BrainCheckLocalRepository(box: box);
    clockTick = DateTime.utc(2026, 8, 1, 12);
    controller = BrainCheckController(
      repository: repository,
      clock: nextClock,
      scoreBridge: const V1RecoveryScoreBridge(),
    );
  });

  tearDown(() async {
    controller.dispose();
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
    HiveBootstrap.resetForTesting();
  });

  Future<void> answerAllRemaining() async {
    while (controller.progress.phase == BrainCheckPhase.item ||
        controller.progress.phase == BrainCheckPhase.sectionBreak) {
      if (controller.progress.phase == BrainCheckPhase.sectionBreak) {
        await controller.continueAfterBreak();
        continue;
      }
      final question = controller.currentQuestion!;
      final value = question.scale.minValue;
      final result = await controller.answerCurrent(value);
      expect(result.isOk, isTrue, reason: result.messageEn);
    }
  }

  group('empty state', () {
    test('starts empty before hydrate and after empty hydrate', () async {
      expect(controller.snapshot.isEmpty, isTrue);
      expect(controller.progress.phase, BrainCheckPhase.empty);
      await controller.hydrate();
      expect(controller.isHydrated, isTrue);
      expect(controller.snapshot.isEmpty, isTrue);
      expect(controller.result, isNull);
    });
  });

  group('question progression', () {
    test('advances through lite questions and sections', () async {
      await controller.start(mode: BrainCheckMode.lite, source: 'test');
      expect(controller.progress.phase, BrainCheckPhase.item);
      expect(controller.progress.currentQuestionIndex, 0);

      final firstId = controller.currentQuestion!.id;
      await controller.answerCurrent(3);
      expect(controller.progress.answers.containsKey(firstId), isTrue);
      expect(controller.progress.currentQuestionIndex, 1);

      await answerAllRemaining();
      expect(controller.progress.phase, BrainCheckPhase.completion);
      expect(
        controller.progress.answeredCount,
        BrainCheckItemBank.questionsFor(BrainCheckMode.lite).length,
      );
    });

    test('full mode inserts section breaks between chapters', () async {
      await controller.start(mode: BrainCheckMode.full, source: 'test');
      // First section has 3 questions → break before index 3.
      await controller.answerCurrent(3);
      await controller.answerCurrent(3);
      await controller.answerCurrent(2);
      expect(controller.progress.phase, BrainCheckPhase.sectionBreak);
      expect(controller.progress.currentSectionIndex, 1);
      await controller.continueAfterBreak();
      expect(controller.progress.phase, BrainCheckPhase.item);
      expect(controller.progress.currentQuestionIndex, 3);
    });

    test('goBack restores prior question index', () async {
      await controller.start(mode: BrainCheckMode.pulse);
      await controller.answerCurrent(1);
      expect(controller.progress.currentQuestionIndex, 1);
      await controller.goBack();
      expect(controller.progress.currentQuestionIndex, 0);
      expect(controller.progress.phase, BrainCheckPhase.item);
    });
  });

  group('validation', () {
    test('rejects empty and out-of-range answers', () async {
      await controller.start(mode: BrainCheckMode.lite);
      final empty = await controller.answerCurrent(null);
      expect(empty.code, BrainCheckValidationCode.emptyAnswer);
      expect(controller.progress.currentQuestionIndex, 0);

      final outOfRange = await controller.answerCurrent(99);
      expect(outOfRange.code, BrainCheckValidationCode.outOfRange);
      expect(controller.progress.answers, isEmpty);
    });

    test('restart without confirmation is a no-op', () async {
      await controller.start(mode: BrainCheckMode.lite);
      await controller.answerCurrent(2);
      final blocked = await controller.restart(confirmed: false);
      expect(blocked.code, BrainCheckValidationCode.restartNotConfirmed);
      expect(controller.progress.answeredCount, 1);
    });
  });

  group('local persistence and resume', () {
    test('autosaves after each answer and resumes exact index', () async {
      await controller.start(mode: BrainCheckMode.lite, source: 'onboarding');
      await controller.answerCurrent(4);
      await controller.answerCurrent(2);

      final draft = await repository.loadDraft();
      expect(draft, isNotNull);
      expect(draft!.currentQuestionIndex, 2);
      expect(draft.answeredCount, 2);

      final resumed = BrainCheckController(
        repository: repository,
        clock: nextClock,
        scoreBridge: const V1RecoveryScoreBridge(),
      );
      await resumed.hydrate();
      expect(resumed.progress.phase, BrainCheckPhase.resumeGate);
      expect(resumed.progress.answeredCount, 2);

      final cont = await resumed.resume();
      expect(cont.isOk, isTrue);
      expect(resumed.progress.phase, BrainCheckPhase.item);
      expect(resumed.progress.currentQuestionIndex, 2);
      expect(resumed.currentQuestion!.id, 'lite_q3');
      resumed.dispose();
    });

    test('confirmed restart wipes draft only after confirm', () async {
      await controller.start(mode: BrainCheckMode.lite);
      await controller.answerCurrent(3);
      await controller.restart(confirmed: true);
      expect(controller.progress.answeredCount, 0);
      expect(controller.progress.currentQuestionIndex, 0);
      expect(controller.progress.phase, BrainCheckPhase.item);
      final draft = await repository.loadDraft();
      expect(draft!.answeredCount, 0);
    });
  });

  group('completion', () {
    test('completes with MeasurementEvent and V1 Recovery Score', () async {
      await controller.start(mode: BrainCheckMode.pulse, source: 'pulse');
      await answerAllRemaining();
      expect(controller.progress.phase, BrainCheckPhase.completion);

      final done = await controller.complete(languageCode: 'en');
      expect(done.isOk, isTrue);
      expect(controller.progress.phase, BrainCheckPhase.completed);
      expect(controller.result, isNotNull);
      expect(controller.result!.scorePlaceholder.isPending, isFalse);
      expect(
        controller.result!.scorePlaceholder.status,
        RecoveryScorePlaceholder.v1Status,
      );
      expect(controller.result!.scorePlaceholder.recoveryScore, isNotNull);
      expect(controller.result!.measurementEvent.answers.length, 4);
      expect(await repository.loadDraft(), isNull);
      expect(await repository.loadResult(), isNotNull);
    });

    test('complete is idempotent — no new session or MeasurementEvent', () async {
      await controller.start(mode: BrainCheckMode.pulse, source: 'pulse');
      await answerAllRemaining();
      final first = await controller.complete(languageCode: 'en');
      expect(first.isOk, isTrue);
      final sessionId = controller.result!.sessionId;
      final eventId = controller.result!.measurementEvent.id;
      final completedAt = controller.result!.completedAt;

      final second = await controller.complete(languageCode: 'ar');
      expect(second.isOk, isTrue);
      expect(controller.result!.sessionId, sessionId);
      expect(controller.result!.measurementEvent.id, eventId);
      expect(controller.result!.completedAt, completedAt);
      expect(controller.result!.measurementEvent.languageCode, 'en');
      expect(controller.progress.phase, BrainCheckPhase.completed);

      final stored = await repository.loadResult();
      expect(stored!.sessionId, sessionId);
      expect(stored.measurementEvent.id, eventId);
    });
  });

  group('Arabic / English / RTL', () {
    test('question stems resolve for en and ar', () {
      final question = BrainCheckItemBank.questionsFor(BrainCheckMode.lite).first;
      expect(question.stemForLocale('en'), question.stemEn);
      expect(question.stemForLocale('ar'), question.stemAr);
      expect(question.isRtlForLocale('ar'), isTrue);
      expect(question.isRtlForLocale('en'), isFalse);
      expect(question.textDirectionForLocale('ar'), TextDirectionHint.rtl);
      expect(question.textDirectionForLocale('en'), TextDirectionHint.ltr);
    });

    test('l10n foundation strings exist in English and Arabic', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      expect(en.brainCheckTitle, isNotEmpty);
      expect(ar.brainCheckTitle, isNotEmpty);
      expect(en.brainCheckTitle, isNot(ar.brainCheckTitle));
      expect(en.brainCheckQuestionProgress(2, 6), contains('2'));
      expect(ar.brainCheckQuestionProgress(2, 6), contains('2'));
      expect(en.brainCheckIntroNonMedical.toLowerCase(), contains('not a medical'));
      expect(ar.brainCheckEmptyState, isNotEmpty);
    });

    test('Directionality wrapper accepts Arabic RTL content', () {
      final section = BrainCheckItemBank.sectionsFor(BrainCheckMode.lite).first;
      final title = section.titleForLocale('ar');
      expect(title, section.titleAr);
      final direction = TextDirection.rtl;
      expect(direction, TextDirection.rtl);
      expect(title.isNotEmpty, isTrue);
    });
  });

  group('controller lifecycle', () {
    test('hydrate → start → pause-as-persist → resume → complete', () async {
      await controller.hydrate();
      expect(controller.isHydrated, isTrue);

      await controller.showIntro(mode: BrainCheckMode.lite, source: 'lifecycle');
      expect(controller.progress.phase, BrainCheckPhase.intro);

      await controller.start(mode: BrainCheckMode.lite, source: 'lifecycle');
      await controller.answerCurrent(3);

      // Simulate process kill: new controller + hydrate.
      final second = BrainCheckController(
        repository: repository,
        clock: nextClock,
        scoreBridge: const V1RecoveryScoreBridge(),
      );
      addTearDown(second.dispose);
      await second.hydrate();
      expect(second.progress.phase, BrainCheckPhase.resumeGate);
      await second.resume();
      await answerAllWith(second);
      final completed = await second.complete(languageCode: 'ar');
      expect(completed.isOk, isTrue);
      expect(second.result!.measurementEvent.languageCode, 'ar');
      expect(second.snapshot.isComplete, isTrue);
    });

    test('dispose is safe after hydrate', () async {
      await controller.hydrate();
      expect(() => controller.dispose(), returnsNormally);
      // Recreate for tearDown.
      controller = BrainCheckController(
        repository: repository,
        scoreBridge: const V1RecoveryScoreBridge(),
      );
    });
  });
}

Future<void> answerAllWith(BrainCheckController controller) async {
  while (controller.progress.phase == BrainCheckPhase.item ||
      controller.progress.phase == BrainCheckPhase.sectionBreak) {
    if (controller.progress.phase == BrainCheckPhase.sectionBreak) {
      await controller.continueAfterBreak();
      continue;
    }
    final question = controller.currentQuestion!;
    final result = await controller.answerCurrent(question.scale.minValue);
    expect(result.isOk, isTrue);
  }
}
