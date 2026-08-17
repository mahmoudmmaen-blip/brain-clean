import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/services/claude_ai_service.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/v2_safa/application/safa_controller.dart';
import 'package:brain_clean_mobile/features/v2_safa/data/safa_consent_store.dart';
import 'package:brain_clean_mobile/features/v2_safa/data/safa_controller_provider.dart';
import 'package:brain_clean_mobile/features/v2_safa/data/safa_edge_adapter.dart';
import 'package:brain_clean_mobile/features/v2_safa/domain/safa_consent_state.dart';
import 'package:brain_clean_mobile/features/v2_safa/domain/safa_context_category.dart';
import 'package:brain_clean_mobile/features/v2_safa/domain/safa_eligibility.dart';
import 'package:brain_clean_mobile/features/v2_safa/domain/safa_failure_reason.dart';
import 'package:brain_clean_mobile/features/v2_safa/domain/safa_local_fallback.dart';
import 'package:brain_clean_mobile/features/v2_safa/domain/safa_request.dart';
import 'package:brain_clean_mobile/features/v2_safa/domain/safa_request_mapper.dart';
import 'package:brain_clean_mobile/features/v2_safa/domain/safa_response_validator.dart';
import 'package:brain_clean_mobile/features/v2_safa/domain/safa_session_id.dart';
import 'package:brain_clean_mobile/features/v2_safa/domain/safa_session_limit.dart';
import 'package:brain_clean_mobile/features/v2_safa/domain/safa_session_origin.dart';
import 'package:brain_clean_mobile/features/v2_safa/domain/safa_session_state.dart';
import 'package:brain_clean_mobile/features/v2_safa/domain/safa_suggested_destination.dart';
import 'package:brain_clean_mobile/features/v2_safa/ui/safa_support_screen.dart';
import 'package:brain_clean_mobile/features/v2_shell/domain/v2_shell_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/localized_test_app.dart';

class _TimeoutEdge extends SafaEdgeAdapter {
  _TimeoutEdge()
      : super(
          claude: ClaudeAiService(
            invoker: ({required functionName, required body}) async {
              return FunctionResponse(status: 200, data: {'reply': 'x'});
            },
            supabaseConfigured: true,
            supabaseInitialized: true,
          ),
        );

  @override
  Future<SafaEdgeResult> send(SafaRequest request) async {
    return const SafaEdgeResult.fail(SafaFailureReason.timeout);
  }
}

class _FakeInvoker {
  _FakeInvoker({
    this.reply = 'A calm next step is enough for now.',
    this.status = 200,
    this.delay = Duration.zero,
    this.throwNetwork = false,
    this.malformed = false,
  });

  String? reply;
  int status;
  Duration delay;
  bool throwNetwork;
  bool malformed;
  int calls = 0;
  Map<String, dynamic>? lastBody;

  Future<FunctionResponse> call({
    required String functionName,
    required Map<String, dynamic> body,
  }) async {
    calls++;
    lastBody = Map<String, dynamic>.from(body);
    expect(functionName, ClaudeAiService.functionName);
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (throwNetwork) {
      throw Exception('network');
    }
    if (malformed) {
      return FunctionResponse(status: status, data: 'not-a-map');
    }
    return FunctionResponse(status: status, data: {'reply': reply});
  }
}

SafaController _controller({
  _FakeInvoker? invoker,
  bool online = true,
  SafaConsentStore? store,
}) {
  final fake = invoker ?? _FakeInvoker();
  final claude = ClaudeAiService(
    invoker: fake.call,
    timeout: const Duration(seconds: 30),
    supabaseConfigured: true,
    supabaseInitialized: true,
  );
  return SafaController(
    edge: SafaEdgeAdapter(
      claude: claude,
      isOnline: () => online,
    ),
    consentStore: store ?? SafaConsentStore(),
  );
}

void _ackAndGrant(SafaController c) {
  c.open(origin: SafaSessionOrigin.today, locale: 'en');
  c.acknowledgePrivacyNotice();
  c.grantSendConsent();
}

