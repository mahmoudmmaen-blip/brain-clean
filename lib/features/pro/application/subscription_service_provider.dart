import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/hive_meta_keys.dart';
import '../../../core/data/app_meta_box_provider.dart';
import '../data/local_subscription_service.dart';
import '../data/purchases_flutter_sdk_port.dart';
import '../data/revenuecat_subscription_service.dart';
import '../data/store_unavailable_subscription_service.dart';
import '../domain/purchases_sdk_port.dart';
import '../domain/subscription_adapter_kind.dart';
import '../domain/subscription_service.dart';

part 'subscription_service_provider.g.dart';

/// When true, force the local fake adapter (tests / explicit debug only).
///
/// Production must leave this false so LocalSubscriptionService cannot silently
/// become the production grant path.
final forceLocalSubscriptionAdapterProvider = Provider<bool>((ref) => false);

/// Injectable SDK port (tests override with [FakePurchasesSdkPort]).
final purchasesSdkPortProvider = Provider<PurchasesSdkPort?>((ref) => null);

/// When non-null/non-empty, overrides platform key resolution (tests only).
final revenueCatApiKeyOverrideProvider = Provider<String?>((ref) => null);

/// Optional platform override for key selection in tests (`true` = iOS).
final revenueCatPlatformIsIosProvider = Provider<bool?>((ref) => null);

@Riverpod(keepAlive: true)
SubscriptionService subscriptionService(SubscriptionServiceRef ref) {
  final forceLocal = ref.watch(forceLocalSubscriptionAdapterProvider);
  if (forceLocal) {
    return LocalSubscriptionService(ref);
  }

  final isIos = ref.watch(revenueCatPlatformIsIosProvider) ??
      (!kIsWeb && Platform.isIOS);
  final overrideKey = ref.watch(revenueCatApiKeyOverrideProvider);
  final key = (overrideKey != null && overrideKey.isNotEmpty)
      ? overrideKey
      : AppConfig.revenueCatPublicSdkKey(isIOS: isIos);
  if (key.isEmpty) {
    return StoreUnavailableSubscriptionService(
      readStoreVerifiedMirror: () => _readStoreVerified(ref),
    );
  }

  final sdk = ref.watch(purchasesSdkPortProvider) ?? PurchasesFlutterSdkPort();
  final resolvedKey = key;
  final service = RevenueCatSubscriptionService(
    sdk: sdk,
    apiKeyReader: () => resolvedKey,
    readStoreVerifiedMirror: () => _readStoreVerified(ref),
    mirrorStoreVerified: (entitled) => _mirrorStoreVerified(ref, entitled),
  );
  ref.onDispose(sdk.dispose);
  return service;
}

bool _readStoreVerified(Ref ref) {
  try {
    final box = ref.read(appMetaBoxProvider);
    return box.get(HiveMetaKeys.storeVerifiedPremium, defaultValue: false) ==
        true;
  } catch (_) {
    return false;
  }
}

Future<void> _mirrorStoreVerified(Ref ref, bool entitled) async {
  try {
    final box = ref.read(appMetaBoxProvider);
    await box.put(HiveMetaKeys.storeVerifiedPremium, entitled);
  } catch (_) {}
  try {
    await ref.read(appPreferencesProvider.notifier).setProUser(entitled);
  } catch (_) {}
}

/// Reactive Premium entitlement from the selected [SubscriptionService].
///
/// Production authority is RevenueCat / store-verified mirror — never Hive-only
/// when the production adapters are selected.
@riverpod
bool isProUser(IsProUserRef ref) {
  final service = ref.watch(subscriptionServiceProvider);
  if (service.adapterKind == SubscriptionAdapterKind.localFake) {
    ref.watch(appPreferencesProvider);
  }
  return service.isPro;
}
