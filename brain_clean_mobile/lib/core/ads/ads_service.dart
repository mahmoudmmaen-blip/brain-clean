import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Initializes the Mobile Ads SDK once. Missing keys must never crash the app.
abstract final class AdsService {
  AdsService._();

  static bool isInitialized = false;

  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('AdsService: skipping on Web');
      return;
    }
    try {
      await MobileAds.instance.initialize();
      isInitialized = true;
      debugPrint('AdsService: Mobile Ads initialized');
    } catch (error, stackTrace) {
      debugPrint('AdsService: initialize failed — continuing without ads');
      debugPrint('$error');
      debugPrint('$stackTrace');
      isInitialized = false;
    }
  }
}
