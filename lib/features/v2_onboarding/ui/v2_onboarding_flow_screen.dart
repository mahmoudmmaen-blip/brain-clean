import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/routing/startup_destination.dart';
import '../../../core/theme/app_colors.dart';
import '../../daily_session/data/daily_session_controller_provider.dart';
import '../../recovery_plan/data/recovery_plan_repository_provider.dart'
    show recoveryPlanGeneratorProvider;
import '../application/v2_onboarding_controller.dart';
import '../data/v2_onboarding_repository_provider.dart';
import '../domain/v2_onboarding_progress.dart';
import '../domain/v2_onboarding_status.dart';
import '../domain/v2_onboarding_step.dart';
import 'v2_onboarding_step_views.dart';

/// Short onboarding host — 3 screens, then Day 1 exercise.
class V2OnboardingFlowScreen extends ConsumerStatefulWidget {
  const V2OnboardingFlowScreen({super.key});

  @override
  ConsumerState<V2OnboardingFlowScreen> createState() =>
      _V2OnboardingFlowScreenState();
}

class _V2OnboardingFlowScreenState
    extends ConsumerState<V2OnboardingFlowScreen> {
  var _startingDay1 = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final locale = ref.read(localeProvider);
      final controller = ref.read(v2OnboardingControllerProvider);
      await controller.hydrate(languageCode: locale.languageCode);

      // If a plan already exists, never show onboarding again.
      final plan =
          await ref.read(recoveryPlanGeneratorProvider).active();
      if (plan != null) {
        await controller.markJourneyCompleted(planId: plan.id);
        await ref.read(appPreferencesProvider.notifier).completeOnboarding();
        if (!mounted) return;
        context.go(StartupDestination.resolve());
        return;
      }
      if (controller.state.isJourneyComplete) {
        await ref.read(appPreferencesProvider.notifier).completeOnboarding();
        if (!mounted) return;
        context.go(StartupDestination.resolve());
      }
    });
  }

  Future<void> _startDay1() async {
    if (_startingDay1) return;
    setState(() => _startingDay1 = true);
    try {
      final controller = ref.read(v2OnboardingControllerProvider);
      final name = controller.state.firstName?.trim();
      if (name != null && name.isNotEmpty) {
        await ref
            .read(appPreferencesProvider.notifier)
            .setProfileDisplayName(name);
      }

      final generator = ref.read(recoveryPlanGeneratorProvider);
      final plan = await generator.generateStarterForOnboarding();
      await controller.markPlanRevealed(planId: plan.id);
      await controller.markJourneyCompleted(planId: plan.id);
      await ref.read(appPreferencesProvider.notifier).completeOnboarding();

      final sessionController = ref.read(dailySessionControllerProvider);
      await sessionController.loadToday();
      final session = await sessionController.ensureSession();
      if (!mounted) return;
      if (session != null) {
        context.go('${AppRoutes.v2SessionPrepare}?session=${session.id}');
      } else {
        context.go(StartupDestination.resolve());
      }
    } catch (e) {
      debugPrint('V2OnboardingFlowScreen: start Day 1 failed: $e');
      if (mounted) {
        setState(() => _startingDay1 = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.v2TodayReadyPersistFailed)),
        );
      }
    }
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
                    startingDay1: _startingDay1,
                    onToggleLanguage: () async {
                      await toggleLocale(ref);
                      final code = ref.read(localeProvider).languageCode;
                      await controller.setLanguageCode(code);
                    },
                    onStartDay1: _startDay1,
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
    this.onStartDay1,
    this.startingDay1 = false,
    // Legacy callbacks kept for older widget tests.
    this.onRitualComplete,
    this.onStartCheck,
    this.onSkipCheck,
  });

  final AppLocalizations loc;
  final V2OnboardingController controller;
  final String languageCode;
  final VoidCallback onToggleLanguage;
  final VoidCallback? onStartDay1;
  final bool startingDay1;
  final Future<void> Function(V2RitualWindow? window, {required bool skip})?
      onRitualComplete;
  final VoidCallback? onStartCheck;
  final VoidCallback? onSkipCheck;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final step = state.currentStep.normalizedForShell;
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
                    onPressed: startingDay1 ? null : controller.goBack,
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
    switch (step.normalizedForShell) {
      case V2OnboardingStep.welcome:
        return OnbWelcomeView(
          loc: loc,
          onContinue: controller.advanceFromWelcome,
        );
      case V2OnboardingStep.quickSetup:
        return OnbQuickSetupView(
          loc: loc,
          initialScreenHours: controller.state.screenHours,
          initialGoal: controller.state.mainGoal,
          initialHardest: controller.state.hardestTime,
          initialReminder: controller.state.ritualWindow,
          initialFirstName: controller.state.firstName,
          onContinue: ({
            required screenHours,
            required mainGoal,
            required hardestTime,
            reminderTime,
            firstName,
          }) async {
            await controller.saveQuickSetup(
              screenHours: screenHours,
              mainGoal: mainGoal,
              hardestTime: hardestTime,
              reminderTime: reminderTime,
              firstName: firstName,
            );
            await controller.advanceFromQuickSetup();
          },
        );
      case V2OnboardingStep.planReady:
      default:
        return OnbPlanReadyView(
          loc: loc,
          busy: startingDay1,
          onStartDay1: onStartDay1 ?? onStartCheck ?? () {},
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.v2OnboardingCorruptTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            loc.v2OnboardingCorruptBody,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const Spacer(),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: onRestart,
              child: Text(loc.v2OnboardingRestart),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: onHome,
              child: Text(loc.v2OnboardingGoHome),
            ),
          ),
        ],
      ),
    );
  }
}
