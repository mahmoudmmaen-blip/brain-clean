import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/startup_destination.dart';
import '../../../core/theme/app_colors.dart';

/// Temporary Slice 3 completion boundary — Recovery Plan is Slice 4.
class ProfileReadyBoundaryScreen extends StatelessWidget {
  const ProfileReadyBoundaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                header: true,
                child: Text(
                  loc.brainProfileReadyTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.brainProfileReadyBody,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => context.go(StartupDestination.resolve()),
                  child: Text(loc.brainProfileGoHome),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
