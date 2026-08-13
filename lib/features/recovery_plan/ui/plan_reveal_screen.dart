import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../../brain_profile/data/brain_profile_repository_provider.dart';
import '../../brain_profile/domain/measurement_confidence.dart';
import '../../v2_onboarding/data/v2_onboarding_repository_provider.dart';
import '../../v2_onboarding/domain/v2_setup_recovery.dart';
import '../data/recovery_plan_repository_provider.dart';
import '../domain/recovery_plan.dart';
import '../domain/recovery_plan_intensity.dart';
import '../domain/recovery_plan_status.dart';
import '../domain/recovery_plan_step.dart';
import '../domain/today_act_presentation.dart';

/// Dual-use presentation for [PlanRevealScreen].
///
/// [firstTimeReveal] — PLN-01 onboarding reveal (continue → today-preview).
/// [shellOrientation] — established shell Plan tab (soft CTA → shell Today).
enum PlanRevealPresentation {
  firstTimeReveal,
  shellOrientation,
}

/// PLN-01 — calm Recovery Plan reveal + shell orientation dual-use.
class PlanRevealScreen extends ConsumerStatefulWidget {
  const PlanRevealScreen({super.key, this.planId});

  final String? planId;

  @override
  ConsumerState<PlanRevealScreen> createState() => _PlanRevealScreenState();
}

class _PlanRevealScreenState extends ConsumerState<PlanRevealScreen> {
  RecoveryPlan? _plan;
  var _loading = true;
  var _missing = false;
  var _hasProfilePack = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  /// Established shell Plan once Today preview (or full journey) exists.
  /// Keeps PLN-01 layout until onboarding advances past reveal.
  static bool _isEstablishedShellPlan({
    required bool isJourneyComplete,
    required bool todayPreviewed,
  }) =>
      isJourneyComplete || todayPreviewed;

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _missing = false;
    });
    try {
      final repo = ref.read(recoveryPlanRepositoryProvider);
      final onboarding = ref.read(v2OnboardingControllerProvider);
      final onb = onboarding.state;
      final shellMode = _isEstablishedShellPlan(
        isJourneyComplete: onb.isJourneyComplete,
        todayPreviewed: onb.todayPreviewed,
      );

      RecoveryPlan? plan;
      if (widget.planId != null && widget.planId!.isNotEmpty) {
        plan = await repo.findById(widget.planId!);
      }
      plan ??= await repo.active();
      if (!mounted) return;

      var hasPack = plan != null;
      if (plan == null) {
        try {
          final pack = await ref.read(brainProfileRepositoryProvider).latest();
          hasPack = pack != null;
        } catch (_) {
          hasPack = false;
        }
      }

      // First-time reveal still marks PLN-01. Skip redundant writes on shell.
      if (plan != null && !shellMode) {
        await onboarding.markPlanRevealed(planId: plan.id);
      }

      if (!mounted) return;
      setState(() {
        _plan = plan;
        _missing = plan == null;
        _hasProfilePack = hasPack;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _plan = null;
        _missing = true;
        _hasProfilePack = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    // Indexed shell keeps this screen alive — re-resolve mode every build.
    final onb = ref.watch(v2OnboardingControllerProvider).state;
    final presentation = _isEstablishedShellPlan(
      isJourneyComplete: onb.isJourneyComplete,
      todayPreviewed: onb.todayPreviewed,
    )
        ? PlanRevealPresentation.shellOrientation
        : PlanRevealPresentation.firstTimeReveal;
    final isShell = presentation == PlanRevealPresentation.shellOrientation;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.recoveryPlanTitle),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: PlanRevealBody(
          loc: loc,
          languageCode: isAr ? 'ar' : 'en',
          loading: _loading,
          missing: _missing,
          plan: _plan,
          hasProfilePack: _hasProfilePack,
          presentation: presentation,
          onGoHome: () => context.go(AppRoutes.v2Home),
          onContinue: () {
            final id = _plan?.id ?? '';
            if (isShell) {
              context.go(AppRoutes.v2Home);
            } else {
              context.go('${AppRoutes.v2PlanTodayPreview}?plan=$id');
            }
          },
          onRebuild: () => context.go(AppRoutes.v2PlanBuilding),
          onStartBrainCheck: () => context.go(
            V2SetupRecovery.brainCheckLocation(source: 'program'),
          ),
        ),
      ),
    );
  }
}

