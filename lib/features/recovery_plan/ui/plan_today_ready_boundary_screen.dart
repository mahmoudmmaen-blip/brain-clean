import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// Temporary Today-ready boundary — session player is a later slice.
class PlanTodayReadyBoundaryScreen extends StatelessWidget {
  const PlanTodayReadyBoundaryScreen({super.key, this.planId});

  final String? planId;

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
                  loc.recoveryPlanTodayReadyTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.recoveryPlanTodayReadyBody,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: Text(loc.recoveryPlanGoHome),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
