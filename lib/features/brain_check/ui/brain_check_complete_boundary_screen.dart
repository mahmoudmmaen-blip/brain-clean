import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// Safe post-check recovery boundary — continues into CHK-03 Profile build.
class BrainCheckCompleteBoundaryScreen extends StatelessWidget {
  const BrainCheckCompleteBoundaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                header: true,
                child: Text(
                  loc.brainCheckCompleteBoundaryTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.brainCheckCompleteBoundaryBody,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.brainCheckIntroNonMedical,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () =>
                      context.go(AppRoutes.v2BrainCheckBuilding),
                  child: Text(loc.brainCheckCompleteBoundaryContinue),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: Text(loc.v2OnboardingGoHome),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