/// Sync-testable PLN-01 / shell Plan body.
class PlanRevealBody extends StatelessWidget {
  const PlanRevealBody({
    super.key,
    required this.loc,
    required this.languageCode,
    required this.loading,
    required this.missing,
    required this.plan,
    required this.onGoHome,
    required this.onContinue,
    required this.onRebuild,
    required this.onStartBrainCheck,
    this.hasProfilePack = false,
    this.presentation = PlanRevealPresentation.firstTimeReveal,
  });

  final AppLocalizations loc;
  final String languageCode;
  final bool loading;
  final bool missing;
  final RecoveryPlan? plan;
  final VoidCallback onGoHome;
  final VoidCallback onContinue;
  final VoidCallback onRebuild;
  final VoidCallback onStartBrainCheck;
  final bool hasProfilePack;
  final PlanRevealPresentation presentation;

  bool get _isShell => presentation == PlanRevealPresentation.shellOrientation;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          label: loc.recoveryPlanLoading,
          child: Text(loc.recoveryPlanLoading),
        ),
      );
    }

    if (missing || plan == null) {
      final theme = Theme.of(context);
      final startCheck = V2SetupRecovery.resolve(
            hasProfilePack: hasProfilePack,
            hasValidPlan: false,
          ) ==
          V2SetupRecoveryAction.startBrainCheck;
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: V2ShellVisual.pagePadding(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight >
                        AppDesignConstants.minTouchTarget
                    ? constraints.maxHeight - AppDesignConstants.minTouchTarget
                    : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      loc.recoveryPlanMissing,
                      textAlign: TextAlign.center,
                      style: V2ShellVisual.heroTitle(theme),
                    ),
                  ),
                  if (startCheck) ...[
                    const SizedBox(height: AppDesignConstants.v2GapControl),
                    Text(
                      loc.recoveryPlanMissingProfile,
                      textAlign: TextAlign.center,
                      style: V2ShellVisual.bodyMuted(theme),
                    ),
                  ],
                  const SizedBox(height: AppDesignConstants.v2GapSection),
                  SizedBox(
                    width: double.infinity,
                    height: AppDesignConstants.minTouchTarget,
                    child: FilledButton(
                      key: const Key('v2_program_setup_cta'),
                      onPressed: startCheck ? onStartBrainCheck : onRebuild,
                      style: V2ShellVisual.primaryFilled(),
                      child: Text(
                        startCheck
                            ? loc.v2BrainCheckEntryStart
                            : loc.recoveryPlanBuildCta,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDesignConstants.v2GapTight),
                  SizedBox(
                    width: double.infinity,
                    height: AppDesignConstants.minTouchTarget,
                    child: OutlinedButton(
                      style: V2ShellVisual.secondaryOutlined(),
                      onPressed: onGoHome,
                      child: Text(loc.recoveryPlanGoHome),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (_isShell) {
      return _ShellPlanOrientation(
        loc: loc,
        languageCode: languageCode,
        plan: plan!,
        onContinue: onContinue,
      );
    }

    return _FirstTimePlanReveal(
      loc: loc,
      languageCode: languageCode,
      plan: plan!,
      onContinue: onContinue,
    );
  }
}

// Shell Program rhythm — shared V2 tokens.
const double _kShellGapThesisBody = AppDesignConstants.v2GapInline;
const double _kShellGapAfterThesis = AppDesignConstants.v2GapSection;
const double _kShellGapSupportBlocks = AppDesignConstants.v2GapControl;
const double _kShellGapSection = AppDesignConstants.v2GapSection;
const double _kShellGapLabelBody = AppDesignConstants.v2GapSectionLabel;
const double _kShellGapBeforeDetails = AppDesignConstants.v2GapControl;
const double _kShellGapDetailsCta = AppDesignConstants.v2GapSection;

/// Established shell Plan — orientation-first, not another Today.
class _ShellPlanOrientation extends StatelessWidget {
  const _ShellPlanOrientation({
    required this.loc,
    required this.languageCode,
    required this.plan,
    required this.onContinue,
  });

  final AppLocalizations loc;
  final String languageCode;
  final RecoveryPlan plan;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final expl = plan.explanation;
    final today = plan.dayTemplate.todayPreview;
    final isStarter = plan.isStarterFallback ||
        plan.generationStatus == RecoveryPlanStatus.starterFallback;
    final confidenceLabel = switch (plan.confidence) {
      MeasurementConfidence.provisional =>
        loc.brainProfileConfidenceProvisional,
      MeasurementConfidence.moderate => loc.brainProfileConfidenceModerate,
      MeasurementConfidence.strong => loc.brainProfileConfidenceSolid,
    };
    final timeLabel = loc.recoveryPlanTimeRange(
      '${plan.cadence.minPathMinutesMin}',
      '${plan.cadence.standardPathMinutesMax}',
    );
    final intensityLabel = plan.intensity.labelForLocale(languageCode);
    final actTitle = resolveTodayActTitle(plan, languageCode) ??
        loc.v2TodayPreviewFallbackTitle;
    final minSteps = _resolvedSteps(plan, today.minimumPathStepIds);
    final stdSteps = _resolvedSteps(plan, today.standardPathStepIds);

    return SingleChildScrollView(
      padding: V2ShellVisual.pagePadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1–2 Program thesis (dominant)
          if (isStarter) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                loc.recoveryPlanStarterBadge,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppDesignConstants.v2GapTight),
          ],
          Semantics(
            header: true,
            label:
                '${loc.recoveryPlanMainFocus}: ${expl.mainFocusForLocale(languageCode)}',
            child: Text(
              loc.recoveryPlanMainFocus,
              style: theme.textTheme.labelMedium?.copyWith(color: muted),
            ),
          ),
          const SizedBox(height: _kShellGapThesisBody),
          Text(
            expl.mainFocusForLocale(languageCode),
            style: V2ShellVisual.heroTitle(theme),
          ),
          const SizedBox(height: _kShellGapThesisBody),
          Text(
            loc.recoveryPlanCalmOrientationBody,
            style: V2ShellVisual.captionMuted(theme),
          ),

          // 3 Support context — compact chips, not a second hero
          const SizedBox(height: _kShellGapAfterThesis),
          V2SectionLabel(loc.recoveryPlanPrioritiesHeading),
          const SizedBox(height: _kShellGapLabelBody),
          if (plan.priority.priorities.isEmpty)
            Text(
              loc.recoveryPlanNoPriorities,
              style: V2ShellVisual.bodyMuted(theme),
            )
          else
            Wrap(
              spacing: AppDesignConstants.v2GapTight,
              runSpacing: AppDesignConstants.v2GapTight,
              children: [
                for (final d in plan.priority.priorities)
                  V2QuietChip(
                    label: d.titleForLocale(languageCode),
                    semanticLabel:
                        '${loc.recoveryPlanPrioritiesHeading}: ${d.titleForLocale(languageCode)}',
                  ),
              ],
            ),
          if (plan.priority.strongerDomainId != null) ...[
            const SizedBox(height: _kShellGapSupportBlocks),
            V2SectionLabel(loc.recoveryPlanStrongerHeading),
            const SizedBox(height: _kShellGapLabelBody),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: V2QuietChip(
                label: plan.priority.strongerTitleForLocale(languageCode),
                semanticLabel:
                    '${loc.recoveryPlanStrongerHeading}: ${plan.priority.strongerTitleForLocale(languageCode)}',
              ),
            ),
          ],

          // 4 Daily shape — one concise effort line
          const SizedBox(height: _kShellGapSection),
          V2SectionLabel(loc.recoveryPlanTimeHeading),
          const SizedBox(height: _kShellGapLabelBody),
          Semantics(
            label:
                '$timeLabel. ${loc.recoveryPlanIntensityLabel}: $intensityLabel',
            child: Text(
              '$timeLabel · $intensityLabel',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),

          // 5 Today's place (orientation only)
          const SizedBox(height: _kShellGapSection),
          V2SectionLabel(loc.recoveryPlanTodayFitHeading),
          const SizedBox(height: _kShellGapLabelBody),
          Text(
            actTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppDesignConstants.v2GapInline - 2),
          Text(
            today.because.forLocale(languageCode),
            style: V2ShellVisual.bodyMuted(theme),
          ),

          // 6 Depth — demoted progressive disclosure
          const SizedBox(height: _kShellGapBeforeDetails),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 4),
          _PlanDetailExpansion(
            title: loc.recoveryPlanPathDetails,
            subtitle:
                '${loc.recoveryPlanMinimumPath}: ${loc.recoveryPlanStepCount(minSteps.length)} · '
                '${loc.recoveryPlanStandardPath}: ${loc.recoveryPlanStepCount(stdSteps.length)}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loc.recoveryPlanMinimumPath,
                  style: theme.textTheme.labelMedium?.copyWith(color: muted),
                ),
                const SizedBox(height: 4),
                ..._compactPathNames(loc, languageCode, minSteps),
                const SizedBox(height: 10),
                Text(
                  loc.recoveryPlanStandardPath,
                  style: theme.textTheme.labelMedium?.copyWith(color: muted),
                ),
                const SizedBox(height: 4),
                ..._compactPathNames(loc, languageCode, stdSteps),
              ],
            ),
          ),
          _PlanDetailExpansion(
            title: loc.recoveryPlanAboutDetails,
            subtitle: '${loc.recoveryPlanConfidenceHeading}: $confidenceLabel',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...expl.becauseLinesForLocale(languageCode).map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          line,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                Text(
                  expl.nonMedicalForLocale(languageCode),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  expl.whyMayChangeForLocale(languageCode),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.recoveryPlanSkipHint,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),

          // 7 Soft navigation to shell Today (not session execution)
          const SizedBox(height: _kShellGapDetailsCta),
          SizedBox(
            height: AppDesignConstants.minTouchTarget,
            child: OutlinedButton(
              style: V2ShellVisual.secondaryOutlined(),
              onPressed: onContinue,
              child: Text(loc.recoveryPlanOpenToday),
            ),
          ),
        ],
      ),
    );
  }
}

