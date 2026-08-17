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

/// ONB-09 — Today preview only (not the SES daily-session player).
class PlanTodayPreviewScreen extends ConsumerStatefulWidget {
  const PlanTodayPreviewScreen({super.key, this.planId});

  final String? planId;

  @override
  ConsumerState<PlanTodayPreviewScreen> createState() =>
      _PlanTodayPreviewScreenState();
}

class _PlanTodayPreviewScreenState extends ConsumerState<PlanTodayPreviewScreen> {
  RecoveryPlan? _plan;
  var _loading = true;
  String? _errorKey;

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
      await onboarding.markTodayPreviewed(planId: plan.id);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _plan = null;
        _errorKey = 'generation_error';
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
        title: Text(loc.v2TodayPreviewTitle),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: PlanTodayPreviewBody(
          loc: loc,
          languageCode: isAr ? 'ar' : 'en',
          loading: _loading,
          errorKey: _errorKey,
          plan: _plan,
          onRetry: _load,
          onRebuildPlan: () => context.go(AppRoutes.v2PlanBuilding),
          onContinue: () {
            final id = _plan?.id ?? widget.planId ?? '';
            context.go('${AppRoutes.v2PlanTodayReady}?plan=$id');
          },
        ),
      ),
    );
  }
}

/// Sync-testable ONB-09 body.
class PlanTodayPreviewBody extends StatelessWidget {
  const PlanTodayPreviewBody({
    super.key,
    required this.loc,
    required this.languageCode,
    required this.loading,
    required this.errorKey,
    required this.plan,
    required this.onRetry,
    required this.onRebuildPlan,
    required this.onContinue,
  });

  final AppLocalizations loc;
  final String languageCode;
  final bool loading;
  final String? errorKey;
  final RecoveryPlan? plan;
  final VoidCallback onRetry;
  final VoidCallback onRebuildPlan;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          label: loc.v2TodayPreviewLoading,
          child: Text(loc.v2TodayPreviewLoading),
        ),
      );
    }

    if (errorKey != null || plan == null) {
      final message = switch (errorKey) {
        'missing_plan' => loc.recoveryPlanMissing,
        'missing_today_act' => loc.v2TodayPreviewMissingAct,
        'unsupported_version' => loc.recoveryPlanUnsupportedVersion,
        _ => loc.recoveryPlanGenerationError,
      };
      final primary = errorKey == 'missing_plan' ||
              errorKey == 'missing_today_act' ||
              errorKey == 'unsupported_version'
          ? onRebuildPlan
          : onRetry;
      final primaryLabel = errorKey == 'missing_plan' ||
              errorKey == 'missing_today_act' ||
              errorKey == 'unsupported_version'
          ? loc.recoveryPlanBuildCta
          : loc.recoveryPlanRetry;
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
                onPressed: primary,
                child: Text(primaryLabel),
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
            child: Text(
              loc.v2TodayPreviewHeading,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Text(loc.v2TodayPreviewOrientation),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            label: '${loc.v2TodayPreviewActHeading}: $title',
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: timeLabel,
            child: Text(timeLabel),
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
          const SizedBox(height: 16),
          Text(loc.v2TodayPreviewCompletionMeaning),
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
              child: Text(loc.v2TodayPreviewContinueCta),
            ),
          ),
        ],
      ),
    );
  }
}
