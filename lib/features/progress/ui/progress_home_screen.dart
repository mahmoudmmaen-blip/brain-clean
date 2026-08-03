import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../weekly_review/domain/weekly_review_enums.dart';
import '../../weekly_review/domain/weekly_review_summary.dart';
import '../application/progress_experience_controller.dart';
import '../data/progress_experience_controller_provider.dart';
import '../domain/progress_experience_enums.dart';
import '../domain/progress_timeline.dart';
import '../domain/progress_view_model.dart';

/// PRG-01 — words-first Progress proof experience + Weekly Review entry.
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  loc.v2ProgressOrientation,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Text(
                  _headline(loc, vm.proofHeadline),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.v2ProgressBasedOnSessions,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (vm.isEmpty) ...[
                const SizedBox(height: 24),
                Text(loc.v2ProgressEmptyBody),
              ] else ...[
                const SizedBox(height: 24),
                _BetterBlock(vm: vm),
                const SizedBox(height: 20),
                _WhyBlock(vm: vm),
                const SizedBox(height: 20),
                _ComparedBlock(vm: vm),
                const SizedBox(height: 12),
                Text(
                  _evidence(loc, vm.evidenceDepth),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (vm.showScoreRow) ...[
                  const SizedBox(height: 20),
                  _ScoreRow(vm: vm),
                ],
              ],
              const SizedBox(height: 24),
              _ReviewEntry(vm: vm),
              if (vm.weeklySummaryPreview != null) ...[
                const SizedBox(height: 16),
                _WeeklyPreview(summary: vm.weeklySummaryPreview!),
              ],
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                onPressed: () => context.go(AppRoutes.v2Reports),
                child: Text(loc.v2ProgressReportsEntry),
              ),
              const SizedBox(height: 28),
              _PrimaryCta(vm: vm),
            ],
          ),
        );
      },
    );
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

class _BetterBlock extends StatelessWidget {
  const _BetterBlock({required this.vm});
  final ProgressViewModel vm;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Semantics(
      container: true,
      label: loc.v2ProgressBetterHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.v2ProgressBetterHeading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(loc.v2ProgressCompletedDays(vm.completedDays.toString())),
          Text(
            loc.v2ProgressCompletedSessions(
              vm.totalCompletedSessions.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhyBlock extends StatelessWidget {
  const _WhyBlock({required this.vm});
  final ProgressViewModel vm;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final mix = vm.pathMixHint;
    return Semantics(
      container: true,
      label: loc.v2ProgressWhyHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.v2ProgressWhyHeading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(loc.v2ProgressMinimumPath(vm.minimumPathCount.toString())),
          Text(loc.v2ProgressStandardPath(vm.standardPathCount.toString())),
          if (mix != null) Text(_mix(loc, mix)),
          Text(
            loc.v2ProgressCompletionRate(vm.completionRatePercent.toString()),
          ),
        ],
      ),
    );
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
}

class _ComparedBlock extends StatelessWidget {
  const _ComparedBlock({required this.vm});
  final ProgressViewModel vm;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Semantics(
      container: true,
      label: loc.v2ProgressComparedHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.v2ProgressComparedHeading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(loc.v2ProgressCurrentRhythm(vm.currentRhythmDays.toString())),
          Text(loc.v2ProgressLongestRhythm(vm.longestRhythmDays.toString())),
          if (vm.firstCompletedDayKey != null)
            Text(loc.v2ProgressFirstCompleted(vm.firstCompletedDayKey!)),
          if (vm.lastCompletedDayKey != null)
            Text(loc.v2ProgressLastCompleted(vm.lastCompletedDayKey!)),
          const SizedBox(height: 12),
          Text(
            loc.v2ProgressRecentActivity,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          for (final e in vm.recentTimeline) _TimelineRow(entry: e),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry});
  final ProgressTimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final path = entry.usedMinimumPath && entry.usedStandardPath
        ? loc.v2ProgressTimelineBothPaths
        : entry.usedStandardPath
            ? loc.v2ProgressTimelineStandard
            : loc.v2ProgressTimelineMinimum;
    return Semantics(
      label: loc.v2ProgressTimelineEntry(entry.dayKey, path),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(loc.v2ProgressTimelineEntry(entry.dayKey, path)),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.vm});
  final ProgressViewModel vm;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final valueText = vm.scoreDisplayValue != null
        ? loc.v2ProgressScoreValue(vm.scoreDisplayValue.toString())
        : loc.v2ProgressScoreUnavailable;
    return Semantics(
      container: true,
      label: loc.v2ProgressScoreHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.v2ProgressScoreHeading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(valueText),
          if (vm.scoreMeasuredDayKey != null)
            Text(loc.v2ProgressScoreMeasured(vm.scoreMeasuredDayKey!)),
          const SizedBox(height: 4),
          Text(
            loc.v2ProgressScoreDisclaimer,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ReviewEntry extends StatelessWidget {
  const _ReviewEntry({required this.vm});
  final ProgressViewModel vm;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final state = vm.weeklyReviewCardState;
    final route = _routeFor(state);
    final cta = _ctaFor(loc, state);

    return Semantics(
      container: true,
      liveRegion: true,
      label: loc.v2ProgressWeeklyReviewHeading,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.v2ProgressWeeklyReviewHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(_statusText(loc, state)),
            if (vm.weeklyPeriodStartDayKey != null &&
                vm.weeklyPeriodEndDayKey != null) ...[
              const SizedBox(height: 4),
              Text(
                loc.v2WeeklyReviewPeriodLabel(
                  vm.weeklyPeriodStartDayKey!,
                  vm.weeklyPeriodEndDayKey!,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (route != null && cta != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.go(route),
                  child: Text(cta),
                ),
              ),
            ],
          ],
        ),
      ),
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
  const _WeeklyPreview({required this.summary});
  final WeeklyReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Semantics(
      container: true,
      label: loc.v2ProgressWeeklyPreviewHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.v2ProgressWeeklyPreviewHeading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            loc.v2WeeklyReviewPeriodLabel(
              summary.periodStartDayKey,
              summary.periodEndDayKey,
            ),
          ),
          Text(
            loc.v2WeeklySummaryCompletedDays(
              summary.completedDayCount.toString(),
            ),
          ),
          Text(_path(loc, summary.pathMixLabel)),
          Text(_rhythm(loc, summary.rhythmLabel)),
          Text(loc.v2WeeklySummaryPlanUnchanged),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => context.go(AppRoutes.v2WeeklyReviewSummary),
              child: Text(loc.v2ProgressWrCtaSummary),
            ),
          ),
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
        vm.weeklyReviewCardState == ProgressWeeklyReviewCardState.draftInProgress
            ? loc.v2ProgressWrCtaContinue
            : loc.v2ProgressWrCtaStart,
      ProgressNextDestination.weeklyReviewSummary =>
        loc.v2ProgressWrCtaSummary,
      ProgressNextDestination.today || ProgressNextDestination.none =>
        vm.isEmpty
            ? loc.v2ProgressCtaToday
            : loc.v2ProgressCtaContinueToday,
    };
    final route = switch (dest) {
      ProgressNextDestination.weeklyReviewQuestions =>
        AppRoutes.v2WeeklyReview,
      ProgressNextDestination.weeklyReviewSummary =>
        AppRoutes.v2WeeklyReviewSummary,
      ProgressNextDestination.today || ProgressNextDestination.none =>
        AppRoutes.v2Today,
    };

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
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
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  liveRegion: true,
                  child: Text(title, textAlign: TextAlign.center),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(onPressed: onCta, child: Text(cta)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
