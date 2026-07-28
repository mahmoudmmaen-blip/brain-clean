import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Test seam over google_mobile_ads UMP APIs.
abstract class AdsConsentGateway {
  Future<void> requestConsentInfoUpdate(ConsentRequestParameters params);

  Future<void> loadAndShowConsentFormIfRequired();

  Future<bool> canRequestAds();

  Future<PrivacyOptionsRequirementStatus> getPrivacyOptionsRequirementStatus();

  Future<void> showPrivacyOptionsForm();
}

/// Production UMP gateway backed by [ConsentInformation] / [ConsentForm].
final class GoogleMobileAdsConsentGateway implements AdsConsentGateway {
  const GoogleMobileAdsConsentGateway();

  @override
  Future<void> requestConsentInfoUpdate(ConsentRequestParameters params) {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      completer.complete,
      (FormError error) => completer.completeError(error),
    );
    return completer.future;
  }

  @override
  Future<void> loadAndShowConsentFormIfRequired() {
    final completer = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
      if (error != null) {
        completer.completeError(error);
      } else {
        completer.complete();
      }
    });
    return completer.future;
  }

  @override
  Future<bool> canRequestAds() {
    return ConsentInformation.instance.canRequestAds();
  }

  @override
  Future<PrivacyOptionsRequirementStatus>
      getPrivacyOptionsRequirementStatus() {
    return ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
  }

  @override
  Future<void> showPrivacyOptionsForm() {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((FormError? error) {
      if (error != null) {
        completer.completeError(error);
      } else {
        completer.complete();
      }
    });
    return completer.future;
  }
}
