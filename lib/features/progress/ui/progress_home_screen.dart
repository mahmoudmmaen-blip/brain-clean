import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/glow_progress.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../../weekly_review/domain/weekly_review_enums.dart';
import '../../weekly_review/domain/weekly_review_summary.dart';
import '../application/progress_experience_controller.dart';
import '../data/progress_experience_controller_provider.dart';
import '../domain/progress_experience_enums.dart';
import '../domain/progress_timeline.dart';
import '../domain/progress_view_model.dart';
import '../domain/progress_weekly_bar_day.dart';
import 'progress_pillar_section.dart';

/// Vertical rhythm for Progress — shared V2 tokens (hierarchy unchanged).
const double _kGapHeadlineSupport = AppDesignConstants.v2GapTight;
const double _kGapToMovement = AppDesignConstants.v2GapSection;
const double _kGapMovementEvidence = AppDesignConstants.v2GapControl;
const double _kGapBeforeCta = AppDesignConstants.v2GapMajor;
const double _kGapAfterCta = AppDesignConstants.v2GapSection;
const double _kGapBeforeReview = AppDesignConstants.v2GapSection;
const double _kGapBeforeReports = AppDesignConstants.v2GapControl;

/// PRG-01 — words-first Progress proof experience + Weekly Review entry.
///
/// Locked hierarchy (Phase A):
/// identity → direction headline → compact movement → next action →
/// progressive pattern/history → contextual Weekly Review → quiet Reports.
class ProgressHomeScreen extends ConsumerStatefulWidget {
  const ProgressHomeScreen({super.key});

  @override
  ConsumerState<ProgressHomeScreen> createState() => _ProgressHomeScreenState();
}

class _ProgressHomeScreenState extends ConsumerState<ProgressHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressExperienceControllerProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final c = ref.watch(progressExperienceControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ProgressHomeBody(
          controller: c,
          onRetry: () => c.load(),
        ),
      ),
    );
  }
}

@visibleForTesting
class ProgressHomeBody extends StatelessWidget {
  const ProgressHomeBody({
    super.key,
    required this.controller,
    required this.onRetry,
  });

  final ProgressExperienceController controller;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = AppColors.textSecondary;
    final c = controller;

