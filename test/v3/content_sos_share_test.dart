import 'dart:io';

import 'package:brain_clean_mobile/core/data/app_meta_box_provider.dart';
import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/core/providers/locale_provider.dart';
import 'package:brain_clean_mobile/core/theme/app_theme.dart';
import 'package:brain_clean_mobile/features/pro/application/subscription_service_provider.dart';
import 'package:brain_clean_mobile/v3/application/in_app_review_service.dart';
import 'package:brain_clean_mobile/v3/application/sos_now_provider.dart';
import 'package:brain_clean_mobile/v3/application/v3_state_providers.dart';
import 'package:brain_clean_mobile/v3/content/content.dart';
import 'package:brain_clean_mobile/v3/content/exercises_content.dart';
import 'package:brain_clean_mobile/v3/data/user_inputs.dart';
import 'package:brain_clean_mobile/v3/data/v3_state_repository.dart';
import 'package:brain_clean_mobile/v3/domain/in_app_review_gate.dart';
import 'package:brain_clean_mobile/v3/domain/sos_helpers.dart';
import 'package:brain_clean_mobile/v3/domain/sos_night.dart';
import 'package:brain_clean_mobile/v3/ui/share/share_card.dart';
import 'package:brain_clean_mobile/v3/ui/sos/sos_flow_screen.dart';
import 'package:brain_clean_mobile/v3/ui/sos/sos_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/hive_test_fixtures.dart';

