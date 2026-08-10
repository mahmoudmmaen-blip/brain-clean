import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../brain_profile/domain/measurement_confidence.dart';
import '../../v2_onboarding/data/v2_onboarding_repository_provider.dart';
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

      // First-time reveal still marks PLN-01. Skip redundant writes on shell.
      if (plan != null && !shellMode) {
        await onboarding.markPlanRevealed(planId: plan.id);
      }

      if (!mounted) return;
      setState(() {
        _plan = plan;
        _missing = plan == null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _plan = null;
        _missing = true;
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
      ),
      body: SafeArea(
        child: PlanRevealBody(
          loc: loc,
          languageCode: isAr ? 'ar' : 'en',
          loading: _loading,
          missing: _missing,
          plan: _plan,
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
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight > 48 ? constraints.maxHeight - 48 : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      loc.recoveryPlanMissing,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: AppDesignConstants.minTouchTarget,
                    child: FilledButton(
                      onPressed: onRebuild,
                      child: Text(loc.recoveryPlanBuildCta),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: AppDesignConstants.minTouchTarget,
                    child: OutlinedButton(
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
    final actTitle = resolveTodayActTitle(plan, languageCode) ??
        loc.v2TodayPreviewFallbackTitle;
    final minSteps = _resolvedSteps(plan, today.minimumPathStepIds);
    final stdSteps = _resolvedSteps(plan, today.standardPathStepIds);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1–2 Program thesis (dominant)
          if (isStarter) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                loc.recoveryPlanStarterBadge,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Semantics(
            header: true,
            label:
                '${loc.recoveryPlanMainFocus}: ${expl.mainFocusForLocale(languageCode)}',
            child: Text(
              loc.recoveryPlanMainFocus,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            expl.mainFocusForLocale(languageCode),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.recoveryPlanCalmOrientationBody,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),

          // 3 Support context
          const SizedBox(height: 24),
          Text(
            loc.recoveryPlanPrioritiesHeading,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (plan.priority.priorities.isEmpty)
            Text(
              loc.recoveryPlanNoPriorities,
              style: theme.textTheme.bodyMedium,
            )
          else
            ...plan.priority.priorities.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '· ${d.titleForLocale(languageCode)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          if (plan.priority.strongerDomainId != null) ...[
            const SizedBox(height: 12),
            Text(
              loc.recoveryPlanStrongerHeading,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              plan.priority.strongerTitleForLocale(languageCode),
              style: theme.textTheme.bodyMedium,
            ),
          ],

          // 4 Daily shape
          const SizedBox(height: 24),
          Text(
            loc.recoveryPlanTimeHeading,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Semantics(
            label:
                '$timeLabel. ${loc.recoveryPlanIntensityLabel}: ${plan.intensity.labelForLocale(languageCode)}',
            child: Text(
              '$timeLabel · ${plan.intensity.labelForLocale(languageCode)}',
              style: theme.textTheme.bodyLarge,
            ),
          ),

          // 5 Today's place (orientation only)
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text(
              loc.recoveryPlanTodayFitHeading,
              style: theme.textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            actTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            today.because.forLocale(languageCode),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          // 6 Depth — paths + trust (true progressive disclosure)
          const SizedBox(height: 20),
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
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                ..._compactPathNames(loc, languageCode, minSteps),
                const SizedBox(height: 12),
                Text(
                  loc.recoveryPlanStandardPath,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
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
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(line, style: theme.textTheme.bodyMedium),
                      ),
                    ),
                Text(
                  expl.nonMedicalForLocale(languageCode),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  expl.whyMayChangeForLocale(languageCode),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.recoveryPlanSkipHint,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // 7 Soft navigation to shell Today (not session execution)
          const SizedBox(height: 28),
          SizedBox(
            height: AppDesignConstants.minTouchTarget,
            child: OutlinedButton(
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
        padding: const EdgeInsets.only(bottom: 6),
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: theme.textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(widget.subtitle, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    semanticLabel: widget.title,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 4),
          widget.child,
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
