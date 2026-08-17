import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../data/premium_controller_provider.dart';
import 'premium_shared_widgets.dart';

/// PRE-02 — Success confirmation after purchase / restore.
class PremiumSuccessScreen extends ConsumerWidget {
  const PremiumSuccessScreen({
    super.key,
    this.source,
  });

  final String? source;

  void _return(BuildContext context) {
    final s = source;
    if (s == 'reports' || s == 'reports_archive') {
      context.go(AppRoutes.v2Reports);
      return;
    }
    if (s == 'profile') {
      context.go(AppRoutes.v2Profile);
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.v2Home);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final entitled = ref.read(premiumControllerProvider).state.isEntitled;

    return PremiumScaffold(
      title: loc.v2PremiumTitle,
      statusAnnouncement: loc.v2PremiumPurchaseCompleted,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              header: true,
              child: Text(
                entitled
                    ? loc.v2PremiumPurchaseCompleted
                    : loc.v2PremiumAlreadyActive,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            Text(loc.v2PremiumFreeCoreReassurance),
            const SizedBox(height: 12),
            Text(loc.v2PremiumCurrentProgressRemains),
            const Spacer(),
            PremiumPrimaryButton(
              key: const Key('v2_premium_success_continue'),
              label: loc.v2PremiumContinue,
              onPressed: () => _return(context),
            ),
            PremiumSecondaryButton(
              label: loc.v2PremiumManage,
              onPressed: () => context.go(AppRoutes.v2PremiumStatus),
            ),
          ],
        ),
      ),
    );
  }
}