/// First-time PLN-01 document — preserve onboarding contract.
class _FirstTimePlanReveal extends StatelessWidget {
  const _FirstTimePlanReveal({
    required this.loc,
    required this.languageCode,
    required this.plan,
    required this.onContinue,
  });

  final AppLocalizations loc;
  final String languageCode;
  final RecoveryPlan plan;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final expl = plan.explanation;
    final today = plan.dayTemplate.todayPreview;
    final isStarter = plan.isStarterFallback ||
        plan.generationStatus == RecoveryPlanStatus.starterFallback;
    final confidenceLabel = switch (plan.confidence) {
      MeasurementConfidence.provisional =>
        loc.brainProfileConfidenceProvisional,
      MeasurementConfidence.moderate => loc.brainProfileConfidenceModerate,
      MeasurementConfidence.strong => loc.brainProfileConfidenceSolid,
    };
    final timeLabel = loc.recoveryPlanTimeRange(
      '${plan.cadence.minPathMinutesMin}',
      '${plan.cadence.standardPathMinutesMax}',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              loc.recoveryPlanCalmOrientation,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Text(loc.recoveryPlanCalmOrientationBody),
          const SizedBox(height: 16),
          if (isStarter) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                loc.recoveryPlanStarterBadge,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Semantics(
            header: true,
            label:
                '${loc.recoveryPlanMainFocus}: ${expl.mainFocusForLocale(languageCode)}',
            child: Text(
              loc.recoveryPlanMainFocus,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(expl.mainFocusForLocale(languageCode)),
          const SizedBox(height: 8),
          Text(loc.recoveryPlanFitsProfile),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              loc.recoveryPlanPrioritiesHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          if (plan.priority.priorities.isEmpty)
            Text(loc.recoveryPlanNoPriorities)
          else
            ...plan.priority.priorities.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Semantics(
                  label:
                      '${loc.recoveryPlanPrioritiesHeading}: ${d.titleForLocale(languageCode)}',
                  child: Text(d.titleForLocale(languageCode)),
                ),
              ),
            ),
          if (plan.priority.strongerDomainId != null) ...[
            const SizedBox(height: 8),
            Semantics(
              header: true,
              child: Text(
                loc.recoveryPlanStrongerHeading,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(plan.priority.strongerTitleForLocale(languageCode)),
          ],
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              loc.recoveryPlanConfidenceHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: '${loc.recoveryPlanConfidenceHeading}: $confidenceLabel',
            child: Text(confidenceLabel),
          ),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              loc.recoveryPlanTimeHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: timeLabel,
            child: Text(timeLabel),
          ),
          const SizedBox(height: 8),
          Text(
            '${loc.recoveryPlanIntensityLabel}: ${plan.intensity.labelForLocale(languageCode)}',
          ),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              loc.recoveryPlanMinimumPath,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          ..._pathSteps(
            context,
            loc,
            plan,
            today.minimumPathStepIds,
            languageCode,
          ),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              loc.recoveryPlanStandardPath,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          ..._pathSteps(
            context,
            loc,
            plan,
            today.standardPathStepIds,
            languageCode,
          ),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              loc.recoveryPlanBecauseHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          ...expl.becauseLinesForLocale(languageCode).map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(line),
                ),
              ),
          const SizedBox(height: 8),
          Text(expl.nonMedicalForLocale(languageCode)),
          const SizedBox(height: 8),
          Text(expl.whyMayChangeForLocale(languageCode)),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              loc.recoveryPlanTodayPreview,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label:
                '${loc.v2TodayPreviewActHeading}: ${resolveTodayActTitle(plan, languageCode) ?? loc.v2TodayPreviewFallbackTitle}',
            child: Text(
              resolveTodayActTitle(plan, languageCode) ??
                  loc.v2TodayPreviewFallbackTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label:
                '${loc.v2TodayPreviewBecauseHeading}: ${today.because.forLocale(languageCode)}',
            child: Text(today.because.forLocale(languageCode)),
          ),
          const SizedBox(height: 8),
          Text(
            loc.recoveryPlanSkipHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: AppDesignConstants.minTouchTarget,
            child: FilledButton(
              style: V2ShellVisual.primaryFilled(),
              onPressed: onContinue,
              child: Text(loc.recoveryPlanContinueToday),
            ),
          ),
        ],
      ),
    );
  }
}

