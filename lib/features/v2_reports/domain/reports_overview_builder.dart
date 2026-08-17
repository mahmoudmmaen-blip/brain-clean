import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../brain_profile/domain/profile_pack.dart';
import '../../brain_profile/domain/recovery_score.dart';
import '../../progress/domain/progress_snapshot.dart';
import '../../progress/domain/progress_statistics.dart';
import '../../weekly_review/domain/weekly_artifact.dart';
import 'reports_evidence_depth.dart';
import 'reports_measurement_status.dart';
import 'reports_overview.dart';
import 'reports_version.dart';

/// Deterministic builder for [ReportsOverview] — read-only, no source mutation.
abstract final class ReportsOverviewBuilder {
  static ReportsEvidenceDepth evidenceDepth({
    required int completedSessionCount,
    required int completedDayCount,
    required int weeklyArtifactCount,
    required int validMeasurementCount,
  }) {
    if (completedSessionCount <= 0) {
      return ReportsEvidenceDepth.noEvidence;
    }
    if (weeklyArtifactCount >= 4 && validMeasurementCount >= 2) {
      return ReportsEvidenceDepth.establishedHistory;
    }
    if (completedDayCount >= 4 && weeklyArtifactCount >= 2) {
      return ReportsEvidenceDepth.developingEvidence;
    }
    return ReportsEvidenceDepth.earlyEvidence;
  }

  static ReportsMeasurementStatus measurementStatus({
    required int validCount,
    required bool hasComparablePair,
    required bool hasIncompatibleOnly,
  }) {
    if (validCount <= 0) return ReportsMeasurementStatus.none;
    if (validCount == 1) return ReportsMeasurementStatus.baselineOnly;
    if (hasComparablePair) {
      return ReportsMeasurementStatus.comparableAvailable;
    }
    if (hasIncompatibleOnly) {
      return ReportsMeasurementStatus.incompatibleOnly;
    }
    return ReportsMeasurementStatus.baselineOnly;
  }

  static ReportsPrimaryCta primaryCta({
    required int completedSessionCount,
    required String? latestWeeklyArtifactId,
    required int validMeasurementCount,
  }) {
    if (latestWeeklyArtifactId != null && latestWeeklyArtifactId.isNotEmpty) {
      return ReportsPrimaryCta.openLatestArtifact;
    }
    if (validMeasurementCount >= 1) {
      return ReportsPrimaryCta.openMeasurementHistory;
    }
    if (completedSessionCount <= 0) {
      return ReportsPrimaryCta.goToToday;
    }
    return ReportsPrimaryCta.backToProgress;
  }

  static ReportsOverview build({
    required String asOfDayKey,
    required DateTime nowUtc,
    required ProgressSnapshot? snapshot,
    required ProgressStatistics stats,
    required String? firstDay,
    required String? lastDay,
    required List<WeeklyArtifact> artifactsNewestFirst,
    required List<ProfilePack> validMeasurementsNewestFirst,
    required bool hasComparablePair,
    required bool hasIncompatibleOnly,
    bool historyCorruptPartial = false,
  }) {
    final validCount = validMeasurementsNewestFirst.length;
    final artifactCount = artifactsNewestFirst.length;
    final latestArtifact =
        artifactsNewestFirst.isEmpty ? null : artifactsNewestFirst.first;
    final latestPack =
        validMeasurementsNewestFirst.isEmpty
            ? null
            : validMeasurementsNewestFirst.first;
    final depth = evidenceDepth(
      completedSessionCount: stats.totalSessions,
      completedDayCount: stats.completedDays,
      weeklyArtifactCount: artifactCount,
      validMeasurementCount: validCount,
    );
    final status = measurementStatus(
      validCount: validCount,
      hasComparablePair: hasComparablePair,
      hasIncompatibleOnly: hasIncompatibleOnly,
    );
    final cta = primaryCta(
      completedSessionCount: stats.totalSessions,
      latestWeeklyArtifactId: latestArtifact?.artifactId,
      validMeasurementCount: validCount,
    );

    final scoreRef = latestPack == null
        ? null
        : '${latestPack.recoveryScore.modelVersion}'
            '|${latestPack.recoveryScore.band.wireName}'
            '|${latestPack.recoveryScore.value}';

    final id = _overviewId(
      dayKey: asOfDayKey,
      snapshotId: snapshot?.id,
      sessions: stats.totalSessions,
      days: stats.completedDays,
      artifacts: artifactCount,
      measurements: validCount,
      latestArtifactId: latestArtifact?.artifactId,
      latestPackId: latestPack?.id,
      depth: depth,
    );

    return ReportsOverview(
      reportOverviewId: id,
      generatedFromDayKey: asOfDayKey,
      latestProgressSnapshotId: snapshot?.id,
      completedSessionCount: stats.totalSessions,
      completedDayCount: stats.completedDays,
      minimumPathCount: stats.minimumPathCount,
      standardPathCount: stats.standardPathCount,
      currentRhythm: stats.currentStreak,
      longestRhythm: stats.longestStreak,
      firstCompletedDayKey: firstDay,
      lastCompletedDayKey: lastDay,
      weeklyArtifactCount: artifactCount,
      latestWeeklyArtifactId: latestArtifact?.artifactId,
      validMeasurementCount: validCount,
      latestProfilePackId: latestPack?.id,
      latestRecoveryScoreReference: scoreRef,
      latestScoreDisplay: latestPack?.recoveryScore.value,
      latestScoreBandWire: latestPack?.recoveryScore.band.wireName,
      evidenceDepth: depth,
      measurementStatus: status,
      primaryCta: cta,
      createdAt: nowUtc,
      reportModelVersion: ReportsVersion.reportModel,
      snapshotMissing: snapshot == null && stats.totalSessions > 0,
      historyCorruptPartial: historyCorruptPartial,
    );
  }

  static String _overviewId({
    required String dayKey,
    required String? snapshotId,
    required int sessions,
    required int days,
    required int artifacts,
    required int measurements,
    required String? latestArtifactId,
    required String? latestPackId,
    required ReportsEvidenceDepth depth,
  }) {
    final payload = jsonEncode(<String, dynamic>{
      'day': dayKey,
      'snap': snapshotId,
      's': sessions,
      'd': days,
      'a': artifacts,
      'm': measurements,
      'la': latestArtifactId,
      'lp': latestPackId,
      'depth': depth.wireName,
      'model': ReportsVersion.reportModel,
    });
    final hash = sha256.convert(utf8.encode(payload)).toString();
    return 'rov_${dayKey}_${hash.substring(0, 12)}';
  }
}
