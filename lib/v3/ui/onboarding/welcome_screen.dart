import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/clarity_check_session_provider.dart';
import '../../routing/v3_routes.dart';
import 'onboarding_keys.dart';

class V3WelcomeScreen extends ConsumerWidget {
  const V3WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppDesignConstants.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Image.asset(
                'assets/branding/brain_clean_mark.png',
                width: 72,
                height: 72,
              ),
              const SizedBox(height: 24),
              Text(
                loc.v3WelcomeTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                  color: AppDesignConstants.darkOnSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.v3WelcomeSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppDesignConstants.darkOnSurfaceMuted,
                ),
              ),
              const SizedBox(height: 28),
              _Line(icon: Icons.visibility_outlined, text: loc.v3WelcomeLine1),
              const SizedBox(height: 12),
              _Line(icon: Icons.home_work_outlined, text: loc.v3WelcomeLine2),
              const SizedBox(height: 12),
              _Line(icon: Icons.swap_horiz_rounded, text: loc.v3WelcomeLine3),
              const Spacer(),
              FilledButton(
                key: V3OnboardingKeys.welcomeStart,
                onPressed: () {
                  ref.read(clarityCheckSessionProvider.notifier).reset(
                        mode: ClarityCheckMode.baseline,
                      );
                  context.go(V3Routes.checkPath(mode: 'baseline'));
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppDesignConstants.brandGreen,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDesignConstants.radiusButton,
                    ),
                  ),
                ),
                child: Text(loc.v3WelcomeStart),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => toggleLocale(ref),
                child: Text(
                  loc.v3LanguageSwitch(locale.languageCode == 'ar' ? 'EN' : 'AR'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.v3NotMedical,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
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

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppDesignConstants.brandGreen, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: AppDesignConstants.darkOnSurface,
            ),
          ),
        ),
      ],
    );
  }
}
