import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../routing/v3_routes.dart';

/// Temporary paywall shell — full RevenueCat UI lands in a later prompt.
class V3PaywallScreen extends StatelessWidget {
  const V3PaywallScreen({super.key, this.source});

  final String? source;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final day7 = source == 'day7';
    return Scaffold(
      key: const Key('v3_paywall'),
      backgroundColor: AppDesignConstants.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(V3Routes.today),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.v3PaywallTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                day7 ? loc.v3PaywallSubDay7 : loc.v3PaywallSubGeneric,
                style: const TextStyle(
                  color: AppDesignConstants.darkOnSurfaceMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _Benefit(loc.v3PaywallBenefit1),
              _Benefit(loc.v3PaywallBenefit2),
              _Benefit(loc.v3PaywallBenefit3),
              _Benefit(loc.v3PaywallBenefit4),
              const Spacer(),
              Text(
                loc.v3PaywallFooter,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppDesignConstants.darkOnSurfaceDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_rounded, color: AppDesignConstants.accentGold),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
        ],
      ),
    );
  }
}