    if (c.phase == ProgressExperiencePhase.loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          child: Text(
            loc.v2ProgressLoading,
            style: V2ShellVisual.bodyMuted(theme),
          ),
        ),
      );
    }

    if (c.phase == ProgressExperiencePhase.persistenceFailed ||
        c.phase == ProgressExperiencePhase.unsupported) {
      return _Pad(
        title: loc.v2ProgressPersistFailed,
        cta: loc.v2ProgressRetry,
        onCta: onRetry,
      );
    }

    final vm = c.viewModel;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: V2ShellVisual.pagePadding(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              V2PageHeader(
                title: loc.v2ProgressTitle,
                subtitle: loc.v2ProgressOrientation,
              ),
              const SizedBox(height: AppDesignConstants.v2GapSection),
              V2HeroCard(
                child: vm.isEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Semantics(
                            header: true,
                            liveRegion: true,
                            child: Text(
                              _headline(loc, vm.proofHeadline),
                              style: V2ShellVisual.heroTitle(theme),
                            ),
                          ),
                          const SizedBox(height: _kGapHeadlineSupport),
                          Text(
                            loc.v2ProgressBasedOnSessions,
                            style: V2ShellVisual.captionMuted(theme),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: DecoratedBox(
                                        decoration:
                                            V2ShellVisual.mintTagDecoration(Theme.of(context)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          child: Text(
                                            loc.v2ProgressStatsRate,
                                            style: V2ShellVisual.mintTagLabel(
                                              theme,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Semantics(
                                      header: true,
                                      liveRegion: true,
                                      child: Text(
                                        _headline(loc, vm.proofHeadline),
                                        style: V2ShellVisual.heroTitle(theme),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: _kGapHeadlineSupport),
                                    Text(
                                      loc.v2ProgressBasedOnSessions,
                                      style: V2ShellVisual.captionMuted(theme),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: AppDesignConstants.v2GapSection,
                              ),
                              _CompletionRing(
                                percent: vm.completionRatePercent,
                                centerLabel:
                                    '${vm.completionRatePercent}%',
                                centerCaption: loc.v2ProgressStatsRate,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          GlowProgressBar(
                            progress: vm.completionRatePercent / 100,
                            height: 7,
                          ),
                        ],
                      ),
              ),
              if (vm.isEmpty) ...[
                const SizedBox(height: _kGapToMovement),
                V2InfoCard(
                  child: Text(
                    loc.v2ProgressEmptyBody,
                    style: V2ShellVisual.bodyMuted(theme),
                  ),
                ),
              ] else ...[
                const SizedBox(height: _kGapToMovement),
                V2InfoCard(
                  child: V2MetricRow(
                    tiles: [
                      V2MetricTile(
                        label: loc.v2ProgressBetterHeading,
                        value: vm.completedDays.toString(),
                        caption: loc.v2ProgressCompletedDays(
                          vm.completedDays.toString(),
                        ),
                      ),
                      V2MetricTile(
                        label: loc.v2ProgressStatsSessions,
                        value: vm.totalCompletedSessions.toString(),
                        caption: loc.v2ProgressCompletedSessions(
                          vm.totalCompletedSessions.toString(),
                        ),
                      ),
                    ],
                  ),
                ),
                if (vm.pathMixHint != null) ...[
                  const SizedBox(height: _kGapMovementEvidence),
                  Text(
                    _mix(loc, vm.pathMixHint!),
                    style: V2ShellVisual.captionMuted(theme),
                  ),
                ],
                const SizedBox(height: AppDesignConstants.v2GapTight),
                Text(
                  loc.v2ProgressCurrentRhythm(vm.currentRhythmDays),
                  style: V2ShellVisual.captionMuted(theme),
                ),
                const SizedBox(height: _kGapMovementEvidence),
                Text(
                  _evidence(loc, vm.evidenceDepth),
                  style: V2ShellVisual.captionMuted(theme),
                ),
              ],
              // 4 Contextual next action — early, before history density
              const SizedBox(height: _kGapBeforeCta),
              _PrimaryCta(vm: vm),
              if (!vm.isEmpty) ...[
                const SizedBox(height: _kGapAfterCta),
                _WeeklyChartCard(bars: vm.weeklyBars),
                const SizedBox(height: AppDesignConstants.v2GapSection),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border.withValues(alpha: 0.35),
                ),
                const SizedBox(height: 2),
                // 5–6 Progressive pattern + history
                _DetailExpansion(
                  title: loc.v2ProgressPatternDetails,
                  subtitle: _patternSubtitle(loc, vm),
                  child: _PatternDetails(vm: vm),
                ),
                if (vm.recentTimeline.isNotEmpty)
                  _DetailExpansion(
                    title: loc.v2ProgressRecentActivity,
                    subtitle: vm.lastCompletedDayKey ??
                        loc.v2ProgressCompletedDays(
                            vm.completedDays.toString()),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final e in vm.recentTimeline)
                          _TimelineRow(entry: e),
                      ],
                    ),
                  ),
                if (vm.showScoreRow) ...[
                  const SizedBox(height: AppDesignConstants.v2GapTight),
                  _ScoreRow(vm: vm, muted: muted),
                ],
              ],
              // 7 Weekly Review — emphasis only when actionable
              const SizedBox(height: _kGapBeforeReview),
              _ReviewEntry(vm: vm),
              if (vm.weeklySummaryPreview != null) ...[
                const SizedBox(height: AppDesignConstants.v2GapControl),
                _WeeklyPreview(
                  summary: vm.weeklySummaryPreview!,
                  showSummaryCta: vm.primaryDestination !=
                      ProgressNextDestination.weeklyReviewSummary,
                ),
              ],
              // 8 Quiet secondary exit to Reports
              const SizedBox(height: _kGapBeforeReports),
              const ProgressPillarSection(),
              const SizedBox(height: _kGapBeforeReports),
              SizedBox(
                height: AppDesignConstants.minTouchTarget,
                child: OutlinedButton(
                  style: V2ShellVisual.secondaryOutlined(),
                  onPressed: () => context.go(AppRoutes.v2Reports),
                  child: Text(loc.v2ProgressReportsEntry),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _patternSubtitle(AppLocalizations loc, ProgressViewModel vm) {
    final mix = vm.pathMixHint;
    if (mix != null) return _mix(loc, mix);
    return loc.v2ProgressCompletionRate(vm.completionRatePercent.toString());
  }

  static String _mix(AppLocalizations loc, PathMixLabel mix) {
    switch (mix) {
      case PathMixLabel.mostlyMinimum:
        return loc.v2ProgressPathMostlyMinimum;
      case PathMixLabel.mostlyStandard:
        return loc.v2ProgressPathMostlyStandard;
      case PathMixLabel.balanced:
        return loc.v2ProgressPathBalanced;
      case PathMixLabel.singleSessionOnly:
        return loc.v2ProgressPathSingle;
    }
  }

  static String _headline(AppLocalizations loc, ProgressProofHeadline h) {
    switch (h) {
      case ProgressProofHeadline.empty:
        return loc.v2ProgressHeadlineEmpty;
      case ProgressProofHeadline.firstSession:
        return loc.v2ProgressHeadlineFirst;
      case ProgressProofHeadline.fewDays:
        return loc.v2ProgressHeadlineFew;
      case ProgressProofHeadline.rhythmBeginning:
        return loc.v2ProgressHeadlineRhythm;
      case ProgressProofHeadline.steadierPattern:
        return loc.v2ProgressHeadlineSteady;
      case ProgressProofHeadline.limitedHistory:
        return loc.v2ProgressHeadlineLimited;
      case ProgressProofHeadline.weeklyEvidenceAvailable:
        return loc.v2ProgressHeadlineWeekly;
    }
  }

  static String _evidence(AppLocalizations loc, ProgressEvidenceDepth d) {
    switch (d) {
      case ProgressEvidenceDepth.empty:
        return loc.v2ProgressEvidenceEmpty;
      case ProgressEvidenceDepth.limited:
        return loc.v2ProgressEvidenceLimited;
      case ProgressEvidenceDepth.developing:
        return loc.v2ProgressEvidenceDeveloping;
      case ProgressEvidenceDepth.sufficient:
        return loc.v2ProgressEvidenceSufficient;
    }
  }
}

class _PatternDetails extends StatelessWidget {
  const _PatternDetails({required this.vm});
  final ProgressViewModel vm;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = AppColors.textSecondary;
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: muted,
      height: 1.4,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.v2ProgressWhyHeading,
          style: theme.textTheme.labelMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 4),
        Text(loc.v2ProgressMinimumPath(vm.minimumPathCount.toString()),
            style: valueStyle),
        Text(loc.v2ProgressStandardPath(vm.standardPathCount.toString()),
            style: valueStyle),
        Text(
          loc.v2ProgressCompletionRate(vm.completionRatePercent.toString()),
          style: valueStyle,
        ),
        const SizedBox(height: 10),
        Text(
          loc.v2ProgressComparedHeading,
          style: theme.textTheme.labelMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 4),
        Text(loc.v2ProgressLongestRhythm(vm.longestRhythmDays),
            style: valueStyle),
        if (vm.firstCompletedDayKey != null)
          Text(loc.v2ProgressFirstCompleted(vm.firstCompletedDayKey!),
              style: valueStyle),
        if (vm.lastCompletedDayKey != null)
          Text(loc.v2ProgressLastCompleted(vm.lastCompletedDayKey!),
              style: valueStyle),
      ],
    );
  }
}

