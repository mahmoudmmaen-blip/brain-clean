import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../application/weekly_review_controller.dart';
import '../data/weekly_review_controller_provider.dart';
import '../domain/weekly_activity_facts.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Semantics(
          header: true,
          child: Text(
            loc.v2WeeklySummaryTitle,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
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
    final theme = Theme.of(context);
    final c = controller;

    if (c.phase == WeeklyReviewUiPhase.loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          child: Text(
            loc.v2WeeklyReviewLoading,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final summary = c.summary ?? c.artifact?.summary;
    final facts = c.activityFacts;
    if (summary == null && facts == null) {
      return Padding(
        padding: V2ShellVisual.pagePadding(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loc.v2WeeklyReviewNotReadyGeneric,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppDesignConstants.v2GapSection),
            SizedBox(
              width: double.infinity,
              height: AppDesignConstants.minTouchTarget,
              child: FilledButton(
                style: V2ShellVisual.primaryFilled(),
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
          padding: V2ShellVisual.pagePadding(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              V2PageHeader(
                title: loc.v2WeeklySummaryOrientation,
                subtitle: loc.v2WeeklyReviewPeriodLabel(
                  summary?.periodStartDayKey ?? facts!.startDayKey,
                  summary?.periodEndDayKey ?? facts!.endDayKey,
                ),
              ),
              if (facts != null) ...[
                const SizedBox(height: AppDesignConstants.v2GapSection),
                V2SectionLabel(loc.v2WeeklyFactsSection),
                const SizedBox(height: AppDesignConstants.v2GapSectionLabel),
                _WeeklyFactsCard(facts: facts),
              ],
              if (summary != null) ...[
                const SizedBox(height: AppDesignConstants.v2GapSection),
                _line(
                  loc.v2WeeklySummaryCompletedDays(
                    summary.completedDayCount.toString(),
                  ),
                ),
                _line(
                  loc.v2WeeklySummaryPathMix(_pathLabel(loc, summary)),
                ),
                _line(loc.v2WeeklySummaryPatternHeading),
                Text(
                  _patternLabel(loc, summary),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppDesignConstants.v2GapControl),
                Text(
                  loc.v2WeeklySummaryObstacleHeading,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _obstacleLabel(loc, summary.obstacleResponse),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppDesignConstants.v2GapControl),
                Text(
                  loc.v2WeeklySummarySupportHeading,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _supportLabel(loc, summary.supportResponses),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppDesignConstants.v2GapControl),
                Text(
                  loc.v2WeeklySummaryAttentionHeading,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _attentionLabel(loc, summary.attentionNext),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppDesignConstants.v2GapControl),
                Text(
                  _evidenceLabel(loc, summary),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDesignConstants.v2GapSection),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    loc.v2WeeklySummaryPlanUnchanged,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppDesignConstants.v2GapMajor),
              SizedBox(
                width: double.infinity,
                height: AppDesignConstants.minTouchTarget,
                child: FilledButton(
                  style: V2ShellVisual.primaryFilled(),
                  onPressed: () => context.go(AppRoutes.v2Progress),
                  child: Text(loc.v2WeeklySummaryCtaProgress),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _line(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
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

class _WeeklyFactsCard extends StatelessWidget {
  const _WeeklyFactsCard({required this.facts});

  final WeeklyActivityFacts facts;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return V2HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          V2MetricRow(
            tiles: [
              V2MetricTile(
                label: loc.v2WeeklyFactsTasks,
                value: facts.completedSessions.toString(),
                caption: loc.v2WeeklyFactsTasksCaption(
                  facts.requiredStepsCompleted.toString(),
                ),
              ),
              V2MetricTile(
                label: loc.v2WeeklyFactsStreak,
                value: facts.currentStreak.toString(),
                caption: loc.v2WeeklyFactsStreakCaption(
                  facts.currentStreak.toString(),
                  facts.longestStreak.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignConstants.v2GapSection),
          V2MetricTile(
            label: loc.v2WeeklyFactsAdherence,
            value: '${facts.adherencePercent}%',
            caption: loc.v2WeeklyFactsAdherenceCaption(
              facts.completedDays.toString(),
            ),
          ),
        ],
      ),
    );
  }
}
