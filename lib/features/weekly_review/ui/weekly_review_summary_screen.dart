import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../application/weekly_review_controller.dart';
import '../data/weekly_review_controller_provider.dart';
import '../domain/weekly_review_enums.dart';
import '../domain/weekly_review_summary.dart';

/// WRV-02 — deterministic weekly summary; plan unchanged.
class WeeklyReviewSummaryScreen extends ConsumerStatefulWidget {
  const WeeklyReviewSummaryScreen({super.key});

  @override
  ConsumerState<WeeklyReviewSummaryScreen> createState() =>
      _WeeklyReviewSummaryScreenState();
}

class _WeeklyReviewSummaryScreenState
    extends ConsumerState<WeeklyReviewSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = ref.read(weeklyReviewControllerProvider);
      if (c.phase != WeeklyReviewUiPhase.completed || c.summary == null) {
        c.bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final c = ref.watch(weeklyReviewControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Semantics(
          header: true,
          child: Text(loc.v2WeeklySummaryTitle),
        ),
      ),
      body: SafeArea(
        child: WeeklyReviewSummaryBody(controller: c),
      ),
    );
  }
}

@visibleForTesting
class WeeklyReviewSummaryBody extends StatelessWidget {
  const WeeklyReviewSummaryBody({super.key, required this.controller});

  final WeeklyReviewController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final c = controller;

    if (c.phase == WeeklyReviewUiPhase.loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          child: Text(loc.v2WeeklyReviewLoading),
        ),
      );
    }

    final summary = c.summary ?? c.artifact?.summary;
    if (summary == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loc.v2WeeklyReviewNotReadyGeneric,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => context.go(AppRoutes.v2WeeklyReview),
                child: Text(loc.v2WeeklyReviewContinue),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  loc.v2WeeklySummaryOrientation,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.v2WeeklyReviewPeriodLabel(
                  summary.periodStartDayKey,
                  summary.periodEndDayKey,
                ),
              ),
              const SizedBox(height: 20),
              _line(
                context,
                loc.v2WeeklySummaryCompletedDays(
                  summary.completedDayCount.toString(),
                ),
              ),
              _line(
                context,
                loc.v2WeeklySummaryPathMix(_pathLabel(loc, summary)),
              ),
              _line(
                context,
                loc.v2WeeklySummaryPatternHeading,
              ),
              Text(_patternLabel(loc, summary)),
              const SizedBox(height: 12),
              Text(
                loc.v2WeeklySummaryObstacleHeading,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(_obstacleLabel(loc, summary.obstacleResponse)),
              const SizedBox(height: 12),
              Text(
                loc.v2WeeklySummarySupportHeading,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(_supportLabel(loc, summary.supportResponses)),
              const SizedBox(height: 12),
              Text(
                loc.v2WeeklySummaryAttentionHeading,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(_attentionLabel(loc, summary.attentionNext)),
              const SizedBox(height: 12),
              Text(
                _evidenceLabel(loc, summary),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              Semantics(
                liveRegion: true,
                child: Text(
                  loc.v2WeeklySummaryPlanUnchanged,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.v2Today),
                  child: Text(loc.v2WeeklySummaryCtaToday),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _line(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text),
    );
  }

  static String _pathLabel(AppLocalizations loc, WeeklyReviewSummary s) {
    switch (s.pathMixLabel) {
      case PathMixLabel.mostlyMinimum:
        return loc.v2WeeklySummaryPathMostlyMinimum;
      case PathMixLabel.mostlyStandard:
        return loc.v2WeeklySummaryPathMostlyStandard;
      case PathMixLabel.balanced:
        return loc.v2WeeklySummaryPathBalanced;
      case PathMixLabel.singleSessionOnly:
        return loc.v2WeeklySummaryPathSingle;
    }
  }

  static String _patternLabel(AppLocalizations loc, WeeklyReviewSummary s) {
    switch (s.rhythmLabel) {
      case RhythmLabel.steady:
        return loc.v2WeeklySummaryRhythmSteady;
      case RhythmLabel.intermittent:
        return loc.v2WeeklySummaryRhythmIntermittent;
      case RhythmLabel.limitedHistory:
        return loc.v2WeeklySummaryRhythmLimited;
    }
  }

  static String _obstacleLabel(AppLocalizations loc, String value) {
    switch (value) {
      case 'time':
        return loc.v2WeeklyReviewOptTime;
      case 'forgetfulness':
        return loc.v2WeeklyReviewOptForgetfulness;
      case 'low_energy':
        return loc.v2WeeklyReviewOptLowEnergy;
      case 'interruptions':
        return loc.v2WeeklyReviewOptInterruptions;
      case 'unclear_step':
        return loc.v2WeeklyReviewOptUnclearStep;
      case 'access_or_environment':
        return loc.v2WeeklyReviewOptAccessEnv;
      case 'no_major_obstacle':
        return loc.v2WeeklyReviewOptNoMajorObstacle;
      default:
        return value;
    }
  }

  static String _supportLabel(AppLocalizations loc, List<String> values) {
    if (values.isEmpty) return loc.v2WeeklySummarySupportNone;
    return values.map((v) {
      switch (v) {
        case 'shorter_path':
          return loc.v2WeeklyReviewOptShorterPath;
        case 'clearer_timing':
          return loc.v2WeeklyReviewOptClearerTiming;
        case 'quieter_environment':
          return loc.v2WeeklyReviewOptQuieterEnv;
        case 'accessibility_alternative':
          return loc.v2WeeklyReviewOptA11yAlt;
        case 'stronger_reminder':
          return loc.v2WeeklyReviewOptStrongerReminder;
        case 'same_plan_is_working':
          return loc.v2WeeklyReviewOptSamePlan;
        default:
          return v;
      }
    }).join(' · ');
  }

  static String _attentionLabel(AppLocalizations loc, String key) {
    if (key == 'consider_load') return loc.v2WeeklySummaryAttentionLoad;
    if (key == 'consider_support_depth') {
      return loc.v2WeeklySummaryAttentionSupport;
    }
    if (key == 'pause_focus_low') return loc.v2WeeklySummaryAttentionPause;
    if (key == 'maintain_observation') {
      return loc.v2WeeklySummaryAttentionMaintain;
    }
    if (key.startsWith('obstacle_')) {
      return loc.v2WeeklySummaryAttentionObstacle;
    }
    return loc.v2WeeklySummaryAttentionMaintain;
  }

  static String _evidenceLabel(AppLocalizations loc, WeeklyReviewSummary s) {
    switch (s.evidenceDepth) {
      case EvidenceDepth.limited:
        return loc.v2WeeklySummaryEvidenceLimited;
      case EvidenceDepth.developing:
        return loc.v2WeeklySummaryEvidenceDeveloping;
      case EvidenceDepth.sufficientForWeeklySummary:
        return loc.v2WeeklySummaryEvidenceSufficient;
    }
  }
}
