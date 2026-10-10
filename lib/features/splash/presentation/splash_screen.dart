import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/security/security_status_provider.dart';
import '../../../v3/application/v3_onboarding_gate_provider.dart';
import '../../../v3/routing/v3_routes.dart';
import '../../../v3/routing/v3_startup.dart';

/// Cold-start gate: then welcome or Today (V3).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  /// Overridable in widget tests to skip the cold-start delay.
  @visibleForTesting
  static Duration minSplashDuration = const Duration(seconds: 2);

  /// When false, skips the typewriter timer (avoids pumpAndSettle hangs in tests).
  @visibleForTesting
  static bool enableTypewriterAnimation = true;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _typewriterDelay = Duration(milliseconds: 80);

  String _typedTitle = '';
  bool _showSubtitle = false;
  bool _routing = true;
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
    if (!SplashScreen.enableTypewriterAnimation) {
      setState(() {
        _typedTitle = full;
        _showSubtitle = true;
      });
      return;
    }
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
        if (mounted) context.go(V3Routes.biometricLock);
        return;
      }
    }

    await ref.read(v3OnboardingGateProvider.notifier).hydrate();
    final onboardingDone = ref.read(v3OnboardingGateProvider) ?? false;
    final destination = V3Startup.afterSplash(onboardingDone: onboardingDone);
    if (kDebugMode) {
      debugPrint(
        '[SplashColdStart] v3OnboardingDone=$onboardingDone destination=$destination',
      );
    }
    if (mounted) {
      setState(() => _routing = false);
      context.go(destination);
    }
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/branding/brain_clean_mark.png',
                      width: 88,
                      height: 88,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _typedTitle,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFE6EDF3),
                              ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedOpacity(
                      opacity: _showSubtitle ? 1 : 0,
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        loc.splashSubtitle,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8B949E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_routing)
              const Padding(
                padding: EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: LinearProgressIndicator(
                  color: Color(0xFF1D9E75),
                  backgroundColor: Color(0xFF30363D),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
