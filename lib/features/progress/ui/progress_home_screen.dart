import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
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

/// Vertical rhythm for Progress — shared V2 tokens (hierarchy unchanged).
const double _kGapIdentityHeadline = AppDesignConstants.v2GapTight;
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Semantics(
          header: true,
          child: Text(loc.v2ProgressTitle),
        ),
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
    final muted = theme.colorScheme.onSurfaceVariant;
    final c = controller;

    if (c.phase == ProgressExperiencePhase.loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          child: Text(loc.v2ProgressLoading),
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
              // 1 Identity — soft orientation under AppBar title
              Text(
                loc.v2ProgressOrientation,
                style: theme.textTheme.labelMedium?.copyWith(color: muted),
              ),
              const SizedBox(height: _kGapIdentityHeadline),
              // 2 Direction / meaningful summary
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
              if (vm.isEmpty) ...[
                const SizedBox(height: _kGapToMovement),
                Text(
                  loc.v2ProgressEmptyBody,
                  style: V2ShellVisual.bodyMuted(theme),
                ),
              ] else ...[
                const SizedBox(height: _kGapToMovement),
                // 3 Compact supporting movement indicators
                _MovementBlock(vm: vm, muted: muted),
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
                Divider(
                  height: 1,
                  thickness: 1,
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
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

class _MovementBlock extends StatelessWidget {
  const _MovementBlock({required this.vm, required this.muted});
  final ProgressViewModel vm;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mix = vm.pathMixHint;
    final days = loc.v2ProgressCompletedDays(vm.completedDays.toString());
    final sessions =
        loc.v2ProgressCompletedSessions(vm.totalCompletedSessions.toString());
    return Semantics(
      container: true,
      label: loc.v2ProgressBetterHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.v2ProgressBetterHeading,
            style: theme.textTheme.labelLarge?.copyWith(color: muted),
          ),
          const SizedBox(height: 6),
          // One calm summary line — not a dashboard stack of big numbers.
          Text(
            '$days · $sessions',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          if (mix != null) ...[
            const SizedBox(height: 4),
            Text(
              ProgressHomeBody._mix(loc, mix),
              style: theme.textTheme.bodySmall?.copyWith(
                color: muted,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            loc.v2ProgressCurrentRhythm(vm.currentRhythmDays),
            style: theme.textTheme.bodySmall?.copyWith(
              color: muted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternDetails extends StatelessWidget {
  const _PatternDetails({required this.vm});
  final ProgressViewModel vm;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
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
    final muted = theme.colorScheme.onSurfaceVariant;
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
    final muted = theme.colorScheme.onSurfaceVariant;
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
    final muted = theme.colorScheme.onSurfaceVariant;
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
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                )
              : theme.textTheme.labelMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 6),
        Text(
          _statusText(loc, state),
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
        if (showInlineCta) ...[
          const SizedBox(height: AppDesignConstants.v2GapControl),
          SizedBox(
            width: double.infinity,
            height: AppDesignConstants.minTouchTarget,
            child: OutlinedButton(
              style: V2ShellVisual.secondaryOutlined(),
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
    ProgressWeeklyReviewCardState state,
  ) {
    switch (state) {
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
    final muted = theme.colorScheme.onSurfaceVariant;
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
                  child: Text(title, textAlign: TextAlign.center),
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
