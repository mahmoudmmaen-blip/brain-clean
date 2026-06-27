import 'package:brain_clean_mobile/features/pro/data/local_subscription_service.dart';
import 'package:brain_clean_mobile/features/pro/domain/subscription_plan.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hive_test_fixtures.dart';

void main() {
  group('LocalSubscriptionService', () {
    test('defaults to free plan', () {
      final service = LocalSubscriptionService(InMemoryHiveBox());
      expect(service.currentPlan, SubscriptionPlan.free);
      expect(service.isPro, isFalse);
    });

    test('purchaseMonthly returns true and sets monthlyPro', () async {
      final service = LocalSubscriptionService(InMemoryHiveBox());
      final ok = await service.purchaseMonthly();
      expect(ok, isTrue);
      expect(service.currentPlan, SubscriptionPlan.monthlyPro);
      expect(service.isPro, isTrue);
    });

    test('purchaseAnnual returns true and sets annualPro', () async {
      final service = LocalSubscriptionService(InMemoryHiveBox());
      final ok = await service.purchaseAnnual();
      expect(ok, isTrue);
      expect(service.currentPlan, SubscriptionPlan.annualPro);
      expect(service.isPro, isTrue);
    });

    test('restorePurchases returns true when already pro', () async {
      final service = LocalSubscriptionService(InMemoryHiveBox());
      await service.purchaseMonthly();
      expect(await service.restorePurchases(), isTrue);
    });

    test('restorePurchases returns false when free', () async {
      final service = LocalSubscriptionService(InMemoryHiveBox());
      expect(await service.restorePurchases(), isFalse);
    });

    test('plan persists across instances sharing the same box', () async {
      final box = InMemoryHiveBox();
      await LocalSubscriptionService(box).purchaseAnnual();
      expect(
        LocalSubscriptionService(box).currentPlan,
        SubscriptionPlan.annualPro,
      );
    });
  });
}
