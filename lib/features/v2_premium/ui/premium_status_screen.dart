import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../pro/application/subscription_service_provider.dart';
import '../application/premium_controller.dart';
import '../data/premium_controller_provider.dart';
import '../domain/premium_purchase_phase.dart';
import '../domain/premium_view_state.dart';
import 'premium_shared_widgets.dart';

/// PRE-03 — Manage / restore / entitlement status.
class PremiumStatusScreen extends ConsumerStatefulWidget {
  const PremiumStatusScreen({
    super.key,
    this.source,
    this.autoRestore = false,
  });

  final String? source;
  final bool autoRestore;

  @override
  ConsumerState<PremiumStatusScreen> createState() =>
      _PremiumStatusScreenState();
}

class _PremiumStatusScreenState extends ConsumerState<PremiumStatusScreen> {
  late final PremiumController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(premiumControllerProvider);
    _controller.addListener(_onChange);
    Future.microtask(() async {
      await _controller.hydrate(source: widget.source ?? 'manage');
      if (widget.autoRestore && mounted) {
        await _controller.restore();
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final state = _state;
    final isPro = ref.watch(isProUserProvider);
    final status = premiumStatusMessage(loc, state);

    final entitlementLabel = isPro || state.isEntitled
        ? loc.v2PremiumAlreadyActive
        : (state.messageKey == 'expired'
            ? loc.v2PremiumSubscriptionExpired
            : loc.v2PremiumFreeStatus);

    return PremiumScaffold(
      title: loc.v2PremiumManage,
      onClose: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.v2Profile);
        }
      },
      statusAnnouncement: '$entitlementLabel. $status',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Semantics(
            liveRegion: true,
            header: true,
            child: Text(
              entitlementLabel,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          Text(loc.v2PremiumFreeCoreReassurance),
          const SizedBox(height: 8),
          Text(loc.v2PremiumCurrentProgressRemains),
          const SizedBox(height: 16),
          Semantics(liveRegion: true, child: Text(status)),
          const SizedBox(height: 24),
          PremiumPrimaryButton(
            key: const Key('v2_premium_status_restore'),
            label: loc.v2PremiumRestorePurchases,
            onPressed: state.busy &&
                    state.phase == PremiumPurchasePhase.restoring
                ? null
                : () => _controller.restore(),
          ),
          const SizedBox(height: 8),
          if (!(isPro || state.isEntitled))
            PremiumSecondaryButton(
              label: loc.v2PremiumViewPlans,
              onPressed: () => context.go(
                '${AppRoutes.v2PremiumPlans}?source=${Uri.encodeComponent(widget.source ?? 'manage')}',
              ),
            )
          else
            PremiumSecondaryButton(
              label: loc.v2PremiumContinue,
              onPressed: () {
                final s = widget.source;
                if (s == 'reports' || s == 'reports_archive') {
                  context.go(AppRoutes.v2Reports);
                } else {
                  context.go(AppRoutes.v2Profile);
                }
              },
            ),
          const SizedBox(height: 8),
          PremiumSecondaryButton(
            label: loc.v2PremiumTitle,
            onPressed: () => context.go(AppRoutes.v2Premium),
          ),
        ],
      ),
    );
  }
}
