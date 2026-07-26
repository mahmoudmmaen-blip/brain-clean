import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_config.dart';
import '../constants/revenue_cat_constants.dart';

part 'purchases_service.g.dart';

/// Which plan tile a RevenueCat [Package] maps to on the paywall.
enum PaywallPlanKind { monthly, annual, lifetime }

/// A purchasable package paired with its paywall kind.
class PaywallPlanEntry {
  const PaywallPlanEntry(this.package, this.kind);

  final Package package;
  final PaywallPlanKind kind;

  String get id => package.identifier;
}

/// RevenueCat integration for Brain Clean (Google Play).
///
/// Public SDK key comes from `--dart-define=REVENUECAT_API_KEY=...`
/// (preferred) or dotenv — never hardcode production keys in source.
class PurchasesService {
  const PurchasesService._();

  /// Preferred entitlement id (`pro`). Live dashboard still uses [legacy].
  static const entitlementId = RevenueCatConstants.proEntitlement;

  /// Live entitlement id (`Brain Clean`).
  static const legacyEntitlementId = RevenueCatConstants.legacyProEntitlement;

  /// Offering identifier configured in the RevenueCat dashboard.
  static const offeringId = RevenueCatConstants.defaultOfferingId;

  static const lifetimeProductId = RevenueCatConstants.lifetimeProductId;
  static const yearlyProductId = RevenueCatConstants.yearlyProductId;
  static const monthlyProductId = RevenueCatConstants.monthlyProductId;

  /// `true` once [initialize] has configured the SDK successfully. Stays
  /// `false` on platforms without the native SDK (e.g. widget tests).
  static bool isConfigured = false;

  /// Configures RevenueCat. Call once from `main`, before `runApp`.
  ///
  /// Skips Web and skips when the key is missing or a documentation
  /// placeholder. Missing key must never crash the app.
  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint(
        'PurchasesService: skipping configure on Web '
        '(Android/iOS public SDK key only)',
      );
      return;
    }

    final apiKey = AppConfig.revenueCatApiKey;
    if (!AppConfig.hasValidRevenueCatApiKey) {
      debugPrint(
        'PurchasesService: missing or placeholder REVENUECAT_API_KEY — '
        'skipping configure (pass via --dart-define for Play billing)',
      );
      return;
    }

    try {
      await Purchases.setLogLevel(
        kReleaseMode ? LogLevel.error : LogLevel.debug,
      );
      await Purchases.configure(PurchasesConfiguration(apiKey));
      isConfigured = true;
      debugPrint(
        'PurchasesService: configured '
        '(${AppConfig.configPresenceLabel(apiKey)})',
      );
    } catch (e) {
      debugPrint(
        'PurchasesService: configure failed — continuing without Pro SDK',
      );
      assert(() {
        debugPrint('PurchasesService: configure error detail: $e');
        return true;
      }());
    }
  }

  /// Whether [info] currently grants Brain Clean Pro.
  ///
  /// Accepts entitlement ids [entitlementId] (`pro`) and
  /// [legacyEntitlementId] (`Brain Clean`). Also treats a purchased lifetime
  /// SKU as Pro when present.
  static bool hasProEntitlement(CustomerInfo info) {
    final active = info.entitlements.active;
    for (final id in RevenueCatConstants.acceptedProEntitlementIds) {
      if (active.containsKey(id)) return true;
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
    if (id.startsWith(yearlyProductId.toLowerCase())) return false;
    if (id.startsWith(monthlyProductId.toLowerCase())) return false;
    return id == lifetimeProductId.toLowerCase() ||
        id.startsWith('${lifetimeProductId.toLowerCase()}:') ||
        id.contains('lifetime');
  }

  /// Whether [productId] matches the monthly subscription product.
  static bool isMonthlyProductIdentifier(String productId) {
    final id = productId.toLowerCase();
    return id == monthlyProductId.toLowerCase() ||
        id.startsWith('${monthlyProductId.toLowerCase()}:');
  }

  /// Whether [productId] matches the annual subscription product.
  static bool isAnnualProductIdentifier(String productId) {
    final id = productId.toLowerCase();
    return id == yearlyProductId.toLowerCase() ||
        id.startsWith('${yearlyProductId.toLowerCase()}:');
  }

  /// Whether [package] is the lifetime plan.
  static bool isLifetimePackage(Package package) {
    if (package.packageType == PackageType.lifetime) return true;
    return isLifetimeProductIdentifier(package.storeProduct.identifier);
  }

  /// Monthly package from [offering], if present.
  static Package? findMonthlyPackage(Offering offering) {
    final typed = offering.monthly;
    if (typed != null && !isLifetimePackage(typed)) return typed;

    for (final package in offering.availablePackages) {
      if (isLifetimePackage(package)) continue;
      if (package.packageType == PackageType.monthly) return package;
      if (isMonthlyProductIdentifier(package.storeProduct.identifier)) {
        return package;
      }
    }

    return offering.getPackage(r'$rc_monthly') ??
        offering.getPackage(monthlyProductId);
  }

  /// Annual package from [offering], if present (never lifetime).
  static Package? findAnnualPackage(Offering offering) {
    final typed = offering.annual;
    if (typed != null && !isLifetimePackage(typed)) return typed;

    for (final package in offering.availablePackages) {
      if (isLifetimePackage(package)) continue;
      if (package.packageType == PackageType.annual) return package;
      if (isAnnualProductIdentifier(package.storeProduct.identifier)) {
        return package;
      }
    }

    return offering.getPackage(r'$rc_annual') ??
        offering.getPackage(yearlyProductId);
  }

  /// Lifetime package only when it exists in [offering].
  ///
  /// Returns `null` for the current live default offering (monthly + annual).
  static Package? findLifetimePackage(Offering offering) {
    final typed = offering.lifetime;
    if (typed != null && isLifetimePackage(typed)) return typed;

    for (final package in offering.availablePackages) {
      if (isLifetimePackage(package)) return package;
    }

    return offering.getPackage(lifetimeProductId);
  }

  /// Paywall tiles for [offering]: monthly/annual when present; lifetime only
  /// when a distinct lifetime package is in the offering.
  static List<PaywallPlanEntry> paywallPlanEntries(Offering offering) {
    final entries = <PaywallPlanEntry>[];
    final seenIds = <String>{};

    void add(Package? package, PaywallPlanKind kind) {
      if (package == null) return;
      if (!seenIds.add(package.identifier)) return;
      entries.add(PaywallPlanEntry(package, kind));
    }

    add(findMonthlyPackage(offering), PaywallPlanKind.monthly);
    add(findAnnualPackage(offering), PaywallPlanKind.annual);
    add(findLifetimePackage(offering), PaywallPlanKind.lifetime);

    return entries;
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