class _DetailExpansion extends StatefulWidget {
  const _DetailExpansion({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  State<_DetailExpansion> createState() => _DetailExpansionState();
}

class _DetailExpansionState extends State<_DetailExpansion> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = AppColors.textSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
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
        ),
        if (_expanded) ...[
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 2, bottom: 8),
            child: widget.child,
          ),
        ],
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry});
  final ProgressTimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = AppColors.textSecondary;
    final path = entry.usedMinimumPath && entry.usedStandardPath
        ? loc.v2ProgressTimelineBothPaths
        : entry.usedStandardPath
            ? loc.v2ProgressTimelineStandard
            : loc.v2ProgressTimelineMinimum;
    return Semantics(
      label: loc.v2ProgressTimelineEntry(entry.dayKey, path),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          loc.v2ProgressTimelineEntry(entry.dayKey, path),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: muted,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.vm, required this.muted});
  final ProgressViewModel vm;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final valueText = vm.scoreDisplayValue != null
        ? loc.v2ProgressScoreValue(vm.scoreDisplayValue.toString())
        : loc.v2ProgressScoreUnavailable;
    final quiet = theme.textTheme.bodySmall?.copyWith(
      color: muted,
      height: 1.4,
    );
    return Semantics(
      container: true,
      label: loc.v2ProgressScoreHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.v2ProgressScoreHeading,
            style: theme.textTheme.labelMedium?.copyWith(color: muted),
          ),
          const SizedBox(height: 6),
          Text(valueText, style: quiet),
          if (vm.scoreMeasuredDayKey != null)
            Text(
              loc.v2ProgressScoreMeasured(vm.scoreMeasuredDayKey!),
              style: quiet,
            ),
          const SizedBox(height: 4),
          Text(loc.v2ProgressScoreDisclaimer, style: quiet),
        ],
      ),
    );
  }
}

