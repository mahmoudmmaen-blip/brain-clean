import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/presentation/app_snack_bar.dart';
import 'application/subscription_service_provider.dart';
import 'domain/subscription_plan.dart';

const proPaywallKey = Key('pro_paywall_screen');
const proSubscribeKey = Key('pro_subscribe_button');
const proRestoreKey = Key('pro_restore_button');
const proPlanTileKeyPrefix = 'pro_plan_tile_';

String _planTitle(AppLocalizations loc, SubscriptionPeriod period) {
  return switch (period) {
    SubscriptionPeriod.monthly => loc.proPlanMonthly,
    SubscriptionPeriod.annual => loc.proPlanAnnual,
    SubscriptionPeriod.lifetime => loc.proPlanLifetime,
  };
}

class ProPaywallScreen extends ConsumerStatefulWidget {
  const ProPaywallScreen({super.key});

  @override
  ConsumerState<ProPaywallScreen> createState() => _ProPaywallScreenState();
}

class _ProPaywallScreenState extends ConsumerState<ProPaywallScreen> {
  String? _selectedPlanId;
  bool _busy = false;

  Future<void> _upgrade(SubscriptionPlan plan) async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    final service = ref.read(subscriptionServiceProvider);
    final ok = await service.purchase(plan.id);
    ref.invalidate(isProUserProvider);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) return;
    showSuccessSnackBar(context, loc.proWelcomeSnack);
    if (mounted) context.pop();
  }

  Future<void> _restore() async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    final service = ref.read(subscriptionServiceProvider);
    await service.restorePurchases();
    final isPro = ref.refresh(isProUserProvider);
    if (!mounted) return;
    setState(() => _busy = false);
    showAppSnackBar(
      context,
      isPro ? loc.proRestoreSuccess : loc.proRestoreNone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isPro = ref.watch(isProUserProvider);
    final service = ref.watch(subscriptionServiceProvider);
    final plans = service.plans;
    final storeConfigured = service.isStoreConfigured;
    if (plans.isNotEmpty) {
      _selectedPlanId ??= plans
          .firstWhere(
            (p) => p.period == SubscriptionPeriod.annual,
            orElse: () => plans.first,
          )
          .id;
    }

    final features = [
      loc.proFeatureColorThemes,
      loc.proFeatureAdvancedBcs,
      loc.proFeatureSevenDayChart,
      loc.proFeatureEmotionWheel,
      loc.proFeatureFocusChallenges,
      loc.proFeatureCloudSync,
    ];

    return Scaffold(
      key: proPaywallKey,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1117), Color(0xFF161B22)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF8B949E)),
                  onPressed: () => context.pop(),
                ),
              ),
              const Icon(
                Icons.workspace_premium,
                size: 64,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(height: 16),
              Text(
                loc.proPaywallTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE6EDF3),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPro ? loc.proAlreadyProBody : loc.proPaywallSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF8B949E)),
              ),
              const SizedBox(height: 32),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF1D9E75), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(f,
                            style: const TextStyle(
                                color: Color(0xFFE6EDF3), fontSize: 15)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (isPro)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1D9E75)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF1D9E75)),
                      const SizedBox(width: 8),
                      Text(loc.proAlreadyProTitle,
                          style: const TextStyle(
                              color: Color(0xFFE6EDF3),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                )
              else if (!storeConfigured || plans.isEmpty) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    loc.v2PremiumStoreUnavailable,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8B949E),
                    ),
                  ),
                ),
              ] else ...[
                ...plans.map((plan) {
                  final selected = plan.id == _selectedPlanId;
                  final isBestValue =
                      plan.period == SubscriptionPeriod.annual;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      key: Key('$proPlanTileKeyPrefix${plan.id}'),
                      onTap: () =>
                          setState(() => _selectedPlanId = plan.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF1D9E75)
                                : Colors.transparent,
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
                                  ? const Color(0xFF1D9E75)
                                  : const Color(0xFF8B949E),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                children: [
                                  Text(_planTitle(loc, plan.period),
                                      style: const TextStyle(
                                          color: Color(0xFFE6EDF3),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  if (isBestValue) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(loc.proBestValueBadge,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Text(plan.priceString,
                                style: const TextStyle(
                                    color: Color(0xFFE6EDF3),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1D9E75), Color(0xFF0F7A5A)]),
                  ),
                  child: ElevatedButton(
                    key: proSubscribeKey,
                    onPressed: _busy || _selectedPlanId == null
                        ? null
                        : () {
                            final matches = plans
                                .where((p) => p.id == _selectedPlanId)
                                .toList(growable: false);
                            if (matches.isNotEmpty) {
                              _upgrade(matches.first);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(loc.proSubscribeNow,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                key: proRestoreKey,
                onPressed: _busy ? null : _restore,
                child: Text(loc.proRestorePurchase,
                    style: const TextStyle(color: Color(0xFF8B949E))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}