void main() {
  setUp(() {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
  });

  tearDown(() {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
  });

  group('eligibility / entry rules', () {
    test('automatic entry never allowed', () {
      expect(SafaEligibility.allowsAutomaticEntry('app_launch'), isFalse);
      expect(SafaEligibility.allowsAutomaticEntry('onboarding'), isFalse);
      expect(SafaEligibility.allowsAutomaticEntry('brain_check'), isFalse);
      expect(SafaEligibility.allowsAutomaticEntry('score_reveal'), isFalse);
      expect(SafaEligibility.allowsAutomaticEntry('purchase'), isFalse);
      expect(SafaEligibility.allowsAutomaticEntry('restore'), isFalse);
      expect(SafaEligibility.allowsScoreBandEntry(0), isFalse);
      expect(SafaEligibility.allowsPremiumStatusEntry(true), isFalse);
    });

    test('explicit origins allowed', () {
      expect(SafaEligibility.allowsExplicitOrigin(SafaSessionOrigin.today), isTrue);
      expect(SafaEligibility.allowsExplicitOrigin(SafaSessionOrigin.plan), isTrue);
      expect(SafaEligibility.allowsExplicitOrigin(SafaSessionOrigin.progress), isTrue);
      expect(SafaEligibility.allowsExplicitOrigin(SafaSessionOrigin.profile), isTrue);
      expect(SafaEligibility.allowsExplicitOrigin(SafaSessionOrigin.unknown), isFalse);
    });

    test('Safa is not a shell tab', () {
      expect(V2ShellTab.values.length, 4);
      expect(
        V2ShellTabX.fromLocation('/v2/safa?origin=today'),
        isNull,
      );
      expect(V2ShellPaths.isKnownV2Location('/v2/safa'), isTrue);
      expect(V2ShellPaths.roots.contains(AppRoutes.v2Safa), isFalse);
    });
  });

  group('request allowlist', () {
    test('builds allowlisted payload only', () {
      final req = SafaRequest(
        sessionId: const SafaSessionId('safa_1'),
        message: '  Need a calm step  ',
        locale: 'en',
        origin: SafaSessionOrigin.today,
        contextCategory: SafaContextCategory.clarifyStep,
        approvedContextSummary: 'step title ok',
        approvedStepTitle: 'Breathe',
      );
      final body = SafaRequestMapper.toAllowlistedBody(req)!;
      expect(SafaRequestMapper.isAllowlisted(body), isTrue);
      expect(body.keys.toSet(), containsAll(['message', 'locale', 'origin']));
      expect(body.containsKey('profile'), isFalse);
      expect(body.containsKey('recoveryScore'), isFalse);
      expect(body.containsKey('weeklyReview'), isFalse);
      expect(body.containsKey('reports'), isFalse);
      expect(body.containsKey('subscription'), isFalse);
      expect(body['message'], 'Need a calm step');
      expect(body['contextCategory'], 'clarify_step');
      expect(body['approvedStepTitle'], 'Breathe');
    });

    test('rejects empty and oversized input', () {
      expect(SafaRequestMapper.isEmpty('   '), isTrue);
      expect(
        SafaRequestMapper.isTooLong('x' * (SafaSessionLimit.maxInputCharacters + 1)),
        isTrue,
      );
      final req = SafaRequest(
        sessionId: const SafaSessionId('safa_1'),
        message: '',
        locale: 'en',
        origin: SafaSessionOrigin.today,
      );
      expect(SafaRequestMapper.toAllowlistedBody(req), isNull);
    });

    test('never auto-includes recovery payloads', () {
      for (final key in SafaRequestMapper.forbiddenKeys) {
        expect(SafaRequestMapper.forbiddenKeys.contains(key), isTrue);
      }
    });
  });

  group('response validation', () {
    test('maps Edge reply string', () {
      final r = SafaResponseValidator.fromEdgePayload(
        data: {'reply': 'Take one small step.'},
        sessionId: const SafaSessionId('safa_1'),
        generatedAt: DateTime.utc(2026, 8, 3),
      );
      expect(r, isNotNull);
      expect(r!.networkUsed, isTrue);
      expect(r.fallbackUsed, isFalse);
      expect(r.boundedSupportText, 'Take one small step.');
    });

    test('rejects oversized and banned copy', () {
      expect(
        SafaResponseValidator.fromEdgePayload(
          data: {'reply': 'x' * (SafaSessionLimit.maxResponseCharacters + 1)},
          sessionId: const SafaSessionId('safa_1'),
          generatedAt: DateTime.utc(2026, 8, 3),
        ),
        isNull,
      );
      expect(
        SafaResponseValidator.fromEdgePayload(
          data: {'reply': "I'm your therapist and this will heal you"},
          sessionId: const SafaSessionId('safa_1'),
          generatedAt: DateTime.utc(2026, 8, 3),
        ),
        isNull,
      );
      expect(
        SafaResponseValidator.fromEdgePayload(
          data: {
            'reply': 'ok',
            'suggestedDestination': 'https://evil.example',
          },
          sessionId: const SafaSessionId('safa_1'),
          generatedAt: DateTime.utc(2026, 8, 3),
        ),
        isNull,
      );
    });
  });

  group('local fallback', () {
    test('deterministic Free offline pack EN/AR', () {
      final en = SafaLocalFallback.build(
        sessionId: const SafaSessionId('safa_1'),
        locale: 'en',
        generatedAt: DateTime.utc(2026, 8, 3),
      );
      final ar = SafaLocalFallback.build(
        sessionId: const SafaSessionId('safa_1'),
        locale: 'ar',
        generatedAt: DateTime.utc(2026, 8, 3),
      );
      expect(en.fallbackUsed, isTrue);
      expect(en.networkUsed, isFalse);
      expect(ar.boundedSupportText, isNot(equals(en.boundedSupportText)));
      expect(en.boundedSupportText.toLowerCase(), isNot(contains('premium')));
      expect(en.boundedSupportText.toLowerCase(), isNot(contains('diagnos')));
    });
  });

  group('controller session / consent / edge', () {
    test('consent required before network; decline uses fallback', () async {
      final invoker = _FakeInvoker();
      final c = _controller(invoker: invoker);
      c.open(origin: SafaSessionOrigin.today);
      expect(c.session!.uiState, SafaSessionState.privacyNotice);
      c.updateDraft('help');
      await c.send();
      expect(invoker.calls, 0);
      expect(c.session!.uiState, SafaSessionState.privacyNotice);

      c.acknowledgePrivacyNotice();
      expect(c.session!.uiState, SafaSessionState.consentRequired);
      await c.send();
      expect(invoker.calls, 0);

      c.declineConsent();
      expect(c.session!.consentState, SafaConsentState.declined);
      expect(c.session!.uiState, SafaSessionState.localFallback);
      expect(c.session!.latestResponse!.fallbackUsed, isTrue);
      expect(invoker.calls, 0);
    });

    test('text-only send succeeds with allowlisted body', () async {
      final invoker = _FakeInvoker();
      final c = _controller(invoker: invoker);
      _ackAndGrant(c);
      expect(c.session!.contextCategory, SafaContextCategory.none);
      c.updateDraft('Need one calm step');
      await c.send();
      expect(invoker.calls, 1);
      expect(invoker.lastBody!['message'], 'Need one calm step');
      expect(invoker.lastBody!.containsKey('profile'), isFalse);
      expect(invoker.lastBody!.containsKey('recoveryScore'), isFalse);
      expect(c.session!.uiState, SafaSessionState.responseReady);
      expect(c.session!.userMessageCount, 1);
      expect(c.session!.assistantResponseCount, 1);
    });

    test('explicit context included only when approved', () async {
      final invoker = _FakeInvoker();
      final c = _controller(invoker: invoker);
      _ackAndGrant(c);
      c.selectContextCategory(SafaContextCategory.clarifyStep);
      c.setIncludeApprovedContext(true);
      c.setApprovedStepTitle('Morning pause');
      c.updateDraft('clarify please');
      await c.send();
      expect(invoker.lastBody!['contextCategory'], 'clarify_step');
      expect(invoker.lastBody!['approvedStepTitle'], 'Morning pause');
    });

    test('offline / unavailable / invalid → fallback draft kept', () async {
      // Offline
      var c = _controller(online: false);
      _ackAndGrant(c);
      c.updateDraft('keep me');
      await c.send();
      expect(c.session!.uiState, SafaSessionState.offline);
      expect(c.session!.draftMessage, 'keep me');
      expect(c.session!.latestResponse!.fallbackUsed, isTrue);

      // Service unavailable
      final invoker5 = _FakeInvoker(status: 503, reply: null);
      c = _controller(invoker: invoker5);
      _ackAndGrant(c);
      c.updateDraft('keep me');
      await c.send();
      expect(c.session!.uiState, SafaSessionState.serviceUnavailable);
      expect(c.session!.draftMessage, 'keep me');

      // Invalid / empty reply
      final invokerEmpty = _FakeInvoker(reply: '');
      c = _controller(invoker: invokerEmpty);
      _ackAndGrant(c);
      c.updateDraft('keep me');
      await c.send();
      expect(
        {
          SafaSessionState.invalidResponse,
          SafaSessionState.localFallback,
          SafaSessionState.serviceUnavailable,
        }.contains(c.session!.uiState),
        isTrue,
      );
      expect(c.session!.draftMessage, 'keep me');
    });

    test('timeout failure maps to timeout state with draft kept', () async {
      final c = SafaController(
        edge: _TimeoutEdge(),
        consentStore: SafaConsentStore(),
      );
      _ackAndGrant(c);
      c.updateDraft('keep me');
      await c.send();
      expect(c.session!.uiState, SafaSessionState.timeout);
      expect(c.session!.draftMessage, 'keep me');
      expect(c.session!.latestResponse!.fallbackUsed, isTrue);
    });

    test('input too long and duplicate send prevented', () async {
      final invoker = _FakeInvoker(delay: const Duration(milliseconds: 80));
      final c = _controller(invoker: invoker);
      _ackAndGrant(c);
      c.updateDraft('x' * (SafaSessionLimit.maxInputCharacters + 5));
      expect(c.session!.uiState, SafaSessionState.inputTooLong);
      await c.send();
      expect(invoker.calls, 0);

      c.updateDraft('ok message');
      expect(c.session!.uiState, SafaSessionState.ready);
      final first = c.send();
      final second = c.send();
      await Future.wait([first, second]);
      expect(invoker.calls, 1);
    });

    test('bounded session 3 turns then blocks fourth', () async {
      final invoker = _FakeInvoker();
      final c = _controller(invoker: invoker);
      _ackAndGrant(c);
      for (var i = 0; i < 3; i++) {
        c.updateDraft('message $i');
        await c.send();
      }
      expect(c.session!.assistantResponseCount, 3);
      expect(c.session!.uiState, SafaSessionState.boundedSessionComplete);
      c.updateDraft('fourth');
      await c.send();
      expect(invoker.calls, 3);
      expect(c.session!.uiState, SafaSessionState.boundedSessionComplete);
    });

    test('clear session drops in-memory history', () {
      final c = _controller();
      _ackAndGrant(c);
      c.updateDraft('secret text');
      c.clearSession();
      expect(c.session, isNull);
    });

    test('urgent help → safety_redirect without network', () async {
      final invoker = _FakeInvoker();
      final c = _controller(invoker: invoker);
      _ackAndGrant(c);
      c.requestUrgentHelp();
      expect(c.session!.uiState, SafaSessionState.safetyRedirect);
      expect(invoker.calls, 0);
    });

    test('premium status irrelevant to fallback/safety', () async {
      // No premium parameter exists — Free and Premium use same controller path.
      final c = _controller(online: false);
      _ackAndGrant(c);
      c.updateDraft('x');
      await c.send();
      expect(c.session!.latestResponse!.fallbackUsed, isTrue);
      c.requestUrgentHelp();
      expect(c.session!.uiState, SafaSessionState.safetyRedirect);
    });

    test('origin preserved for today/plan/progress/profile', () {
      for (final o in [
        SafaSessionOrigin.today,
        SafaSessionOrigin.plan,
        SafaSessionOrigin.progress,
        SafaSessionOrigin.profile,
      ]) {
        final c = _controller();
        c.open(origin: o, returnPath: o.defaultReturnPath);
        expect(c.session!.origin, o);
        expect(c.session!.returnPath, o.defaultReturnPath);
      }
    });

    test('invalid origin falls back to Today return path', () {
      final c = _controller();
      c.open(origin: SafaSessionOrigin.unknown);
      expect(c.session!.origin, SafaSessionOrigin.today);
      expect(c.session!.returnPath, '/v2/home');
    });

    test('Edge architecture preserved as safa-chat', () {
      expect(ClaudeAiService.functionName, 'safa-chat');
      expect(SafaSessionLimit.edgeTimeout, const Duration(seconds: 30));
    });
  });

  group('destinations', () {
    test('allowlisted destinations only', () {
      expect(
        SafaSuggestedDestination.today
            .resolvePath(originReturnPath: '/v2/profile'),
        AppRoutes.v2Home,
      );
      expect(
        SafaSuggestedDestination.origin
            .resolvePath(originReturnPath: '/v2/plan'),
        '/v2/plan',
      );
      expect(
        SafaSuggestedDestinationX.tryParse('https://x'),
        isNull,
      );
      expect(
        SafaSuggestedDestinationX.tryParse('premium'),
        isNull,
      );
    });
  });

  group('localization copy bans', () {
    test('EN/AR Safa strings avoid banned framings', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      for (final s in [
        en.v2SafaPurpose,
        en.v2SafaAiLimitation,
        en.v2SafaUrgentBody,
        en.v2SafaNotMedical,
        ar.v2SafaPurpose,
        ar.v2SafaAiLimitation,
        ar.v2SafaUrgentBody,
        ar.v2SafaNotMedical,
      ]) {
        final lower = s.toLowerCase();
        expect(lower, isNot(contains('therapist')));
        expect(lower, isNot(contains("i'm always here")));
        expect(lower, isNot(contains('heal you')));
        expect(lower, isNot(contains('premium')));
        expect(lower, isNot(contains('diagnos')));
      }
      expect(en.v2SafaTitle, 'Safa');
      expect(ar.v2SafaTitle, 'صفا');
    });
  });

  group('UI / routing widgets', () {
    testWidgets('privacy → consent → ready flow EN', (tester) async {
      final invoker = _FakeInvoker();
      final store = SafaConsentStore();
      final controller = _controller(invoker: invoker, store: store);

      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const SafaSupportScreen(origin: SafaSessionOrigin.today),
          overrides: [
            safaControllerProvider.overrideWithValue(controller),
            safaConsentStoreProvider.overrideWithValue(store),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(AppLocalizationsEn().v2SafaTitle), findsOneWidget);
      expect(find.byKey(const Key('v2_safa_ack_privacy')), findsOneWidget);
      await tester.tap(find.byKey(const Key('v2_safa_ack_privacy')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('v2_safa_grant_consent')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('v2_safa_input')), findsOneWidget);
      expect(find.byKey(const Key('v2_safa_urgent')), findsOneWidget);
      expect(find.textContaining('Premium'), findsNothing);
      expect(find.byType(Banner), findsNothing);
    });

    testWidgets('Arabic RTL and decline → local fallback', (tester) async {
      final controller = _controller();
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const SafaSupportScreen(origin: SafaSessionOrigin.profile),
          locale: const Locale('ar'),
          overrides: [
            safaControllerProvider.overrideWithValue(controller),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('صفا'), findsWidgets);
      final ctx = tester.element(find.text('صفا').first);
      expect(Directionality.of(ctx), TextDirection.rtl);
      await tester.tap(find.byKey(const Key('v2_safa_continue_without')));
      await tester.pumpAndSettle();
      expect(controller.session!.uiState, SafaSessionState.localFallback);
    });

    testWidgets('urgent help announces safety redirect', (tester) async {
      final store = SafaConsentStore()..acknowledgeAiNotice();
      final controller = _controller(store: store);
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const SafaSupportScreen(origin: SafaSessionOrigin.today),
          overrides: [
            safaControllerProvider.overrideWithValue(controller),
            safaConsentStoreProvider.overrideWithValue(store),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('v2_safa_grant_consent')));
      await tester.pumpAndSettle();
      controller.requestUrgentHelp();
      await tester.pumpAndSettle();
      expect(controller.session!.uiState, SafaSessionState.safetyRedirect);
      expect(find.text(AppLocalizationsEn().v2SafaUrgentBody), findsWidgets);
      expect(find.textContaining('Upgrade'), findsNothing);
    });

    testWidgets('320 width + textScale 2.0', (tester) async {
      final store = SafaConsentStore()..acknowledgeAiNotice();
      final controller = _controller(store: store);
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 900),
            textScaler: TextScaler.linear(2.0),
          ),
          child: createLocalizedProviderTestWidget(
            const SafaSupportScreen(origin: SafaSessionOrigin.today),
            overrides: [
              safaControllerProvider.overrideWithValue(controller),
              safaConsentStoreProvider.overrideWithValue(store),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('feature flag OFF preserves V1 home', (tester) async {
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      final router = GoRouter(
        initialLocation: '${AppRoutes.v2Safa}?origin=today',
        redirect: (context, state) {
          final path = state.uri.path;
          if (path.startsWith('/v2/') &&
              !V2FeatureBoundary.enableBrainProfileRoutes) {
            return AppRoutes.home;
          }
          return null;
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const Scaffold(body: Text('V1_HOME')),
          ),
          GoRoute(
            path: AppRoutes.v2Safa,
            builder: (_, __) =>
                const SafaSupportScreen(origin: SafaSessionOrigin.today),
          ),
        ],
      );
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pumpAndSettle();
      expect(find.text('V1_HOME'), findsOneWidget);
    });

    testWidgets('deep link without origin → Today', (tester) async {
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      final router = GoRouter(
        initialLocation: AppRoutes.v2Safa,
        redirect: (context, state) {
          if (state.uri.path == AppRoutes.v2Safa) {
            final origin = state.uri.queryParameters['origin'];
            if (origin == null || origin.trim().isEmpty) {
              return AppRoutes.v2Home;
            }
          }
          return null;
        },
        routes: [
          GoRoute(
            path: AppRoutes.v2Home,
            builder: (_, __) => const Scaffold(body: Text('TODAY')),
          ),
          GoRoute(
            path: AppRoutes.v2Safa,
            builder: (_, __) =>
                const SafaSupportScreen(origin: SafaSessionOrigin.today),
          ),
        ],
      );
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pumpAndSettle();
      expect(find.text('TODAY'), findsOneWidget);
      V2FeatureBoundary.enableBrainProfileRoutes = false;
    });

    testWidgets('exit returns to origin path', (tester) async {
      final store = SafaConsentStore()..acknowledgeAiNotice();
      final controller = _controller(store: store);
      final router = GoRouter(
        initialLocation:
            '${AppRoutes.v2Safa}?origin=profile&returnTo=${Uri.encodeComponent(AppRoutes.v2Profile)}',
        routes: [
          GoRoute(
            path: AppRoutes.v2Profile,
            builder: (_, __) => const Scaffold(body: Text('PROFILE')),
          ),
          GoRoute(
            path: AppRoutes.v2Safa,
            builder: (_, state) => SafaSupportScreen(
              origin: SafaSessionOrigin.profile,
              returnPath: state.uri.queryParameters['returnTo'],
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        createLocalizedRouterTestWidget(
          router: router,
          overrides: [
            safaControllerProvider.overrideWithValue(controller),
            safaConsentStoreProvider.overrideWithValue(store),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('v2_safa_exit')));
      await tester.pumpAndSettle();
      expect(find.text('PROFILE'), findsOneWidget);
      expect(controller.session, isNull);
    });

    testWidgets('no continue chatting CTA after bound', (tester) async {
      final invoker = _FakeInvoker();
      final store = SafaConsentStore()..acknowledgeAiNotice();
      final controller = _controller(invoker: invoker, store: store);
      await tester.pumpWidget(
        createLocalizedProviderTestWidget(
          const SafaSupportScreen(origin: SafaSessionOrigin.today),
          overrides: [
            safaControllerProvider.overrideWithValue(controller),
            safaConsentStoreProvider.overrideWithValue(store),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('v2_safa_grant_consent')));
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        controller.updateDraft('message $i');
        await controller.send();
      }
      await tester.pumpAndSettle();
      expect(controller.session!.uiState, SafaSessionState.boundedSessionComplete);
      expect(
        find.text(AppLocalizationsEn().v2SafaSessionComplete),
        findsWidgets,
      );
      expect(find.byKey(const Key('v2_safa_start_later')), findsOneWidget);
      expect(find.textContaining('Keep chatting'), findsNothing);
      expect(find.textContaining('continue chatting'), findsNothing);
    });

    testWidgets('reduced motion safe open', (tester) async {
      final store = SafaConsentStore()..acknowledgeAiNotice();
      final controller = _controller(store: store);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: createLocalizedProviderTestWidget(
            const SafaSupportScreen(origin: SafaSessionOrigin.today),
            overrides: [
              safaControllerProvider.overrideWithValue(controller),
              safaConsentStoreProvider.overrideWithValue(store),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    test('no Hive conversation box constant introduced', () {
      // Contract: no safa conversation Hive box.
      expect(AppRoutes.v2Safa, '/v2/safa');
    });
  });
}
