import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../domain/purchases_sdk_port.dart';
import '../domain/subscription_plan.dart';

/// Production adapter over [Purchases] (never logs API keys).
class PurchasesFlutterSdkPort implements PurchasesSdkPort {
  bool _configured = false;
  void Function(StoreCustomerSnapshot info)? _listener;
  CustomerInfoUpdateListener? _nativeListener;
  final Map<String, Package> _packagesByProductId = {};

  @override
  bool get isConfigured => _configured;

  @override
  Future<void> configure({required String apiKey}) async {
    if (_configured) return;
    if (kIsWeb) {
      throw const StorePurchaseException(StorePurchaseFailureKind.notConfigured);
    }
    if (apiKey.isEmpty) {
      throw const StorePurchaseException(StorePurchaseFailureKind.notConfigured);
    }
    try {
      await Purchases.setLogLevel(
        kReleaseMode ? LogLevel.error : LogLevel.info,
      );
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _configured = true;
      _nativeListener = (info) {
        _listener?.call(_snapshot(info));
      };
      Purchases.addCustomerInfoUpdateListener(_nativeListener!);
    } catch (_) {
      _configured = false;
      throw const StorePurchaseException(StorePurchaseFailureKind.storeProblem);
    }
  }

  @override
  Future<StoreCustomerSnapshot> getCustomerInfo() async {
    _requireConfigured();
    try {
      final info = await Purchases.getCustomerInfo();
      return _snapshot(info);
    } catch (_) {
      throw const StorePurchaseException(StorePurchaseFailureKind.storeProblem);
    }
  }

  @override
  Future<List<StorePackageRef>> getCurrentOfferingPackages() async {
    _requireConfigured();
    _packagesByProductId.clear();
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return const [];
      final out = <StorePackageRef>[];
      for (final package in current.availablePackages) {
        final product = package.storeProduct;
        final productId = product.identifier;
        final period = StoreEntitlementEvaluator.periodForProductId(productId);
        if (period == null) continue; // ignore unknown
        _packagesByProductId[productId.split(':').first] = package;
        _packagesByProductId[productId] = package;

        final trial = _trialLabel(product);
        out.add(
          StorePackageRef(
            productId: productId.split(':').first,
            title: product.title.isNotEmpty ? product.title : productId,
            priceString: product.priceString,
            period: period,
            trialConfirmed: trial != null,
            trialLabel: trial,
            nativeHandle: package,
          ),
        );
      }
      return out;
    } catch (_) {
      throw const StorePurchaseException(StorePurchaseFailureKind.storeProblem);
    }
  }

  @override
  Future<StoreCustomerSnapshot> purchaseProductId(String productId) async {
    _requireConfigured();
    final package = _packagesByProductId[productId] ??
        _packagesByProductId[productId.split(':').first];
    if (package == null) {
      // Refresh offerings once.
      await getCurrentOfferingPackages();
    }
    final resolved = _packagesByProductId[productId] ??
        _packagesByProductId[productId.split(':').first];
    if (resolved == null) {
      throw const StorePurchaseException(StorePurchaseFailureKind.productNotFound);
    }
    try {
      final result = await Purchases.purchasePackage(resolved);
      return _snapshot(result);
    } on PlatformException catch (e) {
      throw StorePurchaseException(_mapPlatform(e), code: e.code);
    } catch (_) {
      throw const StorePurchaseException(StorePurchaseFailureKind.unknown);
    }
  }

  @override
  Future<StoreCustomerSnapshot> restorePurchases() async {
    _requireConfigured();
    try {
      final info = await Purchases.restorePurchases();
      return _snapshot(info);
    } on PlatformException catch (e) {
      throw StorePurchaseException(_mapPlatform(e), code: e.code);
    } catch (_) {
      throw const StorePurchaseException(StorePurchaseFailureKind.storeProblem);
    }
  }

  @override
  void setCustomerInfoListener(
    void Function(StoreCustomerSnapshot info)? listener,
  ) {
    _listener = listener;
  }

  @override
  void dispose() {
    if (_nativeListener != null) {
      Purchases.removeCustomerInfoUpdateListener(_nativeListener!);
      _nativeListener = null;
    }
    _listener = null;
  }

  void _requireConfigured() {
    if (!_configured) {
      throw const StorePurchaseException(StorePurchaseFailureKind.notConfigured);
    }
  }

  StoreCustomerSnapshot _snapshot(CustomerInfo info) {
    final ids = info.entitlements.active.keys.toList(growable: false);
    return StoreCustomerSnapshot(
      entitled: StoreEntitlementEvaluator.isEntitled(ids),
      activeEntitlementIds: ids,
    );
  }

  String? _trialLabel(StoreProduct product) {
    final intro = product.introductoryPrice;
    if (intro == null) return null;
    // Only confirm when store exposes intro/trial pricing.
    final cycles = intro.cycles;
    if (cycles <= 0) return null;
    return intro.priceString;
  }

  StorePurchaseFailureKind _mapPlatform(PlatformException e) {
    final code = PurchasesErrorHelper.getErrorCode(e);
    switch (code) {
      case PurchasesErrorCode.purchaseCancelledError:
        return StorePurchaseFailureKind.cancelled;
      case PurchasesErrorCode.paymentPendingError:
        return StorePurchaseFailureKind.pending;
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return StorePurchaseFailureKind.productNotFound;
      case PurchasesErrorCode.configurationError:
      case PurchasesErrorCode.storeProblemError:
      case PurchasesErrorCode.networkError:
        return StorePurchaseFailureKind.storeProblem;
      default:
        return StorePurchaseFailureKind.unknown;
    }
  }
}
