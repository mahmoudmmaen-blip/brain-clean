import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../v2_onboarding/data/v2_onboarding_repository_provider.dart';
import '../data/recovery_plan_repository_provider.dart';
import '../domain/recovery_plan.dart';
import '../domain/recovery_plan_versions.dart';
import '../domain/today_act_presentation.dart';

/// Temporary Today-ready boundary — session player is a later slice (ONB-10).
class PlanTodayReadyBoundaryScreen extends ConsumerStatefulWidget {
  const PlanTodayReadyBoundaryScreen({super.key, this.planId});

  final String? planId;

  @override
  ConsumerState<PlanTodayReadyBoundaryScreen> createState() =>
      _PlanTodayReadyBoundaryScreenState();
}

class _PlanTodayReadyBoundaryScreenState
    extends ConsumerState<PlanTodayReadyBoundaryScreen> {
  RecoveryPlan? _plan;
  var _loading = true;
  String? _errorKey;
  var _journeyMarked = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorKey = null;
    });
    try {
      final repo = ref.read(recoveryPlanRepositoryProvider);
      RecoveryPlan? plan;
      if (widget.planId != null && widget.planId!.isNotEmpty) {
        plan = await repo.findById(widget.planId!);
      }
      plan ??= await repo.active();
      if (!mounted) return;
      if (plan == null) {
        setState(() {
          _plan = null;
          _errorKey = 'missing_plan';
          _loading = false;
        });
        return;
      }
      if (plan.schemaVersion.isEmpty) {
        setState(() {
          _plan = plan;
          _errorKey = 'corrupt_plan';
          _loading = false;
        });
        return;
      }
      if (plan.schemaVersion != RecoveryPlanVersions.schema) {
        setState(() {
          _plan = plan;
          _errorKey = 'unsupported_version';
          _loading = false;
        });
        return;
      }
      final today = plan.dayTemplate.todayPreview;
      if (today.id.isEmpty) {
        setState(() {
          _plan = plan;
          _errorKey = 'missing_today_act';
          _loading = false;
        });
        return;
      }

      final onboarding = ref.read(v2OnboardingControllerProvider);
      if (!onboarding.state.todayPreviewed) {
        await onboarding.markTodayPreviewed(planId: plan.id);
      }
      await onboarding.markJourneyCompleted(planId: plan.id);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _journeyMarked = true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _plan = null;
        _errorKey = 'persistence_failed';
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
      body: SafeArea(
        child: PlanTodayReadyBody(
          loc: loc,
          languageCode: isAr ? 'ar' : 'en',
          loading: _loading,
          errorKey: _errorKey,
          plan: _plan,
          journeyMarked: _journeyMarked,
          onRetry: _load,
          onRebuildPlan: () => context.go(AppRoutes.v2PlanBuilding),
          onStay: () {
            context.go(AppRoutes.v2Today);
          },
          onOpenPreview: () {
            final id = _plan?.id ?? widget.planId ?? '';
            context.go('${AppRoutes.v2PlanTodayPreview}?plan=$id');
          },
        ),
      ),
    );
  }
}

/// Sync-testable Today-ready body.
class PlanTodayReadyBody extends StatelessWidget {
  const PlanTodayReadyBody({
    super.key,
    required this.loc,
    required this.languageCode,
    required this.loading,
    required this.errorKey,
    required this.plan,
    required this.journeyMarked,
    required this.onRetry,
    required this.onRebuildPlan,
    required this.onStay,
    required this.onOpenPreview,
  });

  final AppLocalizations loc;
  final String languageCode;
  final bool loading;
  final String? errorKey;
  final RecoveryPlan? plan;
  final bool journeyMarked;
  final VoidCallback onRetry;
  final VoidCallback onRebuildPlan;
  final VoidCallback onStay;
  final VoidCallback onOpenPreview;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          label: loc.v2TodayReadyLoading,
          child: Text(loc.v2TodayReadyLoading),
        ),
      );
    }

    if (errorKey != null || plan == null) {
      final message = switch (errorKey) {
        'missing_plan' => loc.recoveryPlanMissing,
        'corrupt_plan' => loc.v2TodayReadyCorruptPlan,
        'unsupported_version' => loc.recoveryPlanUnsupportedVersion,
        'missing_today_act' => loc.v2TodayPreviewMissingAct,
        'persistence_failed' => loc.v2TodayReadyPersistFailed,
        _ => loc.recoveryPlanGenerationError,
      };
      final useRebuild = errorKey == 'missing_plan' ||
          errorKey == 'corrupt_plan' ||
          errorKey == 'unsupported_version' ||
          errorKey == 'missing_today_act';
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              header: true,
              liveRegion: true,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: useRebuild ? onRebuildPlan : onRetry,
                child: Text(
                  useRebuild ? loc.recoveryPlanBuildCta : loc.recoveryPlanRetry,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final p = plan!;
    final today = p.dayTemplate.todayPreview;
    final title = resolveTodayActTitle(p, languageCode) ??
        loc.v2TodayPreviewFallbackTitle;
    final timeLabel = loc.recoveryPlanTimeRange(
      '${today.estimatedMinutesMin}',
      '${today.estimatedMinutesMax}',
    );
    final minLabels = resolveTodayMinimumPathLabels(p, languageCode);
    final because = today.because.forLocale(languageCode);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            liveRegion: true,
            child: Text(
              loc.v2TodayReadyFirstStepTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.v2TodayReadyFirstStepBody,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Semantics(
            header: true,
            label: '${loc.v2TodayPreviewActHeading}: $title',
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: timeLabel,
            child: Text(
              timeLabel,
              textAlign: TextAlign.center,
            ),
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
          if (minLabels.isEmpty)
            Text(loc.recoveryPlanNoSteps)
          else
            ...minLabels.map(
              (label) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Semantics(
                  label: '${loc.recoveryPlanMinimumPath}: $label',
                  child: Text(label),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              loc.v2TodayPreviewBecauseHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: '${loc.v2TodayPreviewBecauseHeading}: $because',
            child: Text(because),
          ),
          const SizedBox(height: 12),
          Text(
            journeyMarked
                ? loc.v2TodayReadyJourneySaved
                : loc.v2TodayReadyProgressSaved,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: onStay,
              child: Text(loc.v2TodayReadyPrimaryCta),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: onOpenPreview,
              child: Text(loc.v2TodayReadyReviewPreview),
            ),
          ),
        ],
      ),
    );
  }
}
