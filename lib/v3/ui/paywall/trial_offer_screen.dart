import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../features/v2_premium/application/premium_controller.dart';
import '../../../features/v2_premium/data/premium_controller_provider.dart';
import '../../../features/v2_premium/domain/premium_offering.dart';
import '../../../features/v2_premium/domain/premium_purchase_phase.dart';
import '../../application/v3_state_providers.dart';
import '../../domain/trial_offer_gate.dart';
import '../../routing/v3_routes.dart';
import '../onboarding/onboarding_keys.dart';

/// One-time trial offer after Result, before Day 1 (`/offer`).
class V3TrialOfferScreen extends ConsumerStatefulWidget {
  const V3TrialOfferScreen({super.key});

  @override
  ConsumerState<V3TrialOfferScreen> createState() => _V3TrialOfferScreenState();
}

class _V3TrialOfferScreenState extends ConsumerState<V3TrialOfferScreen> {
  late final PremiumController _controller;
  bool _markedShown = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(premiumControllerProvider);
    _controller.addListener(_onChanged);
    Future.microtask(() async {
      await _controller.hydrate(source: 'trial_offer');
      await _markOfferShown();
      if (!mounted) return;
      // If hydrate shows we shouldn't be here, skip to Day 1.
      final yearly = TrialOfferGate.yearlyOffering(_controller.state.offerings);
      final store = ref.read(premiumStorePortProvider);
      if (_controller.state.isEntitled ||
          !store.isStoreConfigured ||
          yearly == null ||
          !yearly.trialConfirmed) {
        await _goDay1();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
    final phase = _controller.state.phase;
    if (!_navigating &&
        (phase == PremiumPurchasePhase.purchased ||
            phase == PremiumPurchasePhase.alreadyEntitled ||
            phase == PremiumPurchasePhase.restored)) {
      _goDay1();
    }
  }

  Future<void> _markOfferShown() async {
    if (_markedShown) return;
    _markedShown = true;
    await ref.read(v3StateRepositoryProvider).setTrialOfferShown(true);
    ref.invalidate(v3AppStateProvider);
  }

  Future<void> _goDay1() async {
    if (_navigating) return;
    _navigating = true;
    await _markOfferShown();
    if (mounted) context.go(V3Routes.sessionPath(1));
  }

  Future<void> _startTrial() async {
    final yearly = TrialOfferGate.yearlyOffering(_controller.state.offerings);
    if (yearly == null) {
      await _goDay1();
      return;
    }
    _controller.selectProduct(yearly.productId);
    await _controller.purchaseSelected();
    // Cancel / fail: stay on screen; success navigates via listener.
    if (mounted &&
        _controller.state.phase != PremiumPurchasePhase.purchased &&
        _controller.state.phase != PremiumPurchasePhase.alreadyEntitled) {
      // Keep user on offer; they can continue free.
    }
  }

  Future<void> _continueFree() async {
    await _goDay1();
  }

  Future<void> _restore() async {
    await _controller.restore();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final state = _controller.state;
    final yearly = TrialOfferGate.yearlyOffering(state.offerings);
    final trialDays = yearly?.trialDays ?? 14;
    final price = yearly?.priceString ?? '—';
    final loading = state.phase == PremiumPurchasePhase.loading ||
        state.busy;

    return Scaffold(
      key: V3OnboardingKeys.trialOfferScreen,
      backgroundColor: colors.background,
      body: SafeArea(
        child: loading && yearly == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Text(
                      loc.v3TrialOfferTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.v3TrialOfferBody(trialDays, price),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (yearly != null) _YearlyCard(offering: yearly, loc: loc),
                    const Spacer(),
                    SizedBox(
                      height: AppDesignConstants.minTouchTarget,
                      child: FilledButton(
                        key: V3OnboardingKeys.trialOfferStart,
                        onPressed: state.busy ? null : _startTrial,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppDesignConstants.brandGreen,
                        ),
                        child: state.busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(loc.v3TrialOfferStartCta(trialDays)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: AppDesignConstants.minTouchTarget,
                      child: TextButton(
                        key: V3OnboardingKeys.trialOfferFree,
                        onPressed: state.busy ? null : _continueFree,
                        child: Text(loc.v3TrialOfferContinueFree),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.v3PaywallTrialDisclaimer,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: colors.textTertiary,
                      ),
                    ),
                    TextButton(
                      onPressed: state.busy ? null : _restore,
                      child: Text(loc.v3PaywallRestore),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _YearlyCard extends StatelessWidget {
  const _YearlyCard({required this.offering, required this.loc});

  final PremiumOffering offering;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final days = offering.trialDays ?? 14;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDesignConstants.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppDesignConstants.brandGreen, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  loc.v3PaywallPlanYearly,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppDesignConstants.brandGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loc.v3PaywallTrialBadge(days),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppDesignConstants.brandGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            offering.priceString,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
