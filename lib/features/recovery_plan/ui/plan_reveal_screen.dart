import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../brain_profile/domain/measurement_confidence.dart';
import '../data/recovery_plan_repository_provider.dart';
import '../domain/recovery_plan.dart';
import '../domain/recovery_plan_intensity.dart';
import '../domain/recovery_plan_status.dart';

/// PLN-01 — calm Recovery Plan reveal + TodayAct preview.
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

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _missing = false;
    });
    try {
      final repo = ref.read(recoveryPlanRepositoryProvider);
      RecoveryPlan? plan;
      if (widget.planId != null && widget.planId!.isNotEmpty) {
        plan = await repo.findById(widget.planId!);
      }
      plan ??= await repo.active();
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
          onGoHome: () => context.go(AppRoutes.home),
          onContinue: () {
            final id = _plan?.id ?? '';
            context.go('${AppRoutes.v2PlanTodayReady}?plan=$id');
          },
          onRebuild: () => context.go(AppRoutes.v2PlanBuilding),
        ),
      ),
    );
  }
}

/// Sync-testable PLN-01 body.
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
  });

  final AppLocalizations loc;
  final String languageCode;
  final bool loading;
  final bool missing;
  final RecoveryPlan? plan;
  final VoidCallback onGoHome;
  final VoidCallback onContinue;
  final VoidCallback onRebuild;

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
      return Padding(
        padding: const EdgeInsets.all(24),
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
              height: 48,
              child: FilledButton(
                onPressed: onRebuild,
                child: Text(loc.recoveryPlanBuildCta),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onGoHome,
                child: Text(loc.recoveryPlanGoHome),
              ),
            ),
          ],
        ),
      );
    }

    final p = plan!;
    final expl = p.explanation;
    final today = p.dayTemplate.todayPreview;
    final isStarter =
        p.isStarterFallback ||
        p.generationStatus == RecoveryPlanStatus.starterFallback;
    final confidenceLabel = switch (p.confidence) {
      MeasurementConfidence.provisional => loc.brainProfileConfidenceProvisional,
      MeasurementConfidence.moderate => loc.brainProfileConfidenceModerate,
      MeasurementConfidence.strong => loc.brainProfileConfidenceSolid,
    };
    final timeLabel = loc.recoveryPlanTimeRange(
      '${p.cadence.minPathMinutesMin}',
      '${p.cadence.standardPathMinutesMax}',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            child: Text(
              loc.recoveryPlanMainFocus,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Text(expl.mainFocusForLocale(languageCode)),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              loc.recoveryPlanPrioritiesHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          if (p.priority.priorities.isEmpty)
            Text(loc.recoveryPlanNoPriorities)
          else
            ...p.priority.priorities.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Semantics(
                  label:
                      '${loc.recoveryPlanPrioritiesHeading}: ${d.titleForLocale(languageCode)}',
                  child: Text(d.titleForLocale(languageCode)),
                ),
              ),
            ),
          if (p.priority.strongerDomainId != null) ...[
            const SizedBox(height: 8),
            Semantics(
              header: true,
              child: Text(
                loc.recoveryPlanStrongerHeading,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(p.priority.strongerTitleForLocale(languageCode)),
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
            '${loc.recoveryPlanIntensityLabel}: ${p.intensity.labelForLocale(languageCode)}',
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
          ..._pathSteps(context, p, today.minimumPathStepIds, languageCode),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              loc.recoveryPlanStandardPath,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          ..._pathSteps(context, p, today.standardPathStepIds, languageCode),
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
          Text(today.because.forLocale(languageCode)),
          const SizedBox(height: 8),
          Text(
            loc.recoveryPlanSkipHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: onContinue,
              child: Text(loc.recoveryPlanContinueToday),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _pathSteps(
    BuildContext context,
    RecoveryPlan plan,
    List<String> stepIds,
    String languageCode,
  ) {
    final byId = {for (final s in plan.steps) s.stepId: s};
    final widgets = <Widget>[];
    for (final id in stepIds) {
      final step = byId[id];
      if (step == null) continue;
      final optionalTag =
          step.optional ? ' (${loc.recoveryPlanOptionalTag})' : '';
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${step.nameForLocale(languageCode)}$optionalTag'),
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
      );
    }
    if (widgets.isEmpty) {
      widgets.add(Text(loc.recoveryPlanNoSteps));
    }
    return widgets;
  }
}
