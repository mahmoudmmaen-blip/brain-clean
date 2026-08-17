import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/hive_meta_keys.dart';
import '../domain/purchases_sdk_port.dart';
import '../domain/subscription_adapter_kind.dart';
import '../domain/subscription_outcomes.dart';
import '../domain/subscription_plan.dart';
import '../domain/subscription_service.dart';

/// Production RevenueCat-backed subscription adapter.
class RevenueCatSubscriptionService implements SubscriptionService {
  RevenueCatSubscriptionService({
    required PurchasesSdkPort sdk,
    required String Function() apiKeyReader,
    Future<void> Function(bool entitled)? mirrorStoreVerified,
    bool Function()? readStoreVerifiedMirror,
    bool Function()? isOnline,
  })  : _sdk = sdk,
        _apiKeyReader = apiKeyReader,
        _mirrorStoreVerified = mirrorStoreVerified,
        _readStoreVerifiedMirror = readStoreVerifiedMirror,
        _isOnline = isOnline ?? (() => true);

  final PurchasesSdkPort _sdk;
  final String Function() _apiKeyReader;
  final Future<void> Function(bool entitled)? _mirrorStoreVerified;
  final bool Function()? _readStoreVerifiedMirror;
  final bool Function() _isOnline;

  bool _initStarted = false;
  bool _initSucceeded = false;
  bool _verifiedEntitled = false;
  bool _inflightPurchase = false;
  bool _inflightRestore = false;
  List<SubscriptionPlan> _plans = const [];

  @override
  SubscriptionAdapterKind get adapterKind => SubscriptionAdapterKind.revenueCat;

  @override
  bool get isStoreConfigured => _initSucceeded && _sdk.isConfigured;

  @override
  bool get isPro {
    if (_initSucceeded) return _verifiedEntitled;
    // Offline / pre-init: only honor store-verified mirror (never Hive-only grant).
    return _readStoreVerifiedMirror?.call() ?? false;
  }

  @override
  List<SubscriptionPlan> get plans => List.unmodifiable(_plans);

  @override
  Future<void> ensureInitialized() async {
    if (_initSucceeded) return;
    if (_initStarted && !_initSucceeded) {
      // Prior failure — retry allowed once path clears.
    }
    _initStarted = true;
    final key = _apiKeyReader();
    if (key.isEmpty) {
      _initSucceeded = false;
      debugPrint(AppConfig.revenueCatInitLogLine(configured: false));
      return;
    }
    try {
      await _sdk.configure(apiKey: key);
      _sdk.setCustomerInfoListener((snap) {
        _applySnapshot(snap);
      });
      final info = await _sdk.getCustomerInfo();
      await _applySnapshot(info);
      _initSucceeded = true;
      debugPrint(AppConfig.revenueCatInitLogLine(configured: true));
    } catch (_) {
      _initSucceeded = false;
      debugPrint(AppConfig.revenueCatInitLogLine(configured: false));
    }
  }

  @override
  Future<List<SubscriptionPlan>> loadOfferings() async {
    await ensureInitialized();
    if (!_initSucceeded) {
      _plans = const [];
      return _plans;
    }
    if (!_isOnline()) {
      return _plans;
    }
    try {
      final packages = await _sdk.getCurrentOfferingPackages();
      _plans = packages
          .map(
            (p) => SubscriptionPlan(
              id: p.productId,
              title: p.title,
              priceString: p.priceString,
              period: p.period,
            ),
          )
          .toList(growable: false);
      return _plans;
    } catch (_) {
      _plans = const [];
      rethrow;
    }
  }

  @override
  Future<SubscriptionPurchaseResult> purchasePlan(String planId) async {
    await ensureInitialized();
    if (!_initSucceeded) return SubscriptionPurchaseResult.storeUnavailable;
    if (_verifiedEntitled) return SubscriptionPurchaseResult.alreadyEntitled;
    if (_inflightPurchase) return SubscriptionPurchaseResult.failed;
    _inflightPurchase = true;
    try {
      if (_plans.every((p) => p.id != planId)) {
        await loadOfferings();
      }
      if (_plans.every((p) => p.id != planId)) {
        return SubscriptionPurchaseResult.failed;
      }
      final snap = await _sdk.purchaseProductId(planId);
      await _applySnapshot(snap);
      if (snap.entitled) return SubscriptionPurchaseResult.success;
      return SubscriptionPurchaseResult.failed;
    } on StorePurchaseException catch (e) {
      return switch (e.kind) {
        StorePurchaseFailureKind.cancelled =>
          SubscriptionPurchaseResult.cancelled,
        StorePurchaseFailureKind.pending => SubscriptionPurchaseResult.pending,
        StorePurchaseFailureKind.notConfigured =>
          SubscriptionPurchaseResult.storeUnavailable,
        _ => SubscriptionPurchaseResult.failed,
      };
    } catch (_) {
      return SubscriptionPurchaseResult.failed;
    } finally {
      _inflightPurchase = false;
    }
  }

  @override
  Future<SubscriptionRestoreResult> restoreEntitlements() async {
    await ensureInitialized();
    if (!_initSucceeded) return SubscriptionRestoreResult.failed;
    if (_inflightRestore) {
      return _verifiedEntitled
          ? SubscriptionRestoreResult.restored
          : SubscriptionRestoreResult.nothingToRestore;
    }
    _inflightRestore = true;
    try {
      final snap = await _sdk.restorePurchases();
      await _applySnapshot(snap);
      return snap.entitled
          ? SubscriptionRestoreResult.restored
          : SubscriptionRestoreResult.nothingToRestore;
    } catch (_) {
      return SubscriptionRestoreResult.failed;
    } finally {
      _inflightRestore = false;
    }
  }

  @override
  Future<bool> purchase(String planId) async {
    final r = await purchasePlan(planId);
    return r == SubscriptionPurchaseResult.success ||
        r == SubscriptionPurchaseResult.alreadyEntitled;
  }

  @override
  Future<void> restorePurchases() async {
    await restoreEntitlements();
  }

  Future<void> _applySnapshot(StoreCustomerSnapshot snap) async {
    _verifiedEntitled = snap.entitled;
    final mirror = _mirrorStoreVerified;
    if (mirror != null) {
      await mirror(snap.entitled);
    }
  }

  /// Hive key used for store-verified mirror.
  static const storeVerifiedMetaKey = HiveMetaKeys.storeVerifiedPremium;
}
