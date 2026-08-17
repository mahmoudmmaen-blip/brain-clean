import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/startup_destination.dart';
import '../../../core/theme/app_colors.dart';

/// Temporary Slice 5.1 boundary — primary path now uses the questionnaire flow.
class BrainCheckReadyBoundaryScreen extends StatelessWidget {
  const BrainCheckReadyBoundaryScreen({super.key});

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
                  loc.v2BrainCheckReadyTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.v2BrainCheckReadyBody,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => context.go(StartupDestination.resolve()),
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