class _ReviewEntry extends StatelessWidget {
  const _ReviewEntry({required this.vm});
  final ProgressViewModel vm;

  bool get _actionable {
    switch (vm.weeklyReviewCardState) {
      case ProgressWeeklyReviewCardState.available:
      case ProgressWeeklyReviewCardState.draftInProgress:
      case ProgressWeeklyReviewCardState.completed:
      case ProgressWeeklyReviewCardState.summaryAvailable:
        return true;
      default:
        return false;
    }
  }

  /// Primary CTA already carries Start/Continue/Summary when due —
  /// avoid a second competing Weekly action button.
  bool get _primaryCoversWeeklyAction {
    switch (vm.primaryDestination) {
      case ProgressNextDestination.weeklyReviewQuestions:
      case ProgressNextDestination.weeklyReviewSummary:
        return true;
      case ProgressNextDestination.today:
      case ProgressNextDestination.none:
        return false;
    }
  }

  bool get _showPeriod {
    // When there is not enough activity, period metadata adds noise.
    return vm.weeklyReviewCardState !=
            ProgressWeeklyReviewCardState.notEnoughActivity &&
        vm.weeklyPeriodStartDayKey != null &&
        vm.weeklyPeriodEndDayKey != null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = AppColors.textSecondary;
    final state = vm.weeklyReviewCardState;
    final route = _routeFor(state);
    final cta = _ctaFor(loc, state);
    final showInlineCta =
        route != null && cta != null && !_primaryCoversWeeklyAction;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.v2ProgressWeeklyReviewHeading,
          style: _actionable
              ? theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                )
              : theme.textTheme.labelMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 6),
        Text(
          _statusText(loc, vm),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: _actionable ? null : muted,
            height: 1.35,
          ),
        ),
        if (_showPeriod) ...[
          const SizedBox(height: 4),
          Text(
            loc.v2WeeklyReviewPeriodLabel(
              vm.weeklyPeriodStartDayKey!,
              vm.weeklyPeriodEndDayKey!,
            ),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
        if (vm.daysUntilWeeklyReviewUnlock != null &&
            vm.daysUntilWeeklyReviewUnlock! > 0) ...[
          const SizedBox(height: AppDesignConstants.v2GapControl),
          SizedBox(
            width: double.infinity,
            height: AppDesignConstants.minTouchTarget,
            child: OutlinedButton(
              style: V2ShellVisual.secondaryOutlined(theme),
              onPressed: null,
              child: Text(
                loc.v2ProgressWrAvailableInDays(
                  vm.daysUntilWeeklyReviewUnlock!,
                ),
              ),
            ),
          ),
        ] else if (showInlineCta) ...[
          const SizedBox(height: AppDesignConstants.v2GapControl),
          SizedBox(
            width: double.infinity,
            height: AppDesignConstants.minTouchTarget,
            child: OutlinedButton(
              style: V2ShellVisual.secondaryOutlined(theme),
              onPressed: () => context.go(route),
              child: Text(cta),
            ),
          ),
        ],
      ],
    );

    return Semantics(
      container: true,
      liveRegion: true,
      label: loc.v2ProgressWeeklyReviewHeading,
      child: _actionable ? V2TonalSurface(child: content) : content,
    );
  }

  static String _statusText(
    AppLocalizations loc,
    ProgressViewModel vm,
  ) {
    final days = vm.daysUntilWeeklyReviewUnlock;
    if (days != null && days > 0) {
      return loc.v2ProgressWrAvailableInDays(days);
    }
    switch (vm.weeklyReviewCardState) {
      case ProgressWeeklyReviewCardState.notEnoughActivity:
        return loc.v2ProgressWrNotEnough;
      case ProgressWeeklyReviewCardState.currentWeekInProgress:
        return loc.v2ProgressWrCurrentWeek;
      case ProgressWeeklyReviewCardState.available:
        return loc.v2ProgressWrAvailable;
      case ProgressWeeklyReviewCardState.draftInProgress:
        return loc.v2ProgressWrDraft;
      case ProgressWeeklyReviewCardState.completed:
      case ProgressWeeklyReviewCardState.summaryAvailable:
        return loc.v2ProgressWrCompleted;
      case ProgressWeeklyReviewCardState.unsupportedVersion:
        return loc.v2ProgressWrUnsupported;
      case ProgressWeeklyReviewCardState.missingReferences:
        return loc.v2ProgressWrMissingRefs;
      case ProgressWeeklyReviewCardState.error:
        return loc.v2ProgressWrError;
    }
  }

  static String? _ctaFor(
    AppLocalizations loc,
    ProgressWeeklyReviewCardState state,
  ) {
    switch (state) {
      case ProgressWeeklyReviewCardState.available:
        return loc.v2ProgressWrCtaStart;
      case ProgressWeeklyReviewCardState.draftInProgress:
        return loc.v2ProgressWrCtaContinue;
      case ProgressWeeklyReviewCardState.completed:
      case ProgressWeeklyReviewCardState.summaryAvailable:
        return loc.v2ProgressWrCtaSummary;
      default:
        return null;
    }
  }

  static String? _routeFor(ProgressWeeklyReviewCardState state) {
    switch (state) {
      case ProgressWeeklyReviewCardState.available:
      case ProgressWeeklyReviewCardState.draftInProgress:
        return AppRoutes.v2WeeklyReview;
      case ProgressWeeklyReviewCardState.completed:
      case ProgressWeeklyReviewCardState.summaryAvailable:
        return AppRoutes.v2WeeklyReviewSummary;
      default:
        return null;
    }
  }
}

