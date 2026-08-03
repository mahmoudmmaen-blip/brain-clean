import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../application/reports_controller.dart';
import '../data/reports_controller_provider.dart';
import '../domain/reports_evidence_depth.dart';
import '../domain/reports_measurement_status.dart';
import '../domain/reports_overview.dart';
// ReportsPrimaryCta lives beside measurement status enums.

/// RPT-01 — Reports evidence overview.
class ReportsOverviewScreen extends ConsumerStatefulWidget {
  const ReportsOverviewScreen({super.key});

  @override
  ConsumerState<ReportsOverviewScreen> createState() =>
      _ReportsOverviewScreenState();
}

class _ReportsOverviewScreenState extends ConsumerState<ReportsOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportsControllerProvider).loadOverview();
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
          child: Text(loc.v2ReportsTitle),
        ),
        leading: IconButton(
          tooltip: loc.v2ReportsBackProgress,
          onPressed: () => context.go(AppRoutes.v2Progress),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: ReportsOverviewBody(
          controller: c,
          onRetry: () => c.loadOverview(),
        ),
      ),
    );
  }
}

@visibleForTesting
class ReportsOverviewBody extends StatelessWidget {
  const ReportsOverviewBody({
    super.key,
    required this.controller,
    required this.onRetry,
  });

  final ReportsController controller;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final c = controller;

    if (c.phase == ReportsPhase.loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          child: Text(loc.v2ReportsLoading),
        ),
      );
    }

    if (c.phase == ReportsPhase.persistenceFailed ||
        c.phase == ReportsPhase.unsupported) {
      return _Pad(
        title: c.phase == ReportsPhase.unsupported
            ? loc.v2ReportsUnsupported
            : loc.v2ReportsPersistFailed,
        cta: loc.v2ReportsRetry,
        onCta: onRetry,
      );
    }

    final o = c.overview;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    loc.v2ReportsEvidenceOverview,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 8),
                Text(loc.v2ReportsOrientation),
                const SizedBox(height: 8),
                Text(
                  loc.v2ReportsOrientationNot,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                Semantics(
                  liveRegion: true,
                  label: _depthSemantics(loc, o.evidenceDepth),
                  child: Text(
                    _depthLabel(loc, o.evidenceDepth),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 6),
                Text(_depthExplain(loc, o.evidenceDepth)),
                if (o.snapshotMissing) ...[
                  const SizedBox(height: 16),
                  Text(loc.v2ReportsSnapshotMissing),
                ],
                if (c.phase == ReportsPhase.empty) ...[
                  const SizedBox(height: 24),
                  Text(loc.v2ReportsEmptyBody),
                ] else ...[
                  const SizedBox(height: 24),
                  _SessionSummary(overview: o),
                  const SizedBox(height: 20),
                  _MeasurementStatusBlock(overview: o),
                  const SizedBox(height: 20),
                  _ArtifactList(controller: c),
                ],
                const SizedBox(height: 28),
                _PrimaryCta(controller: c),
                if (c.visibleMeasurements.isNotEmpty ||
                    o.validMeasurementCount > 0) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () =>
                        context.go(AppRoutes.v2ReportMeasurements),
                    child: Text(loc.v2ReportsOpenMeasurementHistory),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static String _depthLabel(AppLocalizations loc, ReportsEvidenceDepth d) {
    switch (d) {
      case ReportsEvidenceDepth.noEvidence:
        return loc.v2ReportsDepthNoEvidence;
      case ReportsEvidenceDepth.earlyEvidence:
        return loc.v2ReportsDepthEarly;
      case ReportsEvidenceDepth.developingEvidence:
        return loc.v2ReportsDepthDeveloping;
      case ReportsEvidenceDepth.establishedHistory:
        return loc.v2ReportsDepthEstablished;
    }
  }

  static String _depthExplain(AppLocalizations loc, ReportsEvidenceDepth d) {
    switch (d) {
      case ReportsEvidenceDepth.noEvidence:
        return loc.v2ReportsDepthNoEvidenceExplain;
      case ReportsEvidenceDepth.earlyEvidence:
        return loc.v2ReportsEvidenceStillDeveloping;
      case ReportsEvidenceDepth.developingEvidence:
        return loc.v2ReportsDepthDevelopingExplain;
      case ReportsEvidenceDepth.establishedHistory:
        return loc.v2ReportsDepthEstablishedExplain;
    }
  }

  static String _depthSemantics(AppLocalizations loc, ReportsEvidenceDepth d) {
    return '${_depthLabel(loc, d)}. ${_depthExplain(loc, d)}';
  }
}

class _SessionSummary extends StatelessWidget {
  const _SessionSummary({required this.overview});
  final ReportsOverview overview;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final o = overview;
    return Semantics(
      container: true,
      label: loc.v2ReportsSessionSummaryHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.v2ReportsSessionSummaryHeading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            loc.v2ReportsCompletedSessions(o.completedSessionCount.toString()),
          ),
          Text(loc.v2ReportsCompletedDays(o.completedDayCount.toString())),
          Text(loc.v2ReportsMinimumPath(o.minimumPathCount.toString())),
          Text(loc.v2ReportsStandardPath(o.standardPathCount.toString())),
          Text(loc.v2ReportsCurrentRhythm(o.currentRhythm.toString())),
          Text(loc.v2ReportsLongestRhythm(o.longestRhythm.toString())),
          if (o.firstCompletedDayKey != null)
            Text(loc.v2ReportsFirstCompleted(o.firstCompletedDayKey!)),
          if (o.lastCompletedDayKey != null)
            Text(loc.v2ReportsLastCompleted(o.lastCompletedDayKey!)),
        ],
      ),
    );
  }
}

