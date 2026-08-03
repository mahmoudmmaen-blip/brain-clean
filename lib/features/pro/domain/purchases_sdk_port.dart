import 'package:flutter/foundation.dart';

import '../../v2_premium/domain/premium_identifiers.dart';
import 'subscription_plan.dart';

/// Opaque store package handle for purchase.
@immutable
class StorePackageRef {
  const StorePackageRef({
    required this.productId,
    required this.title,
    required this.priceString,
    required this.period,
    this.trialConfirmed = false,
    this.trialLabel,
    this.nativeHandle,
  });

  final String productId;
  final String title;
  final String priceString;
  final SubscriptionPeriod period;
  final bool trialConfirmed;
  final String? trialLabel;

  /// SDK-specific package object (Package). Null in fakes / tests.
  final Object? nativeHandle;
}

/// Redacted CustomerInfo entitlement snapshot.
@immutable
class StoreCustomerSnapshot {
  const StoreCustomerSnapshot({
    required this.entitled,
    this.activeEntitlementIds = const [],
  });

  final bool entitled;
  final List<String> activeEntitlementIds;
}

/// Facade over purchases_flutter for production and deterministic tests.
abstract interface class PurchasesSdkPort {
  bool get isConfigured;

  Future<void> configure({required String apiKey});

  Future<StoreCustomerSnapshot> getCustomerInfo();

  Future<List<StorePackageRef>> getCurrentOfferingPackages();

  /// Purchase by product id. Throws [StorePurchaseException] on failure/cancel.
  Future<StoreCustomerSnapshot> purchaseProductId(String productId);

  Future<StoreCustomerSnapshot> restorePurchases();

  void setCustomerInfoListener(void Function(StoreCustomerSnapshot info)? listener);

  void dispose();
}

/// Typed store purchase failure without embedding secrets.
class StorePurchaseException implements Exception {
  const StorePurchaseException(this.kind, {this.code});

  final StorePurchaseFailureKind kind;
  final String? code;

  @override
  String toString() => 'StorePurchaseException($kind)';
}

enum StorePurchaseFailureKind {
  cancelled,
  pending,
  storeProblem,
  productNotFound,
  notConfigured,
  unknown,
}

/// Shared entitlement evaluation (Contract §4).
abstract final class StoreEntitlementEvaluator {
  static const primary = PremiumIdentifiers.entitlementId; // Brain Clean
  static const additivePro = 'pro';

  static bool isEntitled(Iterable<String> activeEntitlementIds) {
    for (final id in activeEntitlementIds) {
      if (id == primary || id == additivePro) return true;
    }
    return false;
  }

  static bool isProductionProductId(String productId) {
    final base = productId.split(':').first;
    return base == PremiumIdentifiers.monthlyProductId ||
        base == PremiumIdentifiers.yearlyProductId ||
        base == PremiumIdentifiers.lifetimeProductId;
  }

  static SubscriptionPeriod? periodForProductId(String productId) {
    final base = productId.split(':').first;
    if (base == PremiumIdentifiers.monthlyProductId) {
      return SubscriptionPeriod.monthly;
    }
    if (base == PremiumIdentifiers.yearlyProductId) {
      return SubscriptionPeriod.annual;
    }
    if (base == PremiumIdentifiers.lifetimeProductId) {
      return SubscriptionPeriod.lifetime;
    }
    return null;
  }
}