List<RecoveryPlanStep> _resolvedSteps(
  RecoveryPlan plan,
  List<String> stepIds,
) {
  final byId = {for (final s in plan.steps) s.stepId: s};
  final out = <RecoveryPlanStep>[];
  for (final id in stepIds) {
    final step = byId[id];
    if (step != null) out.add(step);
  }
  return out;
}

List<Widget> _compactPathNames(
  AppLocalizations loc,
  String languageCode,
  List<RecoveryPlanStep> steps,
) {
  if (steps.isEmpty) {
    return [Text(loc.recoveryPlanNoSteps)];
  }
  return [
    for (final step in steps)
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Semantics(
          label: [
            step.nameForLocale(languageCode),
            if (step.optional) loc.recoveryPlanOptionalTag,
            step.accessibilityAltForLocale(languageCode),
          ].where((s) => s.isNotEmpty).join('. '),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              '· ${step.nameForLocale(languageCode)}'
              '${step.optional ? ' (${loc.recoveryPlanOptionalTag})' : ''}',
              style: const TextStyle(height: 1.3),
            ),
          ),
        ),
      ),
  ];
}

List<Widget> _pathSteps(
  BuildContext context,
  AppLocalizations loc,
  RecoveryPlan plan,
  List<String> stepIds,
  String languageCode,
) {
  final steps = _resolvedSteps(plan, stepIds);
  if (steps.isEmpty) {
    return [Text(loc.recoveryPlanNoSteps)];
  }
  return [
    for (final step in steps)
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${step.nameForLocale(languageCode)}'
              '${step.optional ? ' (${loc.recoveryPlanOptionalTag})' : ''}',
            ),
            Text(
              step.minimumPathForLocale(languageCode),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              step.accessibilityAltForLocale(languageCode),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
  ];
}

/// Collapsed-by-default detail block; content mounts only when expanded.
class _PlanDetailExpansion extends StatefulWidget {
  const _PlanDetailExpansion({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  State<_PlanDetailExpansion> createState() => _PlanDetailExpansionState();
}

class _PlanDetailExpansionState extends State<_PlanDetailExpansion> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(AppDesignConstants.radiusButton),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppDesignConstants.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 22,
                    color: muted,
                    semanticLabel: widget.title,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 2, bottom: 6),
            child: widget.child,
          ),
        ],
      ],
    );
  }
}
