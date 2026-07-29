import 'package:brain_clean_mobile/core/ads/ad_visibility.dart';
import 'package:brain_clean_mobile/core/ads/ads_consent_gateway.dart';
import 'package:brain_clean_mobile/core/ads/ads_consent_service.dart';
import 'package:brain_clean_mobile/core/ads/ads_service.dart';
import 'package:brain_clean_mobile/core/ads/footer_banner_ad.dart';
import 'package:brain_clean_mobile/core/config/ads_config.dart';
import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class FakeAdsConsentGateway implements AdsConsentGateway {
  FakeAdsConsentGateway({
    this.updateShouldFail = false,
    this.formShouldFail = false,
    this.canRequestAdsResult = false,
    this.privacyOptionsRequirementStatus =
        PrivacyOptionsRequirementStatus.notRequired,
    this.updateDelay = Duration.zero,
  });

  bool updateShouldFail;
  bool formShouldFail;
  bool canRequestAdsResult;
  PrivacyOptionsRequirementStatus privacyOptionsRequirementStatus;
  Duration updateDelay;

  int requestConsentInfoUpdateCalls = 0;
  int loadAndShowConsentFormIfRequiredCalls = 0;
  int canRequestAdsCalls = 0;
  int showPrivacyOptionsFormCalls = 0;
  ConsentRequestParameters? lastParams;

  @override
  Future<void> requestConsentInfoUpdate(ConsentRequestParameters params) async {
    requestConsentInfoUpdateCalls++;
    lastParams = params;
    if (updateDelay > Duration.zero) {
      await Future<void>.delayed(updateDelay);
    }
    if (updateShouldFail) {
      throw FormError(errorCode: 1, message: 'update failed');
    }
  }

  @override
  Future<void> loadAndShowConsentFormIfRequired() async {
    loadAndShowConsentFormIfRequiredCalls++;
    if (formShouldFail) {
      throw FormError(errorCode: 2, message: 'form failed');
    }
  }

  @override
  Future<bool> canRequestAds() async {
    canRequestAdsCalls++;
    return canRequestAdsResult;
  }

  @override
  Future<PrivacyOptionsRequirementStatus>
      getPrivacyOptionsRequirementStatus() async {
    return privacyOptionsRequirementStatus;
  }

  @override
  Future<void> showPrivacyOptionsForm() async {
    showPrivacyOptionsFormCalls++;
  }
}

