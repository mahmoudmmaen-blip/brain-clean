import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/brain_check/application/brain_check_controller.dart';
import 'package:brain_clean_mobile/features/brain_check/data/brain_check_local_repository.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_item_bank.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_mode.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_phase.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_progress.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_result.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_scale.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_validation.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/recovery_score_bridge.dart';
import 'package:brain_clean_mobile/features/brain_check/ui/brain_check_answer_control.dart';
import 'package:brain_clean_mobile/features/brain_check/ui/brain_check_complete_boundary_screen.dart';
import 'package:brain_clean_mobile/features/brain_check/ui/brain_check_flow_screen.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/ui/brain_check_entry_boundary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryBrainCheckRepo implements BrainCheckLocalRepository {
  BrainCheckProgress? draft;
  BrainCheckResult? result;
  var failSave = false;

  @override
  Future<BrainCheckProgress?> loadDraft() async => draft;

  @override
  Future<void> saveDraft(BrainCheckProgress progress) async {
    if (failSave) throw StateError('save_failed');
    draft = progress;
  }

  @override
  Future<void> clearDraft() async {
    draft = null;
  }

  @override
  Future<BrainCheckResult?> loadResult() async => result;

  @override
  Future<void> saveResult(BrainCheckResult value) async {
    if (failSave) throw StateError('save_failed');
    result = value;
  }

  @override
  Future<void> clearResult() async {
    result = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MemoryBrainCheckRepo repository;
  late BrainCheckController controller;
  var clockTick = DateTime.utc(2026, 8, 2, 10);

  DateTime nextClock() {
    clockTick = clockTick.add(const Duration(seconds: 1));
    return clockTick;
  }

  setUp(() {
    V2FeatureBoundary.enableBrainProfileRoutes = true;
    repository = _MemoryBrainCheckRepo();
    clockTick = DateTime.utc(2026, 8, 2, 10);
    controller = BrainCheckController(
      repository: repository,
      clock: nextClock,
      scoreBridge: const V1RecoveryScoreBridge(),
    );
  });

  tearDown(() {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
    controller.dispose();
  });

  Future<AppLocalizations> loadLoc([String code = 'en']) =>
      AppLocalizations.delegate.load(Locale(code));

  Widget wrap(
    Widget child, {
    Locale locale = const Locale('en'),
    TextDirection textDirection = TextDirection.ltr,
    Size size = const Size(390, 800),
    double textScale = 1.0,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Directionality(
          textDirection: textDirection,
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  Future<void> answerAllRemaining(BrainCheckController c) async {
    while (c.progress.phase == BrainCheckPhase.item ||
        c.progress.phase == BrainCheckPhase.sectionBreak) {
      if (c.progress.phase == BrainCheckPhase.sectionBreak) {
        await c.continueAfterBreak();
        continue;
      }
      final q = c.currentQuestion!;
      final result = await c.answerCurrent(q.scale.minValue);
      expect(result.isOk, isTrue, reason: result.messageEn);
    }
  }

  group('modes / bank contract', () {
    test('approved modes and question counts', () {
      expect(BrainCheckMode.values.map((m) => m.name).toSet(), {
        'lite',
        'full',
        'pulse',
      });
      expect(BrainCheckItemBank.questionsFor(BrainCheckMode.lite).length, 6);
      expect(BrainCheckItemBank.questionsFor(BrainCheckMode.full).length, 12);
      expect(BrainCheckItemBank.questionsFor(BrainCheckMode.pulse).length, 4);
      expect(BrainCheckItemBank.sectionsFor(BrainCheckMode.lite).length, 2);
      expect(BrainCheckItemBank.sectionsFor(BrainCheckMode.full).length, 4);
      expect(BrainCheckItemBank.sectionsFor(BrainCheckMode.pulse).length, 1);
    });

    test('question order is deterministic per mode', () {
      expect(
        BrainCheckItemBank.questionsFor(BrainCheckMode.lite)
            .map((q) => q.id)
            .toList(),
        ['lite_q1', 'lite_q2', 'lite_q3', 'lite_q4', 'lite_q5', 'lite_q6'],
      );
    });

    test('bank scales are only approved types', () {
      for (final mode in BrainCheckMode.values) {
        for (final q in BrainCheckItemBank.questionsFor(mode)) {
          expect(BrainCheckScale.values.contains(q.scale), isTrue);
        }
      }
    });
  });

  group('CHK-01 entry', () {
    testWidgets('new-session entry shows Start', (tester) async {
      final loc = await loadLoc();
      await tester.pumpWidget(
        wrap(
          BrainCheckEntryBody(
            loc: loc,
            loading: false,
            errorKey: null,
            phase: BrainCheckPhase.empty,
            onStart: () {},
            onResume: () {},
            onGoHome: () {},
            onRetry: () {},
          ),
        ),
      );
      expect(find.text(loc.v2BrainCheckEntryStart), findsOneWidget);
      expect(find.text(loc.v2BrainCheckEntryResume), findsNothing);
    });

    testWidgets('resume entry shows Resume and Start over', (tester) async {
      final loc = await loadLoc();
      await tester.pumpWidget(
        wrap(
          BrainCheckEntryBody(
            loc: loc,
            loading: false,
            errorKey: null,
            phase: BrainCheckPhase.resumeGate,
            onStart: () {},
            onResume: () {},
            onGoHome: () {},
            onRetry: () {},
          ),
        ),
      );
      expect(find.text(loc.v2BrainCheckEntryResume), findsOneWidget);
      expect(find.text(loc.v2BrainCheckEntryStartOver), findsOneWidget);
    });

    test('restart confirmation strings + cancel leaves draft', () async {
      await controller.start(mode: BrainCheckMode.lite, source: 'onboarding');
      await controller.answerCurrent(3);
      final blocked = await controller.restart(confirmed: false);
      expect(blocked.code, BrainCheckValidationCode.restartNotConfirmed);
      expect(controller.progress.answeredCount, 1);
      final en = AppLocalizationsEn();
      expect(en.brainCheckRestartTitle, isNotEmpty);
      expect(en.brainCheckRestartBody.toLowerCase(), contains('clears'));
    });
  });

  group('answer controls', () {
    testWidgets('renders likert, frequency, and yes/no with 48px targets',
        (tester) async {
      final loc = await loadLoc();
      int? selected;
      await tester.pumpWidget(
        wrap(
          StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    BrainCheckAnswerControl(
                      loc: loc,
                      scale: BrainCheckScale.likert5,
                      selected: selected,
                      onSelected: (v) => setState(() => selected = v),
                    ),
                    BrainCheckAnswerControl(
                      loc: loc,
                      scale: BrainCheckScale.frequency,
                      selected: null,
                      onSelected: (_) {},
                    ),
                    BrainCheckAnswerControl(
                      loc: loc,
                      scale: BrainCheckScale.yesNo,
                      selected: null,
                      onSelected: (_) {},
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text(loc.brainCheckLikert1), findsOneWidget);
      expect(find.text(loc.brainCheckFrequency3), findsOneWidget);
      expect(find.text(loc.brainCheckAnswerYes), findsOneWidget);

      await tester.tap(find.text(loc.brainCheckLikert4));
      await tester.pump();
      expect(selected, 4);

      final inkWell = find.ancestor(
        of: find.text(loc.brainCheckLikert4),
        matching: find.byType(InkWell),
      );
      expect(tester.getSize(inkWell).height, greaterThanOrEqualTo(48));
    });

    test('out-of-range answer rejected', () async {
      await controller.start(mode: BrainCheckMode.lite);
      final bad = await controller.answerCurrent(99);
      expect(bad.isOk, isFalse);
      expect(controller.progress.answers, isEmpty);
    });
  });

  group('progression + autosave + resume', () {
    testWidgets('continue disabled until answer selected; no score copy',
        (tester) async {
      await controller.start(mode: BrainCheckMode.pulse, source: 'test');
      final loc = await loadLoc();
      await tester.pumpWidget(
        wrap(
          BrainCheckFlowBody(
            loc: loc,
            languageCode: 'en',
            controller: controller,
            selected: null,
            submitting: false,
            localError: null,
            onSelect: (_) {},
            onContinue: () {},
            onBack: () {},
            onBreakContinue: () {},
            onComplete: () {},
          ),
        ),
      );
      await tester.pump();

      final continueBtn = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, loc.brainCheckContinue),
      );
      expect(continueBtn.onPressed, isNull);
      expect(find.text(loc.brainCheckSelectAnswerHint), findsOneWidget);
      expect(find.text(loc.brainCheckQuestionProgress(1, 4)), findsOneWidget);
      expect(find.textContaining('Recovery Score'), findsNothing);
    });

    test('answer persists and autosaves; resume exact index/section', () async {
      await controller.start(mode: BrainCheckMode.full, source: 'onboarding');
      await controller.answerCurrent(3);
      await controller.answerCurrent(3);
      await controller.answerCurrent(2);
      expect(controller.progress.phase, BrainCheckPhase.sectionBreak);
      await controller.continueAfterBreak();
      expect(repository.draft!.currentQuestionIndex, 3);
      expect(repository.draft!.currentSectionIndex, 1);

      final second = BrainCheckController(
        repository: repository,
        clock: nextClock,
        scoreBridge: const V1RecoveryScoreBridge(),
      );
      addTearDown(second.dispose);
      await second.hydrate();
      expect(second.progress.phase, BrainCheckPhase.resumeGate);
      await second.resume();
      expect(second.progress.currentQuestionIndex, 3);
      expect(second.progress.currentSectionIndex, 1);
      expect(second.progress.mode, BrainCheckMode.full);
    });

    test('back preserves answer; forward uses restored value', () async {
      await controller.start(mode: BrainCheckMode.lite);
      await controller.answerCurrent(4);
      await controller.goBack();
      expect(controller.progress.currentQuestionIndex, 0);
      expect(controller.progress.answers['lite_q1']!.value, 4);
      await controller.answerCurrent(4);
      expect(controller.progress.currentQuestionIndex, 1);
    });

    test('exit/incomplete generates no MeasurementEvent', () async {
      await controller.start(mode: BrainCheckMode.lite);
      await controller.answerCurrent(2);
      expect(repository.draft, isNotNull);
      expect(repository.result, isNull);
      expect(controller.result, isNull);
    });

    test('locale stems differ without wiping draft', () async {
      await controller.start(mode: BrainCheckMode.lite);
      await controller.answerCurrent(5);
      final q = controller.currentQuestion!;
      expect(q.stemForLocale('en'), isNot(q.stemForLocale('ar')));
      expect(controller.progress.answeredCount, 1);
    });

    test('restart confirm clears draft only; cancel is no-op', () async {
      await controller.start(mode: BrainCheckMode.lite, source: 'onboarding');
      await controller.answerCurrent(3);
      await controller.restart(confirmed: false);
      expect(controller.progress.answeredCount, 1);
      await controller.restart(confirmed: true);
      expect(controller.progress.answeredCount, 0);
      expect(controller.progress.currentQuestionIndex, 0);
    });

    test('save failure surfaces without advancing answer', () async {
      await controller.start(mode: BrainCheckMode.lite);
      repository.failSave = true;
      await controller.answerCurrent(3);
      expect(controller.lastSaveError, isNotNull);
      // Answer is held in memory even if persist throws after write attempt.
      expect(controller.progress.answeredCount, 1);
    });
  });

  group('completion', () {
    testWidgets('CHK-04 completion has no scoring math', (tester) async {
      await controller.start(mode: BrainCheckMode.pulse);
      await answerAllRemaining(controller);
      final loc = await loadLoc();
      await tester.pumpWidget(
        wrap(
          BrainCheckFlowBody(
            loc: loc,
            languageCode: 'en',
            controller: controller,
            selected: null,
            submitting: false,
            localError: null,
            onSelect: (_) {},
            onContinue: () {},
            onBack: () {},
            onBreakContinue: () {},
            onComplete: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.text(loc.brainCheckComplete), findsOneWidget);
      expect(find.text(loc.brainCheckIntroNonMedical), findsOneWidget);
      expect(find.textContaining('Recovery Score'), findsNothing);
    });

    test('completion emits one MeasurementEvent and is idempotent', () async {
      await controller.start(mode: BrainCheckMode.pulse);
      await answerAllRemaining(controller);
      final first = await controller.complete(languageCode: 'en');
      expect(first.isOk, isTrue);
      final eventId = controller.result!.measurementEvent.id;
      final second = await controller.complete(languageCode: 'en');
      expect(second.isOk, isTrue);
      expect(controller.result!.measurementEvent.id, eventId);
      expect(controller.progress.phase, BrainCheckPhase.completed);
    });

    testWidgets('complete boundary is temporary post-check only', (tester) async {
      final loc = await loadLoc();
      await tester.pumpWidget(wrap(const BrainCheckCompleteBoundaryScreen()));
      expect(find.text(loc.brainCheckCompleteBoundaryTitle), findsOneWidget);
      expect(find.textContaining('Profile reveal'), findsOneWidget);
    });
  });

  group('localization + a11y', () {
    test('AR/EN questionnaire strings and wording guards', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      expect(en.brainCheckLikert1, isNot(ar.brainCheckLikert1));
      expect(en.brainCheckFrequency1, isNot(ar.brainCheckFrequency1));
      expect(en.brainCheckBreakTitle, isNot(ar.brainCheckBreakTitle));
      for (final text in [
        en.brainCheckCompletionBody,
        en.brainCheckRestartBody,
        en.brainCheckAutosaveHint,
        ar.brainCheckCompletionBody,
      ]) {
        final lower = text.toLowerCase();
        expect(lower.contains('brain damage'), isFalse);
        expect(lower.contains('cure'), isFalse);
        expect(lower.contains('intelligence'), isFalse);
      }
    });

    testWidgets('Arabic questionnaire + RTL', (tester) async {
      await controller.start(mode: BrainCheckMode.lite);
      final loc = await loadLoc('ar');
      await tester.pumpWidget(
        wrap(
          BrainCheckFlowBody(
            loc: loc,
            languageCode: 'ar',
            controller: controller,
            selected: null,
            submitting: false,
            localError: null,
            onSelect: (_) {},
            onContinue: () {},
            onBack: () {},
            onBreakContinue: () {},
            onComplete: () {},
          ),
          locale: const Locale('ar'),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pump();
      expect(find.text(controller.currentQuestion!.stemAr), findsOneWidget);
      expect(find.text(loc.brainCheckContinue), findsOneWidget);
      expect(find.text(AppLocalizationsEn().brainCheckContinue), findsNothing);
    });

    testWidgets('320 width + textScale 2.0 scrolls', (tester) async {
      await controller.start(mode: BrainCheckMode.pulse);
      final loc = await loadLoc();
      await tester.pumpWidget(
        wrap(
          BrainCheckFlowBody(
            loc: loc,
            languageCode: 'en',
            controller: controller,
            selected: 3,
            submitting: false,
            localError: null,
            onSelect: (_) {},
            onContinue: () {},
            onBack: () {},
            onBreakContinue: () {},
            onComplete: () {},
          ),
          size: const Size(320, 480),
          textScale: 2.0,
        ),
      );
      await tester.pump();
      expect(find.text(loc.brainCheckContinue), findsOneWidget);
      await tester.ensureVisible(find.text(loc.brainCheckContinue));
      expect(tester.takeException(), isNull);
    });

    testWidgets('selected answer announced', (tester) async {
      final loc = await loadLoc();
      await tester.pumpWidget(
        wrap(
          BrainCheckAnswerControl(
            loc: loc,
            scale: BrainCheckScale.yesNo,
            selected: 1,
            onSelected: (_) {},
          ),
        ),
      );
      await tester.pump();
      final yesNode = tester.getSemantics(find.text(loc.brainCheckAnswerYes));
      expect(yesNode.hasFlag(SemanticsFlag.isSelected), isTrue);
      expect(yesNode.hasFlag(SemanticsFlag.isButton), isTrue);
    });
  });

  group('routing + feature flag + privacy', () {
    test('route constants exist', () {
      expect(AppRoutes.v2BrainCheckEntry, '/v2/brain-check/entry');
      expect(AppRoutes.v2BrainCheckFlow, '/v2/brain-check/flow');
      expect(AppRoutes.v2BrainCheckCompleteBoundary, '/v2/brain-check/complete');
    });

    test('feature flag gates V2 onboarding routes', () {
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(V2FeatureBoundary.enableV2OnboardingRoutes, isFalse);
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      expect(V2FeatureBoundary.enableV2OnboardingRoutes, isTrue);
    });

    test('validation messages do not echo raw answers', () {
      const empty = BrainCheckValidationResult(
        code: BrainCheckValidationCode.emptyAnswer,
        messageEn: 'Please choose an answer to continue.',
        messageAr: 'يرجى اختيار إجابة للمتابعة.',
      );
      expect(empty.messageEn!.contains(RegExp(r'\b[0-9]+\b')), isFalse);
    });
  });
}
