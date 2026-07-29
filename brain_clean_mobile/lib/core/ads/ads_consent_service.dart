import 'package:flutter/foundation.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_consent_gateway.dart';
import 'ads_service.dart';

/// Collects UMP consent on launch and gates Mobile Ads initialization.
abstract final class AdsConsentService {
  AdsConsentService._();

  static AdsConsentGateway _gateway = const GoogleMobileAdsConsentGateway();

  static bool _consentInfoUpdateCalled = false;
  static bool _canRequestAds = false;
  static PrivacyOptionsRequirementStatus _privacyOptionsRequirementStatus =
      PrivacyOptionsRequirementStatus.unknown;
  static Future<void>? _launchFlowFuture;

  /// Notifies UI when ads become eligible after consent completes.
  static final AdsConsentNotifier notifier = AdsConsentNotifier();

  @visibleForTesting
  static set gateway(AdsConsentGateway value) => _gateway = value;

  /// True only after [requestConsentInfoUpdate] completed (success or failure).
  static bool get consentInfoUpdateCalled => _consentInfoUpdateCalled;

  /// True only after consent update ran and UMP allows ad requests.
  static bool get canRequestAds => _consentInfoUpdateCalled && _canRequestAds;

  /// Whether Settings should show the privacy options entry.
  static bool get shouldShowPrivacyOptions =>
      _privacyOptionsRequirementStatus ==
      PrivacyOptionsRequirementStatus.required;

  /// Runs the launch consent flow once per process.
  static Future<void> runLaunchConsentFlow() {
    if (kIsWeb) {
      return Future<void>.value();
    }
    _launchFlowFuture ??= _runLaunchConsentFlow();
    return _launchFlowFuture!;
  }

  static Future<void> showPrivacyOptions() async {
    if (kIsWeb) return;
    try {
      await _gateway.showPrivacyOptionsForm();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AdsConsentService: privacy options failed — $error');
      }
    }
    await _refreshCanRequestAdsAfterUpdateAttempt();
    await _refreshPrivacyOptionsRequirementStatus();
    await _initializeAdsIfAllowed();
    notifier.notifyAdsStateChanged();
  }

  /// Debug-only consent reset for local UMP testing.
  static Future<void> debugResetConsent() async {
    assert(kDebugMode);
    if (kReleaseMode) return;
    await ConsentInformation.instance.reset();
    _consentInfoUpdateCalled = false;
    _canRequestAds = false;
    _privacyOptionsRequirementStatus =
        PrivacyOptionsRequirementStatus.unknown;
    _launchFlowFuture = null;
    AdsService.resetForTest();
    notifier.notifyAdsStateChanged();
  }

  @visibleForTesting
  static void resetForTest() {
    _gateway = const GoogleMobileAdsConsentGateway();
    _consentInfoUpdateCalled = false;
    _canRequestAds = false;
    _privacyOptionsRequirementStatus =
        PrivacyOptionsRequirementStatus.unknown;
    _launchFlowFuture = null;
    AdsService.resetForTest();
    notifier.notifyAdsStateChanged();
  }

  static Future<void> _runLaunchConsentFlow() async {
    try {
      await _requestConsentAndShowFormIfRequired();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AdsConsentService: consent update failed — $error');
      }
      await _refreshCanRequestAdsAfterUpdateAttempt();
    }

    await _refreshPrivacyOptionsRequirementStatus();
    await _initializeAdsIfAllowed();
    notifier.notifyAdsStateChanged();
  }

  static Future<void> _requestConsentAndShowFormIfRequired() async {
    _consentInfoUpdateCalled = true;
    final params = _buildConsentRequestParameters();
    await _gateway.requestConsentInfoUpdate(params);
    await _gateway.loadAndShowConsentFormIfRequired();
    await _refreshCanRequestAdsAfterUpdateAttempt();
  }

  static Future<void> _refreshCanRequestAdsAfterUpdateAttempt() async {
    if (!_consentInfoUpdateCalled) return;
    _canRequestAds = await _gateway.canRequestAds();
  }

  static Future<void> _refreshPrivacyOptionsRequirementStatus() async {
    if (!_consentInfoUpdateCalled) return;
    _privacyOptionsRequirementStatus =
        await _gateway.getPrivacyOptionsRequirementStatus();
  }

  static Future<void> _initializeAdsIfAllowed() async {
    if (!canRequestAds) return;
    await AdsService.initialize();
  }

  static ConsentRequestParameters _buildConsentRequestParameters() {
    if (kReleaseMode) {
      return ConsentRequestParameters(tagForUnderAgeOfConsent: false);
    }
    return _buildDebugConsentRequestParameters();
  }

  static ConsentRequestParameters _buildDebugConsentRequestParameters() {
    final debugGeography = _debugGeographyFromEnvironment();
    final testIdentifiers = _debugTestIdentifiersFromEnvironment();

    if (debugGeography == null && testIdentifiers == null) {
      return ConsentRequestParameters(tagForUnderAgeOfConsent: false);
    }

    return ConsentRequestParameters(
      tagForUnderAgeOfConsent: false,
      consentDebugSettings: ConsentDebugSettings(
        debugGeography: debugGeography,
        testIdentifiers: testIdentifiers,
      ),
    );
  }

  static DebugGeography? _debugGeographyFromEnvironment() {
    const value = String.fromEnvironment('ADS_CONSENT_DEBUG_GEOGRAPHY');
    return switch (value) {
      'eea' => DebugGeography.debugGeographyEea,
      'us' => DebugGeography.debugGeographyRegulatedUsState,
      'other' => DebugGeography.debugGeographyOther,
      _ => null,
    };
  }

  static List<String>? _debugTestIdentifiersFromEnvironment() {
    const raw = String.fromEnvironment('ADS_CONSENT_TEST_DEVICE_IDS');
    if (raw.trim().isEmpty) return null;
    final ids = raw
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    return ids.isEmpty ? null : ids;
  }
}

/// Notifies listeners when UMP consent / ads readiness changes.
final class AdsConsentNotifier extends ChangeNotifier {
  bool get adsReady =>
      AdsConsentService.canRequestAds && AdsService.isInitialized;

  void notifyAdsStateChanged() => notifyListeners();
}