class _MeasurementStatusBlock extends StatelessWidget {
  const _MeasurementStatusBlock({required this.overview});
  final ReportsOverview overview;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Semantics(
      container: true,
      label: loc.v2ReportsMeasurementStatusHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.v2ReportsMeasurementStatusHeading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(_status(loc, overview.measurementStatus)),
          if (overview.latestScoreDisplay != null)
            Text(
              loc.v2ReportsLatestScore(overview.latestScoreDisplay.toString()),
            ),
          Text(loc.v2ReportsSelfReportEstimate),
        ],
      ),
    );
  }

  static String _status(AppLocalizations loc, ReportsMeasurementStatus s) {
    switch (s) {
      case ReportsMeasurementStatus.none:
        return loc.v2ReportsMeasurementNone;
      case ReportsMeasurementStatus.baselineOnly:
        return loc.v2ReportsMeasurementBaseline;
      case ReportsMeasurementStatus.comparableAvailable:
        return loc.v2ReportsMeasurementComparable;
      case ReportsMeasurementStatus.incompatibleOnly:
        return loc.v2ReportsMeasurementIncompatible;
    }
  }
}

class _ArtifactList extends StatelessWidget {
  const _ArtifactList({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final c = controller;
    return Semantics(
      container: true,
      label: loc.v2ReportsWeeklyHistory,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.v2ReportsWeeklyHistory,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (c.visibleArtifacts.isEmpty)
            Text(loc.v2ReportsNoArtifacts)
          else
            for (final a in c.visibleArtifacts)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    alignment: AlignmentDirectional.centerStart,
                  ),
                  onPressed: () => context.go(
                    '${AppRoutes.v2ReportArtifact}?id=${Uri.encodeComponent(a.artifactId)}',
                  ),
                  child: Text(
                    loc.v2ReportsWeeklyReportPeriod(
                      a.summary.periodStartDayKey,
                      a.summary.periodEndDayKey,
                    ),
                  ),
                ),
              ),
          if (c.premiumLockedArtifactCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              loc.v2ReportsPremiumArchiveHint(
                c.premiumLockedArtifactCount.toString(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final o = controller.overview;
    final label = switch (o.primaryCta) {
      ReportsPrimaryCta.openLatestArtifact => loc.v2ReportsCtaLatestArtifact,
      ReportsPrimaryCta.openMeasurementHistory =>
        loc.v2ReportsOpenMeasurementHistory,
      ReportsPrimaryCta.backToProgress => loc.v2ReportsBackProgress,
      ReportsPrimaryCta.goToToday => loc.v2ReportsCtaToday,
    };
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: () {
          switch (o.primaryCta) {
            case ReportsPrimaryCta.openLatestArtifact:
              final id = o.latestWeeklyArtifactId;
              if (id != null) {
                context.go(
                  '${AppRoutes.v2ReportArtifact}?id=${Uri.encodeComponent(id)}',
                );
              }
            case ReportsPrimaryCta.openMeasurementHistory:
              context.go(AppRoutes.v2ReportMeasurements);
            case ReportsPrimaryCta.backToProgress:
              context.go(AppRoutes.v2Progress);
            case ReportsPrimaryCta.goToToday:
              context.go(AppRoutes.v2Today);
          }
        },
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(liveRegion: true, child: Text(title)),
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
