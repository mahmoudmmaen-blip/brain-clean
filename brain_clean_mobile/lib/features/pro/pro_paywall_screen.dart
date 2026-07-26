import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/services/purchases_service.dart';

const proPaywallKey = Key('pro_paywall_screen');
const proSubscribeKey = Key('pro_subscribe_button');
const proRestoreKey = Key('pro_restore_button');
const proPlanTileKeyPrefix = 'pro_plan_tile_';

/// Which RevenueCat package a tile represents (drives its label/badge).
enum _PlanKind { monthly, annual, lifetime }

/// A purchasable package paired with its display kind.
class _PlanEntry {
  const _PlanEntry(this.package, this.kind);

  final Package package;
  final _PlanKind kind;

  String get id => package.identifier;
  String get priceString => package.storeProduct.priceString;
}

String _planTitle(AppLocalizations loc, _PlanKind kind) {
  return switch (kind) {
    _PlanKind.monthly => loc.proPlanMonthly,
    _PlanKind.annual => loc.proPlanAnnual,
    _PlanKind.lifetime => loc.proPlanLifetime,
  };
}

/// Builds monthly/annual/lifetime entries from the current [offering].
List<_PlanEntry> _entriesFor(Offering offering) {
  final entries = <_PlanEntry>[];
  final seenIds = <String>{};

  void add(Package package, _PlanKind kind) {
    if (seenIds.add(package.identifier)) {
      entries.add(_PlanEntry(package, kind));
    }
  }

  final monthly = offering.monthly;
  if (monthly != null) add(monthly, _PlanKind.monthly);

  final annual = offering.annual;
  if (annual != null && !PurchasesService.isLifetimePackage(annual)) {
    add(annual, _PlanKind.annual);
  }

  final lifetime = PurchasesService.findLifetimePackage(offering);
  if (lifetime != null) add(lifetime, _PlanKind.lifetime);

  return entries;
}

class ProPaywallScreen extends ConsumerStatefulWidget {
  const ProPaywallScreen({super.key});

  @override
  ConsumerState<ProPaywallScreen> createState() => _ProPaywallScreenState();
}

class _ProPaywallScreenState extends ConsumerState<ProPaywallScreen> {
  String? _selectedPlanId;
  bool _busy = false;

  String? _defaultPlanId(List<_PlanEntry> entries) {
    if (entries.isEmpty) return null;
    final annual = entries.firstWhere(
      (e) => e.kind == _PlanKind.annual,
      orElse: () => entries.first,
    );
    return annual.id;
  }

  Future<void> _purchase(Package package) async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final result = await Purchases.purchasePackage(package);
      if (!mounted) return;
      if (PurchasesService.hasProEntitlement(result.customerInfo)) {
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.proWelcomeSnack),
            backgroundColor: colorScheme.primary,
          ),
        );
        context.pop();
      }
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) return;
      if (!mounted) return;
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.proPurchaseError),
          backgroundColor: colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final info = await Purchases.restorePurchases();
      if (!mounted) return;
      final restored = PurchasesService.hasProEntitlement(info);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(restored ? loc.proRestoreSuccess : loc.proRestoreNone),
        ),
      );
      if (restored) context.pop();
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) return;
      if (!mounted) return;
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.proPurchaseError),
          backgroundColor: colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    final isPro = ref.watch(entitlementStatusProvider).valueOrNull ?? false;
    final offeringAsync = ref.watch(proOfferingProvider);

    final features = [
      loc.proFeatureColorThemes,
      loc.proFeatureAdvancedReports,
      loc.proFeatureSevenDayChart,
      loc.proFeatureEmotionWheel,
      loc.proFeatureFocusChallenges,
      loc.proFeatureExtraQuotes,
      loc.proFeatureExportData,
      loc.proFeatureCustomReminders,
    ];

    return Scaffold(
      key: proPaywallKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  onPressed: () => context.pop(),
                ),
              ),
              Icon(
                Icons.workspace_premium,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                loc.proPaywallTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPro ? loc.proAlreadyProBody : loc.proPaywallSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: colorScheme.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          f,
                          style: TextStyle(
                              color: colorScheme.onSurface, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (isPro)
                _AlreadyProCard(loc: loc)
              else
                offeringAsync.when(
                  loading: () => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  error: (_, __) => _OfferingsLoadError(
                    loc: loc,
                    onRetry: () => ref.invalidate(proOfferingProvider),
                  ),
                  data: (offering) {
                    final entries =
                        offering == null ? const <_PlanEntry>[] : _entriesFor(offering);
                    if (entries.isEmpty) return _PlansUnavailable(loc: loc);

                    final selectedId = _selectedPlanId ??= _defaultPlanId(entries);

                    return Column(
                      children: [
                        ...entries.map(
                          (entry) => _PlanTile(
                            entry: entry,
                            selected: entry.id == selectedId,
                            onTap: () =>
                                setState(() => _selectedPlanId = entry.id),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SubscribeButton(
                          busy: _busy,
                          onPressed: () {
                            final selected = entries.firstWhere(
                              (e) => e.id == _selectedPlanId,
                              orElse: () => entries.first,
                            );
                            _purchase(selected.package);
                          },
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 8),
              TextButton(
                key: proRestoreKey,
                onPressed: _busy ? null : _restore,
                child: Text(
                  loc.proRestorePurchase,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final _PlanEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    final isBestValue = entry.kind == _PlanKind.annual;
    final isLifetime = entry.kind == _PlanKind.lifetime;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        key: Key('$proPlanTileKeyPrefix${entry.id}'),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _planTitle(loc, entry.kind),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (isBestValue) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              loc.proBestValueBadge,
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isLifetime)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          loc.paywallLifetimeLabel,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                entry.priceString,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscribeButton extends StatelessWidget {
  const _SubscribeButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            Color.lerp(colorScheme.primary, Colors.black, 0.35)!,
          ],
        ),
      ),
      child: ElevatedButton(
        key: proSubscribeKey,
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: busy
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.onPrimary,
                ),
              )
            : Text(
                loc.proSubscribeNow,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }
}

class _AlreadyProCard extends StatelessWidget {
  const _AlreadyProCard({required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            loc.proAlreadyProTitle,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlansUnavailable extends StatelessWidget {
  const _PlansUnavailable({required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              loc.proPlansUnavailable,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferingsLoadError extends StatelessWidget {
  const _OfferingsLoadError({
    required this.loc,
    required this.onRetry,
  });

  final AppLocalizations loc;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.proPlansUnavailable,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(loc.paywallRetryLoad),
          ),
        ],
      ),
    );
  }
}
