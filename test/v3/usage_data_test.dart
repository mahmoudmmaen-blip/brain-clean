import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/v3/application/usage_providers.dart';
import 'package:brain_clean_mobile/v3/application/v3_state_providers.dart';
import 'package:brain_clean_mobile/v3/data/usage_ask_flags.dart';
import 'package:brain_clean_mobile/v3/data/usage_data_source.dart';
import 'package:brain_clean_mobile/v3/data/usage_day_total.dart';
import 'package:brain_clean_mobile/v3/data/v3_state_repository.dart';
import 'package:brain_clean_mobile/v3/domain/usage_math.dart';
import 'package:brain_clean_mobile/v3/ui/paywall/paywall_personal_stats.dart';
import 'package:brain_clean_mobile/v3/ui/progress/usage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/hive_test_fixtures.dart';

void main() {
  group('UsageAskGate', () {
    test('ask #1 only when askCount is 0 and no access', () {
      expect(
        UsageAskGate.shouldShow(
          trigger: UsageAskTrigger.progressOpen,
          askCount: 0,
          ask1Declined: false,
          hasAccess: false,
        ),
        isTrue,
      );
      expect(
        UsageAskGate.shouldShow(
          trigger: UsageAskTrigger.progressOpen,
          askCount: 1,
          ask1Declined: true,
          hasAccess: false,
        ),
        isFalse,
      );
    });

    test('ask #2 only after declined #1 + SOS win', () {
      expect(
        UsageAskGate.shouldShow(
          trigger: UsageAskTrigger.sosWin,
          askCount: 1,
          ask1Declined: true,
          hasAccess: false,
        ),
        isTrue,
      );
      expect(
        UsageAskGate.shouldShow(
          trigger: UsageAskTrigger.sosWin,
          askCount: 1,
          ask1Declined: false,
          hasAccess: false,
        ),
        isFalse,
      );
    });

    test('never a 3rd ask', () {
      expect(
        UsageAskGate.shouldShow(
          trigger: UsageAskTrigger.progressOpen,
          askCount: 2,
          ask1Declined: true,
          hasAccess: false,
        ),
        isFalse,
      );
      expect(
        UsageAskGate.shouldShow(
          trigger: UsageAskTrigger.sosWin,
          askCount: 2,
          ask1Declined: true,
          hasAccess: false,
        ),
        isFalse,
      );
    });

    test('never ask when access granted', () {
      expect(
        UsageAskGate.shouldShow(
          trigger: UsageAskTrigger.progressOpen,
          askCount: 0,
          ask1Declined: false,
          hasAccess: true,
        ),
        isFalse,
      );
    });
  });

  group('UsageMath', () {
    final days = [
      const UsageDayTotal(date: '2026-01-01', minutes: 360),
      const UsageDayTotal(date: '2026-01-02', minutes: 300),
      const UsageDayTotal(date: '2026-01-03', minutes: 240),
      const UsageDayTotal(date: '2026-01-04', minutes: 180),
      const UsageDayTotal(date: '2026-01-05', minutes: 120),
      const UsageDayTotal(date: '2026-01-06', minutes: 90),
      const UsageDayTotal(date: '2026-01-07', minutes: 60),
      const UsageDayTotal(date: '2026-01-08', minutes: 30),
    ];

    test('yesterday and 7-day average', () {
      final now = DateTime(2026, 1, 8, 12);
      expect(UsageMath.yesterdayHours(days, now), 1.0);
      final avg = UsageMath.averageHours(days, now: now, window: 7);
      expect(avg, isNotNull);
      expect(avg!, closeTo(1020 / 7 / 60, 0.001));
    });

    test('from A to B needs at least 3 days', () {
      expect(UsageMath.firstVsLastWindow(days.take(2).toList()), isNull);
      final ft = UsageMath.firstVsLastWindow(days);
      expect(ft, isNotNull);
      expect(ft!.from, greaterThan(ft.to));
    });
  });

  group('repository flags + cache', () {
    late InMemoryHiveBox box;
    late V3StateLocalRepository repo;

    setUp(() {
      box = InMemoryHiveBox();
      repo = V3StateLocalRepository(box: box);
    });

    test('ask flags persist', () async {
      await repo.saveUsageAskFlags(
        const UsageAskFlags(askCount: 1, ask1Declined: true),
      );
      final flags = await repo.loadUsageAskFlags();
      expect(flags.askCount, 1);
      expect(flags.ask1Declined, isTrue);
    });

    test('usage cache persists', () async {
      await repo.saveUsageCache([
        const UsageDayTotal(date: '2026-01-01', minutes: 120),
      ]);
      final cached = await repo.loadUsageCache();
      expect(cached, hasLength(1));
      expect(cached.first.minutes, 120);
    });
  });

  testWidgets('card hidden without access', (tester) async {
    final fake = FakeUsageDataSource(hasAccessValue: false);
    final box = InMemoryHiveBox();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usageDataSourceProvider.overrideWithValue(fake),
          v3StateRepositoryProvider.overrideWithValue(
            V3StateLocalRepository(box: box),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: supportedLocales,
          home: const Scaffold(body: UsageSummaryCard()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('v3_progress_usage_summary')), findsNothing);
    expect(
      find.byKey(const Key('v3_progress_usage_summary_slot')),
      findsOneWidget,
    );
  });

  testWidgets('card shows from-to with access and data', (tester) async {
    final fake = FakeUsageDataSource(
      hasAccessValue: true,
      days: [
        for (var i = 1; i <= 8; i++)
          UsageDayTotal(
            date: '2026-01-${i.toString().padLeft(2, '0')}',
            minutes: 60 * (9 - i),
          ),
      ],
    );
    final box = InMemoryHiveBox();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usageDataSourceProvider.overrideWithValue(fake),
          v3StateRepositoryProvider.overrideWithValue(
            V3StateLocalRepository(box: box),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: supportedLocales,
          home: Scaffold(
            body: UsageSummaryCard(nowOverride: DateTime(2026, 1, 8, 12)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('v3_progress_usage_summary')), findsOneWidget);
    expect(find.byKey(const Key('v3_usage_from_to')), findsOneWidget);
  });

  test('paywall hours chip only with usage from/to', () {
    final withHours = PaywallPersonalStats.fromLocalData(
      dayProgress: const [],
      sosLogs: const [],
      clarityResults: const [],
      usageHoursFrom: 6.2,
      usageHoursTo: 5.1,
    );
    expect(withHours.hasHours, isTrue);

    final without = PaywallPersonalStats.fromLocalData(
      dayProgress: const [],
      sosLogs: const [],
      clarityResults: const [],
    );
    expect(without.hasHours, isFalse);
  });

  test('notifier records ask shown and declined; no 3rd ask', () async {
    final box = InMemoryHiveBox();
    final repo = V3StateLocalRepository(box: box);
    final fake = FakeUsageDataSource(hasAccessValue: false);
    final container = ProviderContainer(
      overrides: [
        usageDataSourceProvider.overrideWithValue(fake),
        v3StateRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    await container.read(usageSnapshotProvider.future);
    await container.read(usageSnapshotProvider.notifier).recordAskShown();
    var flags = await repo.loadUsageAskFlags();
    expect(flags.askCount, 1);

    await container.read(usageSnapshotProvider.notifier).recordAskDeclined();
    flags = await repo.loadUsageAskFlags();
    expect(flags.ask1Declined, isTrue);
    expect(
      UsageAskGate.shouldShow(
        trigger: UsageAskTrigger.sosWin,
        askCount: flags.askCount,
        ask1Declined: flags.ask1Declined,
        hasAccess: false,
      ),
      isTrue,
    );

    await container.read(usageSnapshotProvider.notifier).recordAskShown();
    flags = await repo.loadUsageAskFlags();
    expect(flags.askCount, 2);
    expect(
      UsageAskGate.shouldShow(
        trigger: UsageAskTrigger.sosWin,
        askCount: flags.askCount,
        ask1Declined: true,
        hasAccess: false,
      ),
      isFalse,
    );
  });
}