class _WeeklyPreview extends StatelessWidget {
  const _WeeklyPreview({
    required this.summary,
    required this.showSummaryCta,
  });
  final WeeklyReviewSummary summary;
  final bool showSummaryCta;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = AppColors.textSecondary;
    final quiet = theme.textTheme.bodySmall?.copyWith(
      color: muted,
      height: 1.35,
    );
    return Semantics(
      container: true,
      label: loc.v2ProgressWeeklyPreviewHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.v2ProgressWeeklyPreviewHeading,
            style: theme.textTheme.labelMedium?.copyWith(color: muted),
          ),
          const SizedBox(height: 6),
          Text(
            loc.v2WeeklyReviewPeriodLabel(
              summary.periodStartDayKey,
              summary.periodEndDayKey,
            ),
            style: quiet,
          ),
          Text(
            loc.v2WeeklySummaryCompletedDays(
              summary.completedDayCount.toString(),
            ),
            style: quiet,
          ),
          Text(_path(loc, summary.pathMixLabel), style: quiet),
          Text(_rhythm(loc, summary.rhythmLabel), style: quiet),
          Text(loc.v2WeeklySummaryPlanUnchanged, style: quiet),
          if (showSummaryCta) ...[
            const SizedBox(height: AppDesignConstants.v2GapTight),
            SizedBox(
              width: double.infinity,
              height: AppDesignConstants.minTouchTarget,
              child: TextButton(
                style: V2ShellVisual.tertiaryText(),
                onPressed: () => context.go(AppRoutes.v2WeeklyReviewSummary),
                child: Text(loc.v2ProgressWrCtaSummary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _path(AppLocalizations loc, PathMixLabel label) {
    switch (label) {
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

  static String _rhythm(AppLocalizations loc, RhythmLabel label) {
    switch (label) {
      case RhythmLabel.steady:
        return loc.v2WeeklySummaryRhythmSteady;
      case RhythmLabel.intermittent:
        return loc.v2WeeklySummaryRhythmIntermittent;
      case RhythmLabel.limitedHistory:
        return loc.v2WeeklySummaryRhythmLimited;
    }
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({required this.vm});
  final ProgressViewModel vm;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dest = vm.primaryDestination;
    final label = switch (dest) {
      ProgressNextDestination.weeklyReviewQuestions =>
        vm.weeklyReviewCardState ==
                ProgressWeeklyReviewCardState.draftInProgress
            ? loc.v2ProgressWrCtaContinue
            : loc.v2ProgressWrCtaStart,
      ProgressNextDestination.weeklyReviewSummary => loc.v2ProgressWrCtaSummary,
      ProgressNextDestination.today ||
      ProgressNextDestination.none =>
        vm.isEmpty ? loc.v2ProgressCtaToday : loc.v2ProgressCtaContinueToday,
    };
    final route = switch (dest) {
      ProgressNextDestination.weeklyReviewQuestions => AppRoutes.v2WeeklyReview,
      ProgressNextDestination.weeklyReviewSummary =>
        AppRoutes.v2WeeklyReviewSummary,
      ProgressNextDestination.today ||
      ProgressNextDestination.none =>
        AppRoutes.v2Today,
    };

    return SizedBox(
      width: double.infinity,
      height: AppDesignConstants.minTouchTarget,
      child: FilledButton(
        style: V2ShellVisual.primaryFilled(),
        onPressed: () => context.go(route),
        child: Text(label),
      ),
    );
  }
}

class _Pad extends StatelessWidget {
  const _Pad({
    required this.title,
    required this.cta,
    required this.onCta,
  });

  final String title;
  final String cta;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
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
                  liveRegion: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: V2ShellVisual.heroTitle(Theme.of(context)),
                  ),
                ),
                const SizedBox(height: AppDesignConstants.v2GapMajor),
                SizedBox(
                  width: double.infinity,
                  height: AppDesignConstants.minTouchTarget,
                  child: FilledButton(
                    style: V2ShellVisual.primaryFilled(),
                    onPressed: onCta,
                    child: Text(cta),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompletionRing extends StatelessWidget {
  const _CompletionRing({
    required this.percent,
    required this.centerLabel,
    required this.centerCaption,
  });

  final int percent; // 0-100
  final String centerLabel;
  final String centerCaption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = percent.clamp(0, 100);
    return Semantics(
      label: '$centerCaption: $centerLabel',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlowProgressRing(
            key: const Key('v2_progress_completion_ring'),
            progress: clamped / 100,
            size: 120,
            strokeWidth: 11,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                centerLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: V2ShellVisual.heroMetricValue(theme),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 120,
            child: Text(
              centerCaption,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: V2ShellVisual.metricCaption(theme)?.copyWith(
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChartCard extends StatelessWidget {
  const _WeeklyChartCard({required this.bars});

  final List<ProgressWeeklyBarDay> bars;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final palette = AppColors.of(context);
    if (bars.isEmpty) return const SizedBox.shrink();

    return V2InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.v2ProgressWeeklyChartHeading,
            style: V2ShellVisual.sectionLabel(theme),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1.2,
                minY: 0,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= bars.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            bars[i].weekdayLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: palette.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < bars.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: bars[i].completed ? 1 : 0.12,
                          width: 14,
                          borderRadius: BorderRadius.circular(6),
                          color: bars[i].completed
                              ? AppColors.primary
                              : palette.ringTrack,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