void main() {
  late InMemoryHiveBox box;
  late InMemoryHiveBox metaBox;
  late V3StateLocalRepository repo;
  late ContentBundle bundle;
  late FakeInAppReviewService fakeReview;

  setUpAll(() async {
    bundle = await ContentRepository(
      assetLoader: (p) => File(p).readAsString(),
    ).load();
  });

  setUp(() {
    box = InMemoryHiveBox();
    metaBox = InMemoryHiveBox();
    repo = V3StateLocalRepository(box: box);
    fakeReview = FakeInAppReviewService(available: true);
  });

  List<Override> overrides({
    bool isPro = false,
    DateTime? now,
  }) =>
      [
        v3StateRepositoryProvider.overrideWithValue(repo),
        v3ContentProvider.overrideWith((ref) async => bundle),
        v3AppStateProvider.overrideWith((ref) => repo.load()),
        isProUserProvider.overrideWith((ref) => isPro),
        localeProvider.overrideWith((ref) => const Locale('en')),
        appMetaBoxProvider.overrideWithValue(metaBox),
        inAppReviewServiceProvider.overrideWithValue(fakeReview),
        if (now != null) sosNowProvider.overrideWithValue(now),
      ];

  Widget wrap(Widget child, {bool isPro = false, DateTime? now}) {
    return ProviderScope(
      overrides: overrides(isPro: isPro, now: now),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: supportedLocales,
        theme: AppTheme.dark,
        home: child,
      ),
    );
  }

  group('week-1 early wins content', () {
    test('day 4 = notif audit, day 5 = home screen', () {
      expect(bundle.program.dayByNumber(4)!.practiceId, 'ex_notif_audit');
      expect(bundle.program.dayByNumber(5)!.practiceId, 'ex_home_screen');
      expect(bundle.program.dayByNumber(8)!.practiceId, 'ex_attention_anchor');
      expect(bundle.program.dayByNumber(9)!.practiceId, 'ex_pause_breath');
    });

    test('days 1-7 only free exercises', () {
      for (final day in bundle.program.days.where((d) => d.day <= 7)) {
        final practice = bundle.exercises.byId(day.practiceId)!;
        expect(
          practice.tier,
          ExerciseTier.free,
          reason: 'day ${day.day} ${day.practiceId}',
        );
      }
      expect(bundle.exercises.byId('ex_notif_audit')!.tier, ExerciseTier.free);
      expect(bundle.exercises.byId('ex_home_screen')!.tier, ExerciseTier.free);
    });
  });

  group('SOS v2 bored + night', () {
    test('bored flow shows replacement first with defaults when empty', () {
      final bored = bundle.sos.byId('sos_bored')!;
      expect(bored.steps.first.type, 'suggest_replacement');
      expect(bored.steps.first.duration, '5');
      final items = resolveSosReplacements(
        sos: bundle.sos,
        inputs: const UserInputs(),
        duration: '5',
        languageCode: 'en',
      );
      expect(items, isNotEmpty);
      expect(items.first.toLowerCase(), contains('water'));
    });

    testWidgets('bored UI shows replacement first with defaults', (tester) async {
      await tester.pumpWidget(wrap(const V3SosFlowScreen(flowId: 'sos_bored')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('v3_sos_step_replacement')), findsOneWidget);
      expect(find.textContaining('Drink a glass of water'), findsOneWidget);
    });

    test('night window helper', () {
      expect(isSosNightWindow(DateTime(2026, 10, 18, 23, 30)), isTrue);
      expect(isSosNightWindow(DateTime(2026, 10, 18, 4, 59)), isTrue);
      expect(isSosNightWindow(DateTime(2026, 10, 18, 5, 0)), isFalse);
      expect(isSosNightWindow(DateTime(2026, 10, 18, 12, 0)), isFalse);
    });

    testWidgets('at 23:30 sleep flow is first and highlighted', (tester) async {
      await tester.pumpWidget(
        wrap(
          const V3SosHubScreen(),
          now: DateTime(2026, 10, 18, 23, 30),
        ),
      );
      await tester.pumpAndSettle();

      final sleep = tester.getTopLeft(find.byKey(const Key('v3_sos_flow_sos_sleep')));
      final urge = tester.getTopLeft(find.byKey(const Key('v3_sos_flow_sos_urge')));
      expect(sleep.dy, lessThan(urge.dy));
    });
  });

  group('share card', () {
    testWidgets('builds sosWin and dayMilestone without exceptions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ShareCard(
                    variant: ShareCardVariant.sosWin(before: 8, after: 4),
                    locale: 'ar',
                  ),
                  ShareCard(
                    variant: ShareCardVariant.dayMilestone(
                      days: 7,
                      clarityFrom: 40,
                      clarityTo: 55,
                    ),
                    locale: 'en',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('v3_share_card')), findsNWidgets(2));
      expect(find.textContaining('من 8 إلى 4'), findsOneWidget);
      expect(find.textContaining('7 days'), findsOneWidget);
      expect(find.text(ShareCard.storeName), findsNWidgets(2));
    });
  });

  group('in-app review', () {
    test('gate: sos win when after <= before - 2', () {
      expect(InAppReviewGate.isSosWin(before: 8, after: 6), isTrue);
      expect(InAppReviewGate.isSosWin(before: 8, after: 7), isFalse);
      expect(InAppReviewGate.isSosWin(before: null, after: 4), isFalse);
    });

    test('requested once only, not on paywall day', () async {
      final now = DateTime(2026, 10, 18, 12);
      final ok1 = await maybeRequestInAppReview(
        repo: repo,
        review: fakeReview,
        triggerMet: true,
        now: now,
      );
      expect(ok1, isTrue);
      expect(fakeReview.requestCount, 1);

      final ok2 = await maybeRequestInAppReview(
        repo: repo,
        review: fakeReview,
        triggerMet: true,
        now: now,
      );
      expect(ok2, isFalse);
      expect(fakeReview.requestCount, 1);
    });

    test('skipped on paywall day even if trigger met', () async {
      final now = DateTime(2026, 10, 18, 15);
      await repo.setLastPaywallShownDate(InAppReviewGate.dateKey(now));
      final ok = await maybeRequestInAppReview(
        repo: repo,
        review: fakeReview,
        triggerMet: true,
        now: now,
      );
      expect(ok, isFalse);
      expect(fakeReview.requestCount, 0);
    });

    test('no-op when isAvailable is false', () async {
      fakeReview.available = false;
      final ok = await maybeRequestInAppReview(
        repo: repo,
        review: fakeReview,
        triggerMet: true,
        now: DateTime(2026, 10, 18),
      );
      expect(ok, isFalse);
      expect(fakeReview.requestCount, 0);
    });
  });
}
