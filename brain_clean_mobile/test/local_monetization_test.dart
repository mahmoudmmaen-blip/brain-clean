import 'package:brain_clean_mobile/core/ads/ad_visibility.dart';
import 'package:brain_clean_mobile/core/ads/ads_service.dart';
import 'package:brain_clean_mobile/core/ads/footer_banner_ad.dart';
import 'package:brain_clean_mobile/core/config/ads_config.dart';
import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/constants/revenue_cat_constants.dart';
import 'package:brain_clean_mobile/core/services/purchases_service.dart';
import 'package:brain_clean_mobile/features/home/domain/daily_quotes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  group('AdVisibility (Safe Footer Banner RC)', () {
    test('shows banner for free users on normal shell routes', () {
      for (final location in [
        AppRoutes.home,
        AppRoutes.exercises,
        AppRoutes.journey,
        AppRoutes.more,
        AppRoutes.settings,
      ]) {
        expect(
          AdVisibility.shouldShowFooterBanner(isPro: false, location: location),
          isTrue,
          reason: location,
        );
      }
    });

    test('hides banner for Pro users everywhere', () {
      for (final location in [
        AppRoutes.home,
        AppRoutes.exercises,
        AppRoutes.more,
      ]) {
        expect(
          AdVisibility.shouldShowFooterBanner(isPro: true, location: location),
          isFalse,
          reason: location,
        );
      }
    });

    test('hides banner on paywall, Safa, and focus flows', () {
      for (final location in [
        AppRoutes.proPaywall,
        AppRoutes.safa,
        '${AppRoutes.safa}/emotion-oasis',
        AppRoutes.singleTask,
        '/home/silence-challenge/3',
        AppRoutes.dailyProgram,
        AppRoutes.dayEnd,
        AppRoutes.sukoon,
        AppRoutes.pomodoro,
        AppRoutes.recovery,
        '${AppRoutes.exercises}/games',
      ]) {
        expect(
          AdVisibility.shouldShowFooterBanner(isPro: false, location: location),
          isFalse,
          reason: location,
        );
      }
    });
  });

  group('AdsConfig', () {
    test('defaults to Google test banner and app ids', () {
      expect(AdsConfig.androidBannerUnitId, AdsConfig.androidTestBannerUnitId);
      expect(AdsConfig.iosBannerUnitId, AdsConfig.iosTestBannerUnitId);
      expect(AdsConfig.androidAppId, AdsConfig.androidTestAppId);
      expect(AdsConfig.iosAppId, AdsConfig.iosTestAppId);
      expect(AdsConfig.bannerAdUnitId, isNotEmpty);
    });
  });

  group('FooterBannerAd layout', () {
    test('forces fixed AdSize.banner 320x50 only (no adaptive)', () {
      expect(FooterBannerAd.bannerWidth, 320);
      expect(FooterBannerAd.bannerHeight, 50);
      expect(FooterBannerAd.stripVerticalPadding, 0);
      expect(FooterBannerAd.reservedStripHeight, 50);
      expect(FooterBannerAd.fixedPhoneBanner.width, 320);
      expect(FooterBannerAd.fixedPhoneBanner.height, 50);
      expect(FooterBannerAd.fixedPhoneBanner.width, AdSize.banner.width);
      expect(FooterBannerAd.fixedPhoneBanner.height, AdSize.banner.height);
      // Explicitly not fullBanner (468×60) or largeBanner.
      expect(FooterBannerAd.fixedPhoneBanner.width, isNot(AdSize.fullBanner.width));
      expect(FooterBannerAd.fixedPhoneBanner.height, isNot(AdSize.fullBanner.height));
    });
  });

  group('AdsService', () {
    test('missing plugin path stays safe (no crash / not initialized)', () {
      // Unit tests have no native AdMob plugin; AdsService must remain false
      // and AdsConfig must still supply test IDs without throwing.
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
      // Widget/unit tests never call Purchases.configure with a real key.
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
