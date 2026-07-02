import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/bootstrap/app_hydration_provider.dart';
import '../../../core/application/app_preferences_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/security/security_status_provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

/// Cold-start gate: hydrates Hive + Riverpod, then home or **live session** resume.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  /// Overridable in widget tests to skip the cold-start delay.
  @visibleForTesting
  static Duration minSplashDuration = const Duration(seconds: 2);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _typewriterDelay = Duration(milliseconds: 80);

  String _typedTitle = '';
  bool _showSubtitle = false;
  Timer? _typewriterTimer;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTypewriter();
      _hydrateAndRoute();
    });
  }

  void _startTypewriter() {
    final loc = AppLocalizations.of(context)!;
    final full = loc.splashTitle;
    _typewriterTimer = Timer.periodic(_typewriterDelay, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _charIndex++;
      setState(() => _typedTitle = full.substring(0, _charIndex));
      if (_charIndex >= full.length) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showSubtitle = true);
        });
      }
    });
  }

  Future<void> _hydrateAndRoute() async {
    final started = DateTime.now();
    var snapshot = const AppHydrationSnapshot(
      hasCommittedSession: false,
      hasDraftProgress: false,
    );
    try {
      snapshot = await ref.read(appHydrationProvider.future);
    } catch (_) {
      // Local Hive remains authoritative; route using defaults below.
    }

    final elapsed = DateTime.now().difference(started);
    if (elapsed < SplashScreen.minSplashDuration) {
      await Future<void>.delayed(SplashScreen.minSplashDuration - elapsed);
    }
    if (!mounted) return;

    await ref.read(biometricLockSettingsProvider.notifier).hydrate();
    final biometricEnabled = ref.read(biometricLockSettingsProvider);
    if (biometricEnabled) {
      final ok = await ref
          .read(biometricAuthControllerProvider.notifier)
          .authenticate();
      if (!ok) {
        if (mounted) context.go(AppRoutes.biometricLock);
        return;
      }
    }

    final hasSeen = ref.read(hasSeenOnboardingProvider);
    if (!hasSeen) {
      context.go(AppRoutes.onboarding);
      return;
    }

    final resumeLiveSession =
        snapshot.hasDraftProgress && !snapshot.hasCommittedSession;
    context.go(resumeLiveSession ? AppRoutes.diagnostic : AppRoutes.home);
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final hydration = ref.watch(appHydrationProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.psychology_outlined,
                      size: 64,
                      color: AppTheme.gold,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _typedTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedOpacity(
                      opacity: _showSubtitle ? 1 : 0,
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        loc.splashSubtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (hydration.hasError)
                      Text(
                        loc.splashHydrationRetry,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ),
            if (hydration.isLoading)
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: LinearProgressIndicator(
                  color: colorScheme.primary,
                  backgroundColor: dividerColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