void main() {
  setUp(() {
    AdsConsentService.resetForTest();
    AdsService.resetForTest();
  });

  group('AdsConsentService launch flow', () {
    test('waits for consent info update before allowing ads', () async {
      final gateway = FakeAdsConsentGateway(
        updateDelay: const Duration(milliseconds: 20),
        canRequestAdsResult: true,
      );
      AdsConsentService.gateway = gateway;

      expect(AdsConsentService.canRequestAds, isFalse);

      final flow = AdsConsentService.runLaunchConsentFlow();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(gateway.requestConsentInfoUpdateCalls, 1);
      expect(gateway.loadAndShowConsentFormIfRequiredCalls, 0);
      expect(AdsConsentService.canRequestAds, isFalse);

      await flow;
      expect(gateway.loadAndShowConsentFormIfRequiredCalls, 1);
      expect(AdsConsentService.canRequestAds, isTrue);
    });

    test('runs required consent form after successful update', () async {
      final gateway = FakeAdsConsentGateway(canRequestAdsResult: true);
      AdsConsentService.gateway = gateway;

      await AdsConsentService.runLaunchConsentFlow();

      expect(gateway.requestConsentInfoUpdateCalls, 1);
      expect(gateway.loadAndShowConsentFormIfRequiredCalls, 1);
      expect(gateway.canRequestAdsCalls, greaterThan(0));
    });

    test('skips ad init when consent is not required and ads cannot load',
        () async {
      final gateway = FakeAdsConsentGateway(canRequestAdsResult: false);
      AdsConsentService.gateway = gateway;

      await AdsConsentService.runLaunchConsentFlow();

      expect(gateway.loadAndShowConsentFormIfRequiredCalls, 1);
      expect(AdsConsentService.canRequestAds, isFalse);
      expect(AdsService.isInitialized, isFalse);
    });

    test('uses previous valid consent when update fails', () async {
      final gateway = FakeAdsConsentGateway(
        updateShouldFail: true,
        canRequestAdsResult: true,
      );
      AdsConsentService.gateway = gateway;

      await AdsConsentService.runLaunchConsentFlow();

      expect(gateway.requestConsentInfoUpdateCalls, 1);
      expect(gateway.loadAndShowConsentFormIfRequiredCalls, 0);
      expect(AdsConsentService.consentInfoUpdateCalled, isTrue);
      expect(AdsConsentService.canRequestAds, isTrue);
    });

    test('does not allow ads when update fails and no valid consent exists',
        () async {
      final gateway = FakeAdsConsentGateway(
        updateShouldFail: true,
        canRequestAdsResult: false,
      );
      AdsConsentService.gateway = gateway;

      await AdsConsentService.runLaunchConsentFlow();

      expect(AdsConsentService.canRequestAds, isFalse);
      expect(AdsService.isInitialized, isFalse);
    });

    test('does not check canRequestAds before consent info update', () {
      expect(AdsConsentService.canRequestAds, isFalse);
      expect(AdsConsentService.consentInfoUpdateCalled, isFalse);
    });

    test('deduplicates launch consent flow', () async {
      final gateway = FakeAdsConsentGateway(canRequestAdsResult: true);
      AdsConsentService.gateway = gateway;

      await Future.wait([
        AdsConsentService.runLaunchConsentFlow(),
        AdsConsentService.runLaunchConsentFlow(),
      ]);

      expect(gateway.requestConsentInfoUpdateCalls, 1);
    });
  });

  group('AdsService initialization', () {
    test('prevents duplicate MobileAds initialization', () async {
      var initializeCalls = 0;
      AdsService.initializeDelegate = () async {
        initializeCalls++;
      };

      await Future.wait([
        AdsService.initialize(),
        AdsService.initialize(),
        AdsService.initialize(),
      ]);

      expect(initializeCalls, 1);
      expect(AdsService.isInitialized, isTrue);
    });
  });

  group('Privacy options', () {
    test('shows privacy options only when required', () async {
      final gateway = FakeAdsConsentGateway(
        canRequestAdsResult: true,
        privacyOptionsRequirementStatus:
            PrivacyOptionsRequirementStatus.required,
      );
      AdsConsentService.gateway = gateway;

      await AdsConsentService.runLaunchConsentFlow();
      expect(AdsConsentService.shouldShowPrivacyOptions, isTrue);
    });

    test('hides privacy options when not required', () async {
      final gateway = FakeAdsConsentGateway(
        canRequestAdsResult: true,
        privacyOptionsRequirementStatus:
            PrivacyOptionsRequirementStatus.notRequired,
      );
      AdsConsentService.gateway = gateway;

      await AdsConsentService.runLaunchConsentFlow();
      expect(AdsConsentService.shouldShowPrivacyOptions, isFalse);
    });

    test('opens privacy options form on user action', () async {
      final gateway = FakeAdsConsentGateway(
        canRequestAdsResult: true,
        privacyOptionsRequirementStatus:
            PrivacyOptionsRequirementStatus.required,
      );
      AdsConsentService.gateway = gateway;

      await AdsConsentService.runLaunchConsentFlow();
      await AdsConsentService.showPrivacyOptions();

      expect(gateway.showPrivacyOptionsFormCalls, 1);
    });
  });

  group('AdVisibility with consent gating', () {
    test('Pro users remain ad-free regardless of consent', () {
      expect(
        AdVisibility.shouldShowFooterBanner(
          isPro: true,
          location: AppRoutes.home,
        ),
        isFalse,
      );
    });

    test('sensitive routes remain ad-free regardless of consent', () {
      for (final location in [
        AppRoutes.proPaywall,
        AppRoutes.safa,
        AppRoutes.dailyProgram,
        AppRoutes.dayEnd,
        AppRoutes.singleTask,
        '/home/silence-challenge/3',
        AppRoutes.sukoon,
        AppRoutes.recovery,
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
      expect(
        FooterBannerAd.fixedPhoneBanner.width,
        isNot(AdSize.fullBanner.width),
      );
      expect(
        FooterBannerAd.fixedPhoneBanner.height,
        isNot(AdSize.fullBanner.height),
      );
    });
  });
}
