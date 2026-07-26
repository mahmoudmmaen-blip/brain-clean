import 'package:brain_clean_mobile/core/ads/ad_visibility.dart';
import 'package:brain_clean_mobile/core/config/ads_config.dart';
import 'package:brain_clean_mobile/core/constants/revenue_cat_constants.dart';
import 'package:brain_clean_mobile/features/home/domain/daily_quotes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdVisibility', () {
    test('hides ads for Pro users everywhere', () {
      expect(
        AdVisibility.shouldShowFooterBanner(
          isPro: true,
          location: '/home',
        ),
        isFalse,
      );
    });

    test('hides ads on focus routes for free users', () {
      for (final location in [
        '/home/silence-challenge/3',
        '/home/single-task',
        '/daily-program',
        '/day-end',
        '/sukoon',
      ]) {
        expect(
          AdVisibility.shouldShowFooterBanner(
            isPro: false,
            location: location,
          ),
          isFalse,
          reason: location,
        );
      }
    });

    test('shows ads on shell tabs for free users', () {
      expect(
        AdVisibility.shouldShowFooterBanner(
          isPro: false,
          location: '/home',
        ),
        isTrue,
      );
      expect(
        AdVisibility.shouldShowFooterBanner(
          isPro: false,
          location: '/more',
        ),
        isTrue,
      );
    });
  });

  group('AdsConfig', () {
    test('defaults to Google test banner unit ids', () {
      expect(AdsConfig.androidBannerUnitId, AdsConfig.androidTestBannerUnitId);
      expect(AdsConfig.iosBannerUnitId, AdsConfig.iosTestBannerUnitId);
      expect(AdsConfig.androidAppId, AdsConfig.androidTestAppId);
    });
  });

  group('RevenueCat entitlement ids', () {
    test('canonical entitlement is pro with legacy alias', () {
      expect(RevenueCatConstants.proEntitlement, 'pro');
      expect(RevenueCatConstants.legacyProEntitlement, 'Brain Clean');
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
}
