import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/revenue_cat_constants.dart';

part 'purchases_service.g.dart';

/// RevenueCat integration for Brain Clean (Google Play, production).
///
/// Holds the SDK configuration constants and the one-shot [initialize] call
/// that must run from `main` before `runApp`.
class PurchasesService {
  const PurchasesService._();

  /// Public SDK key (Google Play, production).
  static const _apiKey = 'goog_RJESzENrLajTmowuJXBVoBKTpgE';

  /// Entitlement identifier configured in the RevenueCat dashboard.
  static const entitlementId = RevenueCatConstants.proEntitlement;

  /// Offering identifier configured in the RevenueCat dashboard.
  static const offeringId = 'default';

  /// Google Play / RevenueCat product id for one-time Pro lifetime access.
  static const lifetimeProductId = RevenueCatConstants.lifetimeProductId;

  /// `true` once [initialize] has configured the SDK successfully. Stays
  /// `false` on platforms without the native SDK (e.g. widget tests).
  static bool isConfigured = false;

  /// Configures RevenueCat. Call once from `main`, before `runApp`.
  static Future<void> initialize() async {
    try {
      await Purchases.setLogLevel(
        kReleaseMode ? LogLevel.error : LogLevel.debug,
      );
      await Purchases.configure(PurchasesConfiguration(_apiKey));
      isConfigured = true;
    } catch (e) {
      debugPrint('RevenueCat configure failed: $e');
    }
  }

  /// Whether [info] currently grants the Brain Clean Pro entitlement.
  ///
  /// Checks the active entitlement first, then lifetime one-time purchases
  /// (non-consumable) when the dashboard product type was misconfigured.
  static bool hasProEntitlement(CustomerInfo info) {
    if (info.entitlements.active.containsKey(entitlementId)) {
      return true;
    }

    for (final productId in info.allPurchasedProductIdentifiers) {
      if (isLifetimeProductIdentifier(productId)) return true;
    }

    for (final tx in info.nonSubscriptionTransactions) {
      if (isLifetimeProductIdentifier(tx.productIdentifier)) return true;
    }

    return false;
  }

  /// Whether [productId] refers to the lifetime Pro SKU.
  static bool isLifetimeProductIdentifier(String productId) {
    final id = productId.toLowerCase();
    return id == lifetimeProductId.toLowerCase() || id.contains('lifetime');
  }

  /// Whether [package] is the lifetime plan — supports [PackageType.lifetime]
  /// and misconfigured subscription/custom slots that still map to lifetime.
  static bool isLifetimePackage(Package package) {
    if (package.packageType == PackageType.lifetime) return true;

    final packageId = package.identifier.toLowerCase();
    final productId = package.storeProduct.identifier.toLowerCase();

    if (productId == lifetimeProductId.toLowerCase()) return true;

    if (package.packageType == PackageType.annual &&
        (packageId.contains('lifetime') || productId.contains('lifetime'))) {
      return true;
    }

    if ((package.packageType == PackageType.custom ||
            package.packageType == PackageType.unknown) &&
        (packageId.contains('lifetime') || productId.contains('lifetime'))) {
      return true;
    }

    return false;
  }

  /// Resolves the lifetime [Package] from an [Offering], including mis-typed SKUs.
  static Package? findLifetimePackage(Offering offering) {
    final lifetime = offering.lifetime;
    if (lifetime != null && isLifetimePackage(lifetime)) return lifetime;

    for (final package in offering.availablePackages) {
      if (isLifetimePackage(package)) return package;
    }

    final annual = offering.annual;
    if (annual != null && isLifetimePackage(annual)) return annual;

    return offering.getPackage(lifetimeProductId);
  }
}

/// Live Pro entitlement — emits `true`/`false` and updates in real time when
/// the user purchases, restores, or the subscription expires.
///
/// Seeds from [Purchases.getCustomerInfo] and then follows
/// [Purchases.addCustomerInfoUpdateListener]. Emits `false` when the SDK is not
/// configured so gates fail closed without touching native code.
@Riverpod(keepAlive: true)
Stream<bool> entitlementStatus(EntitlementStatusRef ref) {
  final controller = StreamController<bool>();

  if (!PurchasesService.isConfigured) {
    controller.add(false);
    ref.onDispose(controller.close);
    return controller.stream;
  }

  void onCustomerInfo(CustomerInfo info) {
    if (!controller.isClosed) {
      controller.add(PurchasesService.hasProEntitlement(info));
    }
  }

  Purchases.addCustomerInfoUpdateListener(onCustomerInfo);

  Purchases.getCustomerInfo().then(
    (info) {
      if (!controller.isClosed) {
        controller.add(PurchasesService.hasProEntitlement(info));
      }
    },
    onError: (Object e) {
      debugPrint('RevenueCat getCustomerInfo failed: $e');
      if (!controller.isClosed) controller.add(false);
    },
  );

  ref.onDispose(() {
    Purchases.removeCustomerInfoUpdateListener(onCustomerInfo);
    controller.close();
  });

  return controller.stream;
}

/// The current ("default") offering, or `null` when unavailable (SDK not
/// configured, offline, or nothing configured in the dashboard).
@riverpod
Future<Offering?> proOffering(ProOfferingRef ref) async {
  if (!PurchasesService.isConfigured) return null;
  final offerings = await Purchases.getOfferings();
  return offerings.getOffering(PurchasesService.offeringId) ??
      offerings.current;
}
