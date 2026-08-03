import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../weekly_review/domain/weekly_review_enums.dart';
import '../../weekly_review/domain/weekly_review_summary.dart';
import '../application/reports_controller.dart';
import '../data/reports_controller_provider.dart';

/// RPT-02 — immutable WeeklyArtifact detail (user-facing summary only).
class WeeklyArtifactDetailScreen extends ConsumerStatefulWidget {
  const WeeklyArtifactDetailScreen({super.key, this.artifactId});

  final String? artifactId;

  @override
  ConsumerState<WeeklyArtifactDetailScreen> createState() =>
      _WeeklyArtifactDetailScreenState();
}

class _WeeklyArtifactDetailScreenState
    extends ConsumerState<WeeklyArtifactDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportsControllerProvider).loadArtifact(widget.artifactId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final c = ref.watch(reportsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Semantics(
          header: true,
          child: Text(loc.v2ReportsWeeklyReport),
        ),
        leading: IconButton(
          tooltip: loc.v2ReportsBackOverview,
          onPressed: () => context.go(AppRoutes.v2Reports),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: WeeklyArtifactDetailBody(
          controller: c,
          onBack: () => context.go(AppRoutes.v2Reports),
        ),
      ),
    );
  }
}

@visibleForTesting
class WeeklyArtifactDetailBody extends StatelessWidget {
  const WeeklyArtifactDetailBody({
    super.key,
    required this.controller,
    required this.onBack,
  });

  final ReportsController controller;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final c = controller;

    if (c.artifactPhase == ArtifactDetailPhase.loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          child: Text(loc.v2ReportsLoading),
        ),
      );
    }

    if (c.artifactPhase == ArtifactDetailPhase.premiumGated) {
      return _Message(
        title: loc.v2ReportsPremiumGatedTitle,
        body: loc.v2ReportsPremiumGatedBody,
        cta: loc.v2ReportsBackOverview,
        onCta: onBack,
      );
    }

    if (c.artifactPhase == ArtifactDetailPhase.missing ||
        c.artifactPhase == ArtifactDetailPhase.invalidAccess) {
      return _Message(
        title: loc.v2ReportsArtifactMissing,
        body: loc.v2ReportsArtifactMissingBody,
        cta: loc.v2ReportsBackOverview,
        onCta: onBack,
      );
    }

    if (c.artifactPhase == ArtifactDetailPhase.unsupported) {
      return _Message(
        title: loc.v2ReportsUnsupported,
        body: loc.v2ReportsArtifactUnsupportedBody,
        cta: loc.v2ReportsBackOverview,
        onCta: onBack,
      );
    }

    if (c.artifactPhase == ArtifactDetailPhase.corrupt ||
        c.selectedArtifact == null) {
      return _Message(
        title: loc.v2ReportsArtifactCorrupt,
        body: loc.v2ReportsArtifactCorruptBody,
        cta: loc.v2ReportsBackOverview,
        onCta: onBack,
      );
    }

    final s = c.selectedArtifact!.summary;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              loc.v2ReportsWeeklyReportPeriod(
                s.periodStartDayKey,
                s.periodEndDayKey,
              ),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          Text(loc.v2ReportsCompletedDays(s.completedDayCount.toString())),
          Text(
            loc.v2ReportsCompletedSessions(s.completedSessionCount.toString()),
          ),
          Text(_pathMix(loc, s.pathMixLabel)),
          Text(_rhythm(loc, s.rhythmLabel)),
          const SizedBox(height: 16),
          Text(
            loc.v2WeeklySummaryObstacleHeading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(_obstacle(loc, s.obstacleResponse)),
          const SizedBox(height: 12),
          Text(
            loc.v2WeeklySummarySupportHeading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(_supports(loc, s.supportResponses)),
          const SizedBox(height: 12),
          Text(_evidence(loc, s)),
          const SizedBox(height: 12),
          if (s.planUnchangedNotice) Text(loc.v2WeeklySummaryPlanUnchanged),
          const SizedBox(height: 12),
          Text(loc.v2ReportsNoCauseFromHistory),
          const SizedBox(height: 28),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: onBack,
              child: Text(loc.v2ReportsBackOverview),
            ),
          ),
        ],
      ),
    );
  }

  static String _pathMix(AppLocalizations loc, PathMixLabel label) {
    final name = switch (label) {
      PathMixLabel.mostlyMinimum => loc.v2WeeklySummaryPathMostlyMinimum,
      PathMixLabel.mostlyStandard => loc.v2WeeklySummaryPathMostlyStandard,
      PathMixLabel.balanced => loc.v2WeeklySummaryPathBalanced,
      PathMixLabel.singleSessionOnly => loc.v2WeeklySummaryPathSingle,
    };
    return loc.v2WeeklySummaryPathMix(name);
  }

  static String _rhythm(AppLocalizations loc, RhythmLabel label) {
    return switch (label) {
      RhythmLabel.steady => loc.v2WeeklySummaryRhythmSteady,
      RhythmLabel.intermittent => loc.v2WeeklySummaryRhythmIntermittent,
      RhythmLabel.limitedHistory => loc.v2WeeklySummaryRhythmLimited,
    };
  }

  static String _obstacle(AppLocalizations loc, String v) {
    switch (v) {
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
        return loc.v2WeeklyReviewOptNoMajorObstacle;
    }
  }

  static String _supports(AppLocalizations loc, List<String> values) {
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

  static String _evidence(AppLocalizations loc, WeeklyReviewSummary s) {
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

class _Message extends StatelessWidget {
  const _Message({
    required this.title,
    required this.body,
    required this.cta,
    required this.onCta,
  });

  final String title;
  final String body;
  final String cta;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            header: true,
            liveRegion: true,
            child: Text(title, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          Text(body, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: FilledButton(onPressed: onCta, child: Text(cta)),
          ),
        ],
      ),
    );
  }
}
