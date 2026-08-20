import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/routing/startup_destination.dart';
import '../../../core/theme/app_colors.dart';
import '../application/v2_onboarding_controller.dart';
import '../data/v2_onboarding_repository_provider.dart';
import '../domain/v2_onboarding_progress.dart';
import '../domain/v2_onboarding_status.dart';
import '../domain/v2_onboarding_step.dart';
import 'v2_onboarding_step_views.dart';

/// Host for ONB-01…ONB-06 — resumable single-flow shell.
class V2OnboardingFlowScreen extends ConsumerStatefulWidget {
  const V2OnboardingFlowScreen({super.key});

  @override
  ConsumerState<V2OnboardingFlowScreen> createState() =>
      _V2OnboardingFlowScreenState();
}

class _V2OnboardingFlowScreenState
    extends ConsumerState<V2OnboardingFlowScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final locale = ref.read(localeProvider);
      await ref
          .read(v2OnboardingControllerProvider)
          .hydrate(languageCode: locale.languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final controller = ref.watch(v2OnboardingControllerProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: !controller.isHydrated
            ? Center(
                child: Semantics(
                  liveRegion: true,
                  label: loc.v2OnboardingLoading,
                  child: Text(loc.v2OnboardingLoading),
                ),
              )
            : controller.state.status == V2OnboardingStatus.corrupt
                ? _CorruptBody(
                    loc: loc,
                    onRestart: () => controller.clearCorruptAndStart(
                      languageCode: locale.languageCode,
                    ),
                    onHome: () => context.go(StartupDestination.resolve()),
                  )
                : V2OnboardingFlowBody(
                    loc: loc,
                    controller: controller,
                    languageCode: locale.languageCode,
                    onToggleLanguage: () async {
                      await toggleLocale(ref);
                      final code = ref.read(localeProvider).languageCode;
                      await controller.setLanguageCode(code);
                    },
                    onRitualComplete: (window, {required skip}) async {
                      await controller.setRitual(window, skip: skip);
                      await ref
                          .read(appPreferencesProvider.notifier)
                          .completeOnboarding();
                    },
                    onStartCheck: () async {
                      await controller.markReadyForBrainCheck();
                      await ref
                          .read(appPreferencesProvider.notifier)
                          .completeOnboarding();
                      if (!context.mounted) return;
                      context.go(
                        '${AppRoutes.v2BrainCheckEntry}?mode=lite&source=onboarding',
                      );
                    },
                    onSkipCheck: () async {
                      await controller.markReadyForBrainCheck();
                      await ref
                          .read(appPreferencesProvider.notifier)
                          .completeOnboarding();
                      if (!context.mounted) return;
                      context.go(StartupDestination.resolve());
                    },
                  ),
      ),
    );
  }
}

class V2OnboardingFlowBody extends StatelessWidget {
  const V2OnboardingFlowBody({
    super.key,
    required this.loc,
    required this.controller,
    required this.languageCode,
    required this.onToggleLanguage,
    required this.onRitualComplete,
    required this.onStartCheck,
    required this.onSkipCheck,
  });

  final AppLocalizations loc;
  final V2OnboardingController controller;
  final String languageCode;
  final VoidCallback onToggleLanguage;
  final Future<void> Function(V2RitualWindow? window, {required bool skip})
      onRitualComplete;
  final VoidCallback onStartCheck;
  final VoidCallback onSkipCheck;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final step = state.currentStep;
    final progress = state.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            children: [
              if (step.previous != null)
                SizedBox(
                  height: 48,
                  width: 48,
                  child: IconButton(
                    tooltip: loc.v2OnboardingBack,
                    onPressed: controller.goBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                )
              else
                const SizedBox(width: 48, height: 48),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  label: loc.v2OnboardingProgressSemantics(
                    '${progress.displayStep}',
                    '${progress.totalSteps}',
                  ),
                  child: Text(
                    loc.v2OnboardingProgressLabel(
                      '${progress.displayStep}',
                      '${progress.totalSteps}',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              if (step == V2OnboardingStep.welcome)
                SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: onToggleLanguage,
                    child: Text(
                      languageCode == 'ar'
                          ? loc.v2OnboardingLanguageEnglish
                          : loc.v2OnboardingLanguageArabic,
                    ),
                  ),
                )
              else
                const SizedBox(width: 48, height: 48),
            ],
          ),
        ),
        Expanded(
          child: KeyedSubtree(
            key: ValueKey(step.wireName),
            child: _stepView(step),
          ),
        ),
      ],
    );
  }

  Widget _stepView(V2OnboardingStep step) {
    switch (step) {
      case V2OnboardingStep.welcome:
        return OnbWelcomeView(
          loc: loc,
          onContinue: controller.advanceFromWelcome,
        );
      case V2OnboardingStep.expectations:
        return OnbExpectationsView(
          loc: loc,
          onContinue: controller.advanceFromExpectations,
        );
      case V2OnboardingStep.consent:
        return OnbConsentView(
          loc: loc,
          nonMedical: controller.state.consentNonMedical,
          terms: controller.state.consentTerms,
          analytics: controller.state.consentAnalyticsOptIn,
          onChanged: ({
            required bool nonMedical,
            required bool terms,
            required bool analytics,
          }) {
            controller.setConsent(
              nonMedical: nonMedical,
              terms: terms,
              analyticsOptIn: analytics,
            );
          },
          onContinue: () => controller.advanceFromConsent(),
        );
      case V2OnboardingStep.privacy:
        return OnbPrivacyView(
          loc: loc,
          onContinue: controller.acknowledgePrivacy,
        );
      case V2OnboardingStep.ritual:
        return OnbRitualView(
          loc: loc,
          selected: controller.state.ritualWindow,
          onContinue: (window) => onRitualComplete(window, skip: false),
          onSkip: () => onRitualComplete(null, skip: true),
        );
      case V2OnboardingStep.checkIntro:
        return OnbCheckIntroView(
          loc: loc,
          onStart: onStartCheck,
          onSkip: onSkipCheck,
        );
      case V2OnboardingStep.profileReveal:
      case V2OnboardingStep.planReveal:
      case V2OnboardingStep.todayPreview:
        // ONB-07…09 are hosted by Profile / Plan / Today-preview routes.
        return OnbCheckIntroView(
          loc: loc,
          onStart: onStartCheck,
          onSkip: onSkipCheck,
        );
    }
  }
}

class _CorruptBody extends StatelessWidget {
  const _CorruptBody({
    required this.loc,
    required this.onRestart,
    required this.onHome,
  });

  final AppLocalizations loc;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            header: true,
            liveRegion: true,
            child: Text(
              loc.v2OnboardingCorruptTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          Text(loc.v2OnboardingCorruptBody, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onRestart,
              child: Text(loc.v2OnboardingRestart),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: onHome,
              child: Text(loc.v2OnboardingGoHome),
            ),
          ),
        ],
      ),
    );
  }
}
