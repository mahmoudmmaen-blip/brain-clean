import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/external_link_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../pro/domain/subscription_plan.dart';
import '../application/premium_controller.dart';
import '../data/premium_controller_provider.dart';
import '../domain/premium_offering.dart';
import '../domain/premium_purchase_phase.dart';
import '../domain/premium_view_state.dart';
import 'premium_shared_widgets.dart';

/// Purchase surface (contract PRE-01 offerings / Slice 9.2B plans route).
class PremiumPlansScreen extends ConsumerStatefulWidget {
  const PremiumPlansScreen({
    super.key,
    this.source,
  });

  final String? source;

  @override
  ConsumerState<PremiumPlansScreen> createState() => _PremiumPlansScreenState();
}

class _PremiumPlansScreenState extends ConsumerState<PremiumPlansScreen> {
  late final PremiumController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(premiumControllerProvider);
    _controller.addListener(_onChange);
    Future.microtask(() async {
      if (_controller.state.offerings.isEmpty) {
        await _controller.hydrate(source: widget.source ?? 'profile');
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  PremiumViewState get _state => _controller.state;

  String _periodLabel(AppLocalizations loc, SubscriptionPeriod period) {
    return switch (period) {
      SubscriptionPeriod.monthly => loc.v2PremiumPeriodMonthly,
      SubscriptionPeriod.annual => loc.v2PremiumPeriodAnnual,
      SubscriptionPeriod.lifetime => loc.v2PremiumPeriodLifetime,
    };
  }

  void _returnSource() {
    final source = widget.source;
    if (source == 'reports' || source == 'reports_archive') {
      context.go(AppRoutes.v2Reports);
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.v2Premium);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final state = _state;
    final status = premiumStatusMessage(loc, state);

    return PremiumScaffold(
      title: loc.v2PremiumViewPlans,
      onClose: _returnSource,
      statusAnnouncement: status,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(loc.v2PremiumFreeCoreReassurance),
          const SizedBox(height: 16),
          if (state.phase == PremiumPurchasePhase.loading)
            Semantics(liveRegion: true, child: Text(loc.v2PremiumLoading))
          else if (state.isEntitled) ...[
            Semantics(
              liveRegion: true,
              child: Text(loc.v2PremiumAlreadyActive),
            ),
            const SizedBox(height: 16),
            PremiumPrimaryButton(
              label: loc.v2PremiumManage,
              onPressed: () => context.go(AppRoutes.v2PremiumStatus),
            ),
          ] else if (state.phase == PremiumPurchasePhase.noOffering) ...[
            Semantics(
              liveRegion: true,
              child: Text(loc.v2PremiumNoPlansAvailable),
            ),
          ] else if (state.phase == PremiumPurchasePhase.storeUnavailable) ...[
            Semantics(
              liveRegion: true,
              child: Text(loc.v2PremiumStoreUnavailable),
            ),
          ] else if (state.phase == PremiumPurchasePhase.offlineUnknown) ...[
            Semantics(
              liveRegion: true,
              child: Text(loc.v2PremiumOfflineUnknown),
            ),
          ] else ...[
            for (final o in state.offerings)
              _PlanTile(
                offering: o,
                selected: o.productId == state.selectedProductId,
                periodLabel: _periodLabel(loc, o.period),
                onTap: () => _controller.selectProduct(o.productId),
              ),
            const SizedBox(height: 16),
            PremiumPrimaryButton(
              key: const Key('v2_premium_purchase'),
              label: loc.v2PremiumPurchaseCta,
              onPressed: state.busy || state.selectedProductId == null
                  ? null
                  : () async {
                      await _controller.purchaseSelected();
                      if (!context.mounted) return;
                      final next = _controller.state;
                      if (next.phase == PremiumPurchasePhase.purchased ||
                          next.phase == PremiumPurchasePhase.alreadyEntitled) {
                        context.go(
                          '${AppRoutes.v2PremiumSuccess}?source=${Uri.encodeComponent(widget.source ?? 'plans')}',
                        );
                      }
                    },
            ),
            if (state.messageKey != null &&
                state.phase != PremiumPurchasePhase.offeringReady) ...[
              const SizedBox(height: 12),
              Semantics(liveRegion: true, child: Text(status)),
            ],
          ],
          const SizedBox(height: 8),
          PremiumSecondaryButton(
            key: const Key('v2_premium_plans_restore'),
            label: loc.v2PremiumRestorePurchases,
            onPressed: state.busy
                ? null
                : () async {
                    await _controller.restore();
                    if (!context.mounted) return;
                    if (_controller.state.isEntitled) {
                      context.go(AppRoutes.v2PremiumSuccess);
                    }
                  },
          ),
          TextButton(
            key: const Key('v2_premium_plans_privacy'),
            onPressed: () async {
              final opened = await externalLinkService.openPrivacyPolicy();
              if (!context.mounted) return;
              if (!opened) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.settingsLinkUnavailable)),
                );
              }
            },
            child: Text(loc.settingsPrivacyPolicy),
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.offering,
    required this.selected,
    required this.periodLabel,
    required this.onTap,
  });

  final PremiumOffering offering;
  final bool selected;
  final String periodLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = '${offering.title}. $periodLabel. ${offering.priceString}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 56),
            alignment: AlignmentDirectional.centerStart,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          onPressed: onTap,
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offering.title),
                    Text(periodLabel),
                    if (offering.trialConfirmed && offering.trialLabel != null)
                      Text(offering.trialLabel!),
                  ],
                ),
              ),
              Text(offering.priceString),
            ],
          ),
        ),
      ),
    );
  }
}
