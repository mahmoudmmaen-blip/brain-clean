import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_design_constants.dart';
import 'biometric_gate.dart';
import 'security_status_provider.dart';

/// Full-screen gate when biometric lock is enabled.
class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  int _failureCount = 0;

  Future<void> _authenticate() async {
    final ok = await ref
        .read(biometricAuthControllerProvider.notifier)
        .authenticate();
    if (!mounted) return;
    if (ok) {
      setState(() => _failureCount = 0);
      context.go(AppRoutes.home);
    } else {
      setState(() => _failureCount++);
    }
  }

  void _bypassWithPin() {
    BiometricGate.bypassForSession();
    ref.read(biometricSessionProvider.notifier).unlock();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final auth = ref.watch(biometricAuthControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint_rounded,
                size: 72,
                color: primary,
              ),
              const SizedBox(height: 24),
              Text(
                loc.biometricLockTitle,
                textAlign: TextAlign.center,
                style: AppDesignConstants.arabicText(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.biometricLockSubtitle,
                textAlign: TextAlign.center,
                style: AppDesignConstants.arabicText(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              if (auth.isLoading)
                CircularProgressIndicator(color: primary)
              else
                FilledButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: Text(loc.biometricLockButton),
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              if (_failureCount >= 3) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _bypassWithPin,
                  child: Text(loc.biometricFallbackPin),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
