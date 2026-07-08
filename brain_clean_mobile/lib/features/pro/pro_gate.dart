import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/purchases_service.dart';

/// Whether the current user holds the live Brain Clean Pro entitlement.
bool _hasProEntitlement(WidgetRef ref) =>
    ref.read(entitlementStatusProvider).valueOrNull ?? false;

/// Routes to [destination] for Pro users, otherwise opens the paywall.
void navigateWithProGate(
  BuildContext context,
  WidgetRef ref,
  String destination,
) {
  if (_hasProEntitlement(ref)) {
    context.push(destination);
  } else {
    context.push(AppRoutes.proPaywall);
  }
}

/// Pushes paywall with optional custom streak-days path builder.
void navigateSilenceWithProGate(
  BuildContext context,
  WidgetRef ref,
  int streakDays,
) {
  if (_hasProEntitlement(ref)) {
    context.push('/silence-challenge/$streakDays');
  } else {
    context.push(AppRoutes.proPaywall);
  }
}

/// Locked upsell shown when a Pro-only screen is opened without entitlement.
class ProGate extends ConsumerWidget {
  const ProGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 48, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              loc.proPaywallTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.proPaywallSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.push(AppRoutes.proPaywall),
              child: Text(loc.proPaywallTitle),
            ),
          ],
        ),
      ),
    );
  }
}
