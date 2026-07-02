import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../domain/subscription_plan.dart';
import '../domain/subscription_service.dart';
import 'revenue_cat_bootstrap.dart';

/// Live RevenueCat-backed [SubscriptionService].
class RevenueCatSubscriptionService implements SubscriptionService {
  RevenueCatSubscriptionService(this._ref) {
    if (!RevenueCatBootstrap.isConfigured) return;
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    unawaited(_hydrate());
  }

  final Ref _ref;

  CustomerInfo? _customerInfo;
  List<SubscriptionPlan> _plans = const [];
  final Map<String, Package> _packagesByPlanId = {};
  bool _hydrating = false;

  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    _customerInfo = customerInfo;
    RevenueCatBootstrap.notifyEntitlementChanged();
  }

  Future<void> _hydrate() async {
    if (!RevenueCatBootstrap.isConfigured || _hydrating) return;
    _hydrating = true;
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      await _refreshOfferings();
      RevenueCatBootstrap.notifyCatalogChanged();
    } catch (e) {
      debugPrint('RevenueCat hydrate failed: $e');
    } finally {
      _hydrating = false;
    }
  }

  @override
  bool get isPro =>
      _customerInfo?.entitlements.active
          .containsKey(RevenueCatBootstrap.entitlementId) ??
      false;

  @override
  List<SubscriptionPlan> get plans => _plans;

  Future<void> _refreshOfferings() async {
    final offerings = await Purchases.getOfferings();
    final offering = offerings.getOffering(RevenueCatBootstrap.offeringId) ??
        offerings.current;
    if (offering == null) {
      _plans = const [];
      _packagesByPlanId.clear();
      return;
    }

    final plans = <SubscriptionPlan>[];
    final packages = <String, Package>{};

    for (final package in offering.availablePackages) {
      final period = _periodForPackage(package);
      if (period == null) continue;

      plans.add(
        SubscriptionPlan(
          id: package.identifier,
          title: _titleForPeriod(period),
          priceString: package.storeProduct.priceString,
          period: period,
        ),
      );
      packages[package.identifier] = package;
    }

    plans.sort((a, b) => _periodOrder(a.period).compareTo(_periodOrder(b.period)));

    _plans = List.unmodifiable(plans);
    _packagesByPlanId
      ..clear()
      ..addAll(packages);
  }

  int _periodOrder(SubscriptionPeriod period) => switch (period) {
        SubscriptionPeriod.monthly => 0,
        SubscriptionPeriod.annual => 1,
        SubscriptionPeriod.lifetime => 2,
      };

  SubscriptionPeriod? _periodForPackage(Package package) {
    return switch (package.packageType) {
      PackageType.monthly => SubscriptionPeriod.monthly,
      PackageType.annual => SubscriptionPeriod.annual,
      PackageType.lifetime => SubscriptionPeriod.lifetime,
      _ => null,
    };
  }

  String _titleForPeriod(SubscriptionPeriod period) {
    return switch (period) {
      SubscriptionPeriod.monthly => 'Monthly',
      SubscriptionPeriod.annual => 'Annual',
      SubscriptionPeriod.lifetime => 'Lifetime',
    };
  }

  @override
  Future<bool> purchase(String planId) async {
    if (!RevenueCatBootstrap.isConfigured) return false;

    var package = _packagesByPlanId[planId];
    if (package == null) {
      await _refreshOfferings();
      package = _packagesByPlanId[planId];
      if (package == null) return false;
    }

    try {
      final result = await Purchases.purchasePackage(package);
      _customerInfo = result.customerInfo;
      RevenueCatBootstrap.notifyEntitlementChanged();
      return isPro;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      debugPrint('RevenueCat purchase failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> restorePurchases() async {
    if (!RevenueCatBootstrap.isConfigured) return;

    try {
      final customerInfo = await Purchases.restorePurchases();
      _customerInfo = customerInfo;
      RevenueCatBootstrap.notifyEntitlementChanged();
    } catch (e) {
      debugPrint('RevenueCat restore failed: $e');
      rethrow;
    }
  }
}
