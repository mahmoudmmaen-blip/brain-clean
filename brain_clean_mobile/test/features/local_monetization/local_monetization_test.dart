import 'package:brain_clean_mobile/core/ads/ads_service.dart';
import 'package:brain_clean_mobile/core/config/ads_config.dart';
import 'package:brain_clean_mobile/core/constants/revenue_cat_constants.dart';
import 'package:brain_clean_mobile/core/services/purchases_service.dart';
import 'package:brain_clean_mobile/features/home/domain/daily_quotes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdsService', () {
    test('missing plugin path stays safe (no crash / not initialized)', () {
      expect(AdsService.isInitialized, isFalse);
      expect(AdsConfig.bannerAdUnitId, isNotEmpty);
      expect(AdsConfig.androidAppId, AdsConfig.androidTestAppId);
    });
  });

  group('RevenueCat alignment (Local Pro RC)', () {
    test('reads default offering id', () {
      expect(PurchasesService.offeringId, 'default');
      expect(
        PurchasesService.offeringId,
        RevenueCatConstants.defaultOfferingId,
      );
    });

    test('accepts both Brain Clean and pro entitlements', () {
      expect(
        RevenueCatConstants.acceptedProEntitlementIds,
        containsAll(<String>['pro', 'Brain Clean']),
      );
      expect(RevenueCatConstants.legacyProEntitlement, 'Brain Clean');
      expect(RevenueCatConstants.proEntitlement, 'pro');
      expect(PurchasesService.entitlementId, 'pro');
      expect(PurchasesService.legacyEntitlementId, 'Brain Clean');
    });

    test('expects monthly and annual product ids from live offering', () {
      expect(PurchasesService.monthlyProductId, 'brainclean_monthly');
      expect(PurchasesService.yearlyProductId, 'brainclean_yearly');
    });

    test('classifies Play base-plan product ids', () {
      expect(
        PurchasesService.isMonthlyProductIdentifier(
          'brainclean_monthly:monthly-autorenew',
        ),
        isTrue,
      );
      expect(
        PurchasesService.isAnnualProductIdentifier(
          'brainclean_yearly:yearly-autorenew',
        ),
        isTrue,
      );
      expect(
        PurchasesService.isLifetimeProductIdentifier(
          'brainclean_yearly:yearly-autorenew',
        ),
        isFalse,
      );
      expect(
        PurchasesService.isLifetimeProductIdentifier(
          'brainclean_monthly:monthly-autorenew',
        ),
        isFalse,
      );
      expect(
        PurchasesService.isLifetimeProductIdentifier('brainclean_lifetime'),
        isTrue,
      );
    });

    test('SDK stays unconfigured without key (no crash path)', () {
      expect(PurchasesService.isConfigured, isFalse);
    });
  });

  group('Pro quote pool', () {
    test('free pool is smaller than full library', () {
      expect(freeQuotePoolSize, lessThan(dailyQuotes.length));
      final freeQuote = quoteForDate(DateTime(2026, 6, 1), isPro: false);
      final proQuote = quoteForDate(DateTime(2026, 6, 1), isPro: true);
      expect(dailyQuotes.contains(freeQuote), isTrue);
      expect(dailyQuotes.contains(proQuote), isTrue);
    });
  });

  group('Silence Pro durations', () {
    test('free durations stay within 5–20 minutes', () {
      const free = <int>[5, 10, 15, 20];
      const proOnly = <int>[30, 45, 60];
      expect(free.every((m) => m <= 20), isTrue);
      expect(proOnly.every((m) => m >= 30), isTrue);
      expect(
        {...free}.intersection({...proOnly}),
        isEmpty,
      );
    });
  });
}
