import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/external_link_service.dart';
import '../application/premium_controller.dart';
import '../data/premium_controller_provider.dart';
import '../domain/premium_purchase_phase.dart';
import '../domain/premium_view_state.dart';
import 'premium_shared_widgets.dart';

/// PRE-01 — Appreciation-first Premium overview.
class PremiumOverviewScreen extends ConsumerStatefulWidget {
  const PremiumOverviewScreen({
    super.key,
    this.source,
  });

  final String? source;

  @override
  ConsumerState<PremiumOverviewScreen> createState() =>
      _PremiumOverviewScreenState();
}

class _PremiumOverviewScreenState extends ConsumerState<PremiumOverviewScreen> {
  late final PremiumController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(premiumControllerProvider);
    _controller.addListener(_onChange);
    Future.microtask(() async {
      final phase = _controller.state.phase;
      if (phase == PremiumPurchasePhase.offeringReady ||
          phase == PremiumPurchasePhase.alreadyEntitled ||
          phase == PremiumPurchasePhase.noOffering ||
          phase == PremiumPurchasePhase.storeUnavailable) {
        return;
      }
      await _controller.hydrate(source: widget.source);
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

  void _close() {
    final source = widget.source;
    if (source == 'reports' || source == 'reports_archive') {
      context.go(AppRoutes.v2Reports);
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.v2Profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final state = _state;
    final status = premiumStatusMessage(loc, state);

    return PremiumScaffold(
      title: loc.v2PremiumTitle,
      onClose: _close,
      statusAnnouncement: status,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Semantics(
            header: true,
            child: Text(
              loc.v2PremiumOrientation,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          Text(loc.v2PremiumFreeCoreReassurance),
          const SizedBox(height: 8),
          Text(loc.v2PremiumCurrentProgressRemains),
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text(
              loc.v2PremiumFourCapitalsHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          _Capital(
              title: loc.v2PremiumContinuity,
              body: loc.v2PremiumContinuityBody),
          _Capital(
            title: loc.v2PremiumInterpretation,
            body: loc.v2PremiumInterpretationBody,
          ),
          _Capital(title: loc.v2PremiumFit, body: loc.v2PremiumFitBody),
          _Capital(title: loc.v2PremiumSupport, body: loc.v2PremiumSupportBody),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              loc.v2PremiumIncludesNowHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          _IncludeBullet(loc.v2PremiumIncludeArchive),
          _IncludeBullet(loc.v2PremiumIncludeThemes),
          _IncludeBullet(loc.v2PremiumIncludeTools),
          _IncludeBullet(loc.v2PremiumIncludeChart),
          const SizedBox(height: 12),
          Text(loc.v2PremiumBenefitsBody),
          const SizedBox(height: 24),
          if (state.phase == PremiumPurchasePhase.loading)
            Semantics(
              liveRegion: true,
              child: Text(loc.v2PremiumLoading),
            )
          else if (state.isEntitled ||
              state.phase == PremiumPurchasePhase.alreadyEntitled ||
              state.phase == PremiumPurchasePhase.purchased ||
              state.phase == PremiumPurchasePhase.restored) ...[
            Semantics(
              liveRegion: true,
              child: Text(loc.v2PremiumAlreadyActive),
            ),
            const SizedBox(height: 16),
            PremiumPrimaryButton(
              label: loc.v2PremiumManage,
              onPressed: () => context.go(
                '${AppRoutes.v2PremiumStatus}?source=${Uri.encodeComponent(widget.source ?? 'profile')}',
              ),
            ),
          ] else ...[
            PremiumPrimaryButton(
              key: const Key('v2_premium_view_plans'),
              label: loc.v2PremiumViewPlans,
              onPressed: state.phase == PremiumPurchasePhase.noOffering ||
                      state.phase == PremiumPurchasePhase.storeUnavailable ||
                      state.phase == PremiumPurchasePhase.offlineUnknown
                  ? null
                  : () => context.go(
                        '${AppRoutes.v2PremiumPlans}?source=${Uri.encodeComponent(widget.source ?? 'profile')}',
                      ),
            ),
            if (state.phase == PremiumPurchasePhase.noOffering ||
                state.phase == PremiumPurchasePhase.storeUnavailable) ...[
              const SizedBox(height: 12),
              Semantics(liveRegion: true, child: Text(status)),
            ],
          ],
          const SizedBox(height: 8),
          PremiumSecondaryButton(
            key: const Key('v2_premium_restore'),
            label: loc.v2PremiumRestorePurchases,
            onPressed: state.busy
                ? null
                : () async {
                    await _controller.restore();
                    if (!context.mounted) return;
                    if (_controller.state.isEntitled) {
                      context.go(
                        '${AppRoutes.v2PremiumSuccess}?source=${Uri.encodeComponent(widget.source ?? 'restore')}',
                      );
                    }
                  },
          ),
          // Debug-stable key for phase-dependent primary actions region.
          KeyedSubtree(
            key: Key('v2_premium_phase_${state.phase.name}'),
            child: const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          PremiumSecondaryButton(
            label: loc.v2PremiumManage,
            onPressed: () => context.go(
              '${AppRoutes.v2PremiumStatus}?source=${Uri.encodeComponent(widget.source ?? 'profile')}',
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            key: const Key('v2_premium_privacy'),
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
          const SizedBox(height: 8),
          PremiumSecondaryButton(
            label: MaterialLocalizations.of(context).closeButtonLabel,
            onPressed: _close,
          ),
        ],
      ),
    );
  }
}

class _Capital extends StatelessWidget {
  const _Capital({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(body),
        ],
      ),
    );
  }
}

class _IncludeBullet extends StatelessWidget {
  const _IncludeBullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
