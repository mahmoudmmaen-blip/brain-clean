import 'dart:io';

import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations.dart';
import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/brain_check/domain/brain_check_phase.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/application/v2_onboarding_controller.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/data/v2_onboarding_repository.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_onboarding_progress.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_onboarding_state.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_onboarding_status.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_onboarding_step.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_onboarding_version.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/ui/brain_check_entry_boundary_screen.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/ui/v2_onboarding_flow_screen.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/ui/v2_onboarding_step_views.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late String tempDir;

  setUp(() async {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
    tempDir =
        '${Directory.systemTemp.path}/onb_${DateTime.now().microsecondsSinceEpoch}';
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

  Future<AppLocalizations> loadLoc([String code = 'en']) =>
      AppLocalizations.delegate.load(Locale(code));

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

  group('persistence + controller', () {
    test('new onboarding starts at welcome', () async {
      final box = await Hive.openBox<dynamic>('onb_a');
      final repo = V2OnboardingLocalRepository(box: box);
      final controller = V2OnboardingController(repository: repo);
      await controller.hydrate(languageCode: 'en');
      expect(controller.state.currentStep, V2OnboardingStep.welcome);
      expect(controller.state.status, V2OnboardingStatus.notStarted);
      expect(HiveBoxes.v2Onboarding, V2OnboardingVersion.box);
      await box.close();
    });

    test('step persists and resume returns correct step', () async {
      final box = await Hive.openBox<dynamic>('onb_b');
      final repo = V2OnboardingLocalRepository(box: box);
      final c1 = V2OnboardingController(repository: repo);
      await c1.hydrate();
      await c1.advanceFromWelcome();
      await c1.advanceFromExpectations();
      expect(c1.state.currentStep, V2OnboardingStep.consent);

      final c2 = V2OnboardingController(repository: repo);
      await c2.hydrate();
      expect(c2.state.currentStep, V2OnboardingStep.consent);
      expect(c2.state.status, V2OnboardingStatus.inProgress);
      await box.close();
    });

    test('completion handoff is idempotent', () async {
      final box = await Hive.openBox<dynamic>('onb_c');
      final repo = V2OnboardingLocalRepository(box: box);
      final c = V2OnboardingController(repository: repo);
      await c.hydrate();
      await c.markReadyForBrainCheck();
      final first = c.state;
      await c.markReadyForBrainCheck();
      expect(c.state.status, V2OnboardingStatus.readyForBrainCheck);
      expect(c.state.brainCheckReady, isTrue);
      expect(c.state.schemaVersion, first.schemaVersion);
      await box.close();
    });

    test('explicit restart clears onboarding not inventing brain check wipe',
        () async {
      final box = await Hive.openBox<dynamic>('onb_d');
      final repo = V2OnboardingLocalRepository(box: box);
      final c = V2OnboardingController(repository: repo);
      await c.hydrate(languageCode: 'ar');
      await c.advanceFromWelcome();
      await c.setConsent(
        nonMedical: true,
        terms: true,
        analyticsOptIn: false,
      );
      await c.restart(languageCode: 'ar');
      expect(c.state.currentStep, V2OnboardingStep.welcome);
      expect(c.state.consentNonMedical, isFalse);
      expect(c.state.languageCode, 'ar');
      // Restart API touches only v2 onboarding box.
      expect(box.name, isNot(HiveBoxes.brainCheck));
      await box.close();
    });

    test('corrupt state fails safely', () async {
      final box = await Hive.openBox<dynamic>('onb_e');
      await box.put(V2OnboardingLocalRepository.stateKey, 'not-a-map');
      final repo = V2OnboardingLocalRepository(box: box);
      final state = await repo.load();
      expect(state.status, V2OnboardingStatus.corrupt);
      expect(state.currentStep, V2OnboardingStep.welcome);
      await box.close();
    });

    test('language switch preserves progress', () async {
      final box = await Hive.openBox<dynamic>('onb_f');
      final repo = V2OnboardingLocalRepository(box: box);
      final c = V2OnboardingController(repository: repo);
      await c.hydrate(languageCode: 'en');
      await c.advanceFromWelcome();
      await c.setLanguageCode('ar');
      expect(c.state.currentStep, V2OnboardingStep.expectations);
      expect(c.state.languageCode, 'ar');
      await box.close();
    });

    test('consent gate requires required boxes', () async {
      final box = await Hive.openBox<dynamic>('onb_g');
      final c = V2OnboardingController(
        repository: V2OnboardingLocalRepository(box: box),
      );
      await c.hydrate();
      await c.advanceFromWelcome();
      await c.advanceFromExpectations();
      expect(await c.advanceFromConsent(), isFalse);
      await c.setConsent(
        nonMedical: true,
        terms: true,
        analyticsOptIn: false,
      );
      expect(await c.advanceFromConsent(), isTrue);
      expect(c.state.currentStep, V2OnboardingStep.privacy);
      await box.close();
    });

    test('ritual skip leaves null window', () async {
      final box = await Hive.openBox<dynamic>('onb_h');
      final c = V2OnboardingController(
        repository: V2OnboardingLocalRepository(box: box),
      );
      await c.hydrate();
      await c.setRitual(null, skip: true);
      expect(c.state.ritualWindow, isNull);
      expect(c.state.currentStep, V2OnboardingStep.checkIntro);
      await box.close();
    });

    test('order of steps is ONB-01…06 plus ONB-07…09 milestones', () {
      expect(
        V2OnboardingStepX.preCheckOrdered.map((s) => s.screenId).toList(),
        ['ONB-01', 'ONB-02', 'ONB-03', 'ONB-04', 'ONB-05', 'ONB-06'],
      );
      expect(V2OnboardingStep.profileReveal.screenId, 'ONB-07');
      expect(V2OnboardingStep.planReveal.screenId, 'ONB-08');
      expect(V2OnboardingStep.todayPreview.screenId, 'ONB-09');
    });

    test('no remote persistence identifiers', () {
      final json = V2OnboardingState.fresh().toJson();
      expect(json.containsKey('supabase'), isFalse);
      expect(json.containsKey('remote'), isFalse);
    });
  });

  group('copy safety', () {
    test('EN/AR welcome and check intro avoid prohibited claims', () async {
      final en = await loadLoc('en');
      final ar = await loadLoc('ar');
      final enBlob =
          '${en.v2OnboardingWelcomeBody} ${en.v2OnboardingCheckIntroBody} '
          '${en.v2OnboardingConsentNonMedical} ${en.v2BrainCheckEntryNonMedical}';
      final arBlob =
          '${ar.v2OnboardingWelcomeBody} ${ar.v2OnboardingCheckIntroBody} '
          '${ar.v2OnboardingConsentNonMedical}';
      for (final blob in [enBlob.toLowerCase(), arBlob.toLowerCase()]) {
        expect(blob.contains('scientifically proven'), isFalse);
        expect(blob.contains('diagnose you'), isFalse);
        expect(RegExp(r'\bcure\b').hasMatch(blob), isFalse);
      }
      expect(enBlob.toLowerCase(), contains('not a medical'));
      expect(arBlob, contains('ليس تشخيصاً طبياً'));
      // Mentions of injury/damage only appear as denials.
      expect(en.v2OnboardingCheckIntroBody.toLowerCase(), contains('not brain-damage'));
      expect(ar.v2OnboardingCheckIntroBody, contains('ولا كشفاً عن'));
    });

    test('privacy copy matches local-first truths', () async {
      final en = await loadLoc('en');
      expect(en.v2OnboardingPrivacyBody.toLowerCase(), contains('local'));
      expect(en.v2OnboardingPrivacyBody.toLowerCase(), contains('not generated by ai'));
      expect(en.v2OnboardingPrivacyBody.toLowerCase(), contains('resume'));
    });
  });

  group('UI', () {
    testWidgets('English welcome has one primary CTA', (tester) async {
      final loc = await loadLoc('en');
      await tester.pumpWidget(
        wrap(OnbWelcomeView(loc: loc, onContinue: () {})),
      );
      expect(find.text(loc.v2OnboardingWelcomeTitle), findsOneWidget);
      expect(find.widgetWithText(FilledButton, loc.v2OnboardingContinue),
          findsOneWidget);
    });

    testWidgets('Arabic welcome RTL loads', (tester) async {
      final loc = await loadLoc('ar');
      await tester.pumpWidget(
        wrap(
          OnbWelcomeView(loc: loc, onContinue: () {}),
          locale: const Locale('ar'),
        ),
      );
      expect(find.text(loc.v2OnboardingWelcomeTitle), findsOneWidget);
      final context = tester.element(find.text(loc.v2OnboardingWelcomeTitle));
      expect(Directionality.of(context), TextDirection.rtl);
    });

    testWidgets('expectations shows exactly 3 items', (tester) async {
      final loc = await loadLoc('en');
      await tester.pumpWidget(
        wrap(OnbExpectationsView(loc: loc, onContinue: () {})),
      );
      expect(find.textContaining('1.'), findsOneWidget);
      expect(find.textContaining('2.'), findsOneWidget);
      expect(find.textContaining('3.'), findsOneWidget);
    });

    testWidgets('CHK-01 entry start / resume / completed states', (tester) async {
      final loc = await loadLoc('en');
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

      await tester.pumpWidget(
        wrap(
          BrainCheckEntryBody(
            loc: loc,
            loading: false,
            errorKey: null,
            phase: BrainCheckPhase.completed,
            onStart: () {},
            onResume: () {},
            onGoHome: () {},
            onRetry: () {},
          ),
        ),
      );
      expect(find.text(loc.v2BrainCheckEntryAlreadyComplete), findsOneWidget);
      expect(find.text(loc.v2BrainCheckEntryStart), findsNothing);
    });

    testWidgets('320px + textScale 2.0 scrollable', (tester) async {
      final loc = await loadLoc('en');
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(2.0),
          ),
          child: wrap(
            OnbPrivacyView(loc: loc, onContinue: () {}),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('flow body renders current step', (tester) async {
      final repo = _MemoryOnboardingRepo();
      final controller = V2OnboardingController(repository: repo);
      await controller.hydrate(languageCode: 'en');
      final loc = await loadLoc('en');
      await tester.pumpWidget(
        wrap(
          V2OnboardingFlowBody(
            loc: loc,
            controller: controller,
            languageCode: 'en',
            onToggleLanguage: () {},
            onRitualComplete: (_, {required skip}) async {},
            onStartCheck: () {},
            onSkipCheck: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.text(loc.v2OnboardingWelcomeTitle), findsOneWidget);
    });

    test('feature boundary OFF by default; routes defined', () {
      expect(V2FeatureBoundary.enableBrainProfileRoutes, isFalse);
      expect(V2FeatureBoundary.enableV2OnboardingRoutes, isFalse);
      expect(AppRoutes.v2Onboarding, '/v2/onboarding');
      expect(AppRoutes.v2BrainCheckEntry, '/v2/brain-check/entry');
      expect(AppRoutes.onboarding, '/onboarding');
    });

    test('V1 onboarding box name distinct from V2', () {
      expect(HiveBoxes.v2Onboarding, isNot('app_meta'));
      expect(HiveBoxes.v2Onboarding, isNot(HiveBoxes.brainCheck));
    });
  });
}
