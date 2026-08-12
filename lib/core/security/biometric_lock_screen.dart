import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../routing/startup_destination.dart';
import '../theme/app_design_constants.dart';
import 'security_status_provider.dart';

/// Full-screen gate when biometric lock is enabled.
class BiometricLockScreen extends ConsumerWidget {
  const BiometricLockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final auth = ref.watch(biometricAuthControllerProvider);

    return Scaffold(
      backgroundColor: AppDesignConstants.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fingerprint_rounded,
                size: 72,
                color: Color(0xFF22D3EE),
              ),
              const SizedBox(height: 24),
              Text(
                loc.biometricLockTitle,
                textAlign: TextAlign.center,
                style: AppDesignConstants.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.biometricLockSubtitle,
                textAlign: TextAlign.center,
                style: AppDesignConstants.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              if (auth.isLoading)
                const CircularProgressIndicator(color: Color(0xFF22D3EE))
              else
                FilledButton.icon(
                  onPressed: () async {
                    final ok = await ref
                        .read(biometricAuthControllerProvider.notifier)
                        .authenticate();
                    if (ok && context.mounted) {
                      context.go(StartupDestination.resolve());
                    }
                  },
                  icon: const Icon(Icons.lock_open_rounded),
                  label: Text(loc.biometricLockButton),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
