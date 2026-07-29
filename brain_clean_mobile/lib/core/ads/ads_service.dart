import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Initializes the Mobile Ads SDK once after UMP consent allows ad requests.
abstract final class AdsService {
  AdsService._();

  static bool isInitialized = false;
  static Future<void>? _initializeFuture;

  /// Test seam — replaces [MobileAds.instance.initialize] in unit tests.
  @visibleForTesting
  static Future<void> Function()? initializeDelegate;

  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('AdsService: skipping on Web');
      return;
    }
    if (isInitialized) return;
    _initializeFuture ??= _initializeOnce();
    await _initializeFuture;
  }

  static Future<void> _initializeOnce() async {
    if (isInitialized) return;
    try {
      if (initializeDelegate != null) {
        await initializeDelegate!();
      } else {
        await MobileAds.instance.initialize();
      }
      isInitialized = true;
      debugPrint('AdsService: Mobile Ads initialized');
    } catch (error, stackTrace) {
      debugPrint('AdsService: initialize failed — continuing without ads');
      debugPrint('$error');
      debugPrint('$stackTrace');
      isInitialized = false;
      _initializeFuture = null;
    }
  }

  @visibleForTesting
  static void resetForTest() {
    isInitialized = false;
    _initializeFuture = null;
    initializeDelegate = null;
  }
}
