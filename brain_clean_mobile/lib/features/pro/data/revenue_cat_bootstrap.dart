import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Early RevenueCat SDK setup — called from [main] before [runApp].
abstract final class RevenueCatBootstrap {
  static const entitlementId = 'pro';
  static const offeringId = 'default';

  static bool isConfigured = false;
  static Ref? _ref;
  static ProviderBase<Object?>? _isProProvider;
  static StateProvider<int>? _catalogVersionProvider;

  static void attach(
    Ref ref, {
    required ProviderBase<Object?> isProProvider,
    required StateProvider<int> catalogVersionProvider,
  }) {
    _ref = ref;
    _isProProvider = isProProvider;
    _catalogVersionProvider = catalogVersionProvider;
  }

  static void notifyEntitlementChanged() {
    if (_ref == null || _isProProvider == null) return;
    _ref!.invalidate(_isProProvider!);
  }

  static void notifyCatalogChanged() {
    if (_ref == null) return;
    if (_catalogVersionProvider != null) {
      _ref!.read(_catalogVersionProvider!.notifier).state++;
    }
    notifyEntitlementChanged();
  }

  static Future<void> initialize() async {
    final apiKey = dotenv.env['REVENUECAT_API_KEY']?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('REVENUECAT_API_KEY missing — RevenueCat SDK skipped.');
      return;
    }

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      await Purchases.configure(PurchasesConfiguration(apiKey));
      Purchases.addCustomerInfoUpdateListener((_) {
        notifyEntitlementChanged();
      });
      isConfigured = true;
    } catch (e) {
      debugPrint('RevenueCat configure failed: $e');
    }
  }
}
