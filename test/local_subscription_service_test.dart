import 'package:brain_clean_mobile/core/application/app_preferences_provider.dart';
import 'package:brain_clean_mobile/core/data/app_meta_box_provider.dart';
import 'package:brain_clean_mobile/features/pro/application/subscription_service_provider.dart';
import 'package:brain_clean_mobile/features/pro/domain/subscription_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hive_test_fixtures.dart';

ProviderContainer _container() {
  final container = ProviderContainer(
    overrides: [
      appMetaBoxProvider.overrideWithValue(InMemoryHiveBox()),
      appPreferencesProvider.overrideWith(_FreePreferences.new),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('LocalSubscriptionService', () {
    test('defaults to free (not Pro)', () {
      final c = _container();
      final service = c.read(subscriptionServiceProvider);
      expect(service.isPro, isFalse);
      expect(service.plans, isNotEmpty);
    });

    test('purchase monthly plan id returns true and sets Pro', () async {
      final c = _container();
      final service = c.read(subscriptionServiceProvider);
      final ok = await service.purchase('pro_monthly');
      expect(ok, isTrue);
      expect(c.read(subscriptionServiceProvider).isPro, isTrue);
    });

    test('purchase annual plan id returns true and sets Pro', () async {
      final c = _container();
      final service = c.read(subscriptionServiceProvider);
      final ok = await service.purchase('pro_annual');
      expect(ok, isTrue);
      expect(c.read(subscriptionServiceProvider).isPro, isTrue);
    });

    test('purchase rejects unknown plan id', () async {
      final c = _container();
      final ok = await c.read(subscriptionServiceProvider).purchase('nope');
      expect(ok, isFalse);
      expect(c.read(subscriptionServiceProvider).isPro, isFalse);
    });

    test('restorePurchases completes without throwing', () async {
      final c = _container();
      await c.read(subscriptionServiceProvider).purchase('pro_monthly');
      expect(c.read(subscriptionServiceProvider).isPro, isTrue);
      await expectLater(
        c.read(subscriptionServiceProvider).restorePurchases(),
        completes,
      );
    });

    test('plans expose monthly annual and lifetime periods', () {
      final c = _container();
      final periods =
          c.read(subscriptionServiceProvider).plans.map((p) => p.period).toSet();
      expect(periods, contains(SubscriptionPeriod.monthly));
      expect(periods, contains(SubscriptionPeriod.annual));
      expect(periods, contains(SubscriptionPeriod.lifetime));
    });
  });
}

class _FreePreferences extends AppPreferences {
  @override
  AppPreferencesState build() => const AppPreferencesState(
        hasSeenOnboarding: true,
        isProUser: false,
        emotionNotificationsEnabled: true,
        dailyFocusReminderEnabled: true,
        profileDisplayName: '',
        silenceWinsCount: 0,
        singleTasksCompletedCount: 0,
      );

  @override
  Future<void> setProUser(bool value) async {
    state = state.copyWith(isProUser: value);
  }
}
