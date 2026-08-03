import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'weekly_review_summary.dart';
import 'weekly_review_version.dart';

/// Immutable weekly review artifact — one per completed period review.
class WeeklyArtifact {
  const WeeklyArtifact({
    required this.artifactId,
    required this.weeklyReviewRecordId,
    required this.periodId,
    required this.sourceProgressSnapshotId,
    required this.sourcePlanId,
    required this.sourceProfilePackId,
    required this.sourceRecoveryScoreReference,
    required this.summary,
    required this.completedSessionIds,
    required this.createdAt,
    required this.artifactSchemaVersion,
    required this.reviewModelVersion,
    required this.immutableHash,
  });

  final String artifactId;
  final String weeklyReviewRecordId;
  final String periodId;
  final String sourceProgressSnapshotId;
  final String sourcePlanId;
  final String sourceProfilePackId;
  final String sourceRecoveryScoreReference;
  final WeeklyReviewSummary summary;
  final List<String> completedSessionIds;
  final DateTime createdAt;
  final String artifactSchemaVersion;
  final String reviewModelVersion;
  final String immutableHash;

  static String idFor(String periodId) => 'wart_$periodId';

  static String computeHash({
    required String artifactId,
    required String weeklyReviewRecordId,
    required String periodId,
    required String sourceProgressSnapshotId,
    required String sourcePlanId,
    required String sourceProfilePackId,
    required String sourceRecoveryScoreReference,
    required WeeklyReviewSummary summary,
    required List<String> completedSessionIds,
  }) {
    final payload = <String, dynamic>{
      'artifactId': artifactId,
      'weeklyReviewRecordId': weeklyReviewRecordId,
      'periodId': periodId,
      'sourceProgressSnapshotId': sourceProgressSnapshotId,
      'sourcePlanId': sourcePlanId,
      'sourceProfilePackId': sourceProfilePackId,
      'sourceRecoveryScoreReference': sourceRecoveryScoreReference,
      'summary': summary.toJson(),
      'completedSessionIds': completedSessionIds,
      'artifactSchemaVersion': WeeklyReviewVersion.artifactSchema,
      'reviewModelVersion': WeeklyReviewVersion.reviewModel,
    };
    final bytes = utf8.encode(jsonEncode(payload));
    return sha256.convert(bytes).toString();
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'artifactId': artifactId,
        'weeklyReviewRecordId': weeklyReviewRecordId,
        'periodId': periodId,
        'sourceProgressSnapshotId': sourceProgressSnapshotId,
        'sourcePlanId': sourcePlanId,
        'sourceProfilePackId': sourceProfilePackId,
        'sourceRecoveryScoreReference': sourceRecoveryScoreReference,
        'summary': summary.toJson(),
        'completedSessionIds': completedSessionIds,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'artifactSchemaVersion': artifactSchemaVersion,
        'reviewModelVersion': reviewModelVersion,
        'immutableHash': immutableHash,
      };

  factory WeeklyArtifact.fromJson(Map<String, dynamic> json) {
    final schema = json['artifactSchemaVersion'] as String?;
    if (schema != null && schema != WeeklyReviewVersion.artifactSchema) {
      throw FormatException('Unsupported weekly artifact schema: $schema');
    }
    return WeeklyArtifact(
      artifactId: json['artifactId'] as String,
      weeklyReviewRecordId: json['weeklyReviewRecordId'] as String,
      periodId: json['periodId'] as String,
      sourceProgressSnapshotId: json['sourceProgressSnapshotId'] as String,
      sourcePlanId: json['sourcePlanId'] as String,
      sourceProfilePackId: json['sourceProfilePackId'] as String,
      sourceRecoveryScoreReference:
          json['sourceRecoveryScoreReference'] as String? ?? '',
      summary: WeeklyReviewSummary.fromJson(
        Map<String, dynamic>.from(json['summary'] as Map),
      ),
      completedSessionIds: (json['completedSessionIds'] as List)
          .map((e) => e as String)
          .toList(growable: false),
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      artifactSchemaVersion:
          schema ?? WeeklyReviewVersion.artifactSchema,
      reviewModelVersion: json['reviewModelVersion'] as String? ??
          WeeklyReviewVersion.reviewModel,
      immutableHash: json['immutableHash'] as String,
    );
  }
}
