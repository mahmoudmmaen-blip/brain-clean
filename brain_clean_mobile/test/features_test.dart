import 'package:brain_clean_mobile/core/data/app_meta_box_provider.dart';
import 'package:brain_clean_mobile/core/providers/locale_provider.dart';import 'package:brain_clean_mobile/features/gamification/level_system.dart';
import 'package:brain_clean_mobile/features/home/application/streak_freeze_provider.dart';
import 'package:brain_clean_mobile/features/home/domain/daily_quotes.dart';
import 'package:brain_clean_mobile/features/reports/weekly_report_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hive_test_fixtures.dart';

void main() {
  test('localeProvider defaults to ar and toggles ar/en', () async {
    final container = ProviderContainer(
      overrides: [
        appMetaBoxProvider.overrideWithValue(InMemoryHiveBox()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(localeProvider).languageCode, 'ar');

    final ref = _FakeWidgetRef(container);
    await toggleLocale(ref);
    expect(container.read(localeProvider).languageCode, 'en');

    await toggleLocale(ref);
    expect(container.read(localeProvider).languageCode, 'ar');
  });

  test('daily quote index wraps by day of year', () {
    expect(dailyQuoteIndex(DateTime(2026, 1, 1)), 1);
    expect(dailyQuoteIndex(DateTime(2026, 1, 31)), 1);
    expect(dailyQuotes.length, 30);
  });

  test('streak freeze use and reject when unavailable', () {
    final box = InMemoryHiveBox();
    final container = ProviderContainer(
      overrides: [appMetaBoxProvider.overrideWithValue(box)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(streakFreezeControllerProvider.notifier);
    expect(container.read(streakFreezeControllerProvider).freezesAvailable, 1);

    expect(notifier.useFreeze(), isTrue);
    expect(container.read(streakFreezeControllerProvider).isFrozen, isTrue);
    expect(container.read(streakFreezeControllerProvider).freezesAvailable, 0);

    expect(notifier.useFreeze(), isFalse);
  });

  group('BrainLevel thresholds', () {
    test('maps cumulative scores to levels', () {
      expect(BrainLevel.forScore(0), BrainLevel.level1);
      expect(BrainLevel.forScore(100), BrainLevel.level2);
      expect(BrainLevel.forScore(999), BrainLevel.level4);
      expect(BrainLevel.forScore(1000), BrainLevel.level5);
    });
  });

  group('weekly report messages', () {
    test('returns motivational copy by streak days', () {
      expect(
        weeklyReportMessage(streakDaysThisWeek: 5, isArabic: true),
        'أسبوع استثنائي 🏆',
      );
      expect(
        weeklyReportMessage(streakDaysThisWeek: 2, isArabic: true),
        'الأسبوع القادم أفضل 🌱',
      );
    });
  });
}

class _FakeWidgetRef implements WidgetRef {
  _FakeWidgetRef(this._container);

  final ProviderContainer _container;

  @override
  T read<T>(ProviderListenable<T> provider) => _container.read(provider);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
