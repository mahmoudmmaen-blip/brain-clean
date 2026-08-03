import 'reports_evidence_depth.dart';
import 'reports_measurement_status.dart';
import 'reports_version.dart';

/// Read-only derived Reports Overview (contract §7). Not a source of truth.
class ReportsOverview {
  const ReportsOverview({
    required this.reportOverviewId,
    required this.generatedFromDayKey,
    required this.latestProgressSnapshotId,
    required this.completedSessionCount,
    required this.completedDayCount,
    required this.minimumPathCount,
    required this.standardPathCount,
    required this.currentRhythm,
    required this.longestRhythm,
    required this.firstCompletedDayKey,
    required this.lastCompletedDayKey,
    required this.weeklyArtifactCount,
    required this.latestWeeklyArtifactId,
    required this.validMeasurementCount,
    required this.latestProfilePackId,
    required this.latestRecoveryScoreReference,
    required this.latestScoreDisplay,
    required this.latestScoreBandWire,
    required this.evidenceDepth,
    required this.measurementStatus,
    required this.primaryCta,
    required this.createdAt,
    required this.reportModelVersion,
    required this.snapshotMissing,
    required this.historyCorruptPartial,
  });

  final String reportOverviewId;
  final String generatedFromDayKey;
  final String? latestProgressSnapshotId;
  final int completedSessionCount;
  final int completedDayCount;
  final int minimumPathCount;
  final int standardPathCount;
  final int currentRhythm;
  final int longestRhythm;
  final String? firstCompletedDayKey;
  final String? lastCompletedDayKey;
  final int weeklyArtifactCount;
  final String? latestWeeklyArtifactId;
  final int validMeasurementCount;
  final String? latestProfilePackId;

  /// Score model/version stamp only — never a recalculated value.
  final String? latestRecoveryScoreReference;
  final int? latestScoreDisplay;
  final String? latestScoreBandWire;
  final ReportsEvidenceDepth evidenceDepth;
  final ReportsMeasurementStatus measurementStatus;
  final ReportsPrimaryCta primaryCta;
  final DateTime createdAt;
  final String reportModelVersion;
  final bool snapshotMissing;
  final bool historyCorruptPartial;

  bool get hasEvidence => completedSessionCount > 0;

  factory ReportsOverview.empty({
    required String dayKey,
    required DateTime createdAt,
  }) {
    return ReportsOverview(
      reportOverviewId: 'rov_${dayKey}_empty',
      generatedFromDayKey: dayKey,
      latestProgressSnapshotId: null,
      completedSessionCount: 0,
      completedDayCount: 0,
      minimumPathCount: 0,
      standardPathCount: 0,
      currentRhythm: 0,
      longestRhythm: 0,
      firstCompletedDayKey: null,
      lastCompletedDayKey: null,
      weeklyArtifactCount: 0,
      latestWeeklyArtifactId: null,
      validMeasurementCount: 0,
      latestProfilePackId: null,
      latestRecoveryScoreReference: null,
      latestScoreDisplay: null,
      latestScoreBandWire: null,
      evidenceDepth: ReportsEvidenceDepth.noEvidence,
      measurementStatus: ReportsMeasurementStatus.none,
      primaryCta: ReportsPrimaryCta.goToToday,
      createdAt: createdAt,
      reportModelVersion: ReportsVersion.reportModel,
      snapshotMissing: false,
      historyCorruptPartial: false,
    );
  }
}
