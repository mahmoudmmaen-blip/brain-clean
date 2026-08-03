import 'weekly_review_enums.dart';
import 'weekly_review_version.dart';

/// Deterministic WRV-02 summary — never claims causation.
class WeeklyReviewSummary {
  const WeeklyReviewSummary({
    required this.periodId,
    required this.periodStartDayKey,
    required this.periodEndDayKey,
    required this.completedSessionCount,
    required this.completedDayCount,
    required this.minimumPathCount,
    required this.standardPathCount,
    required this.pathMixLabel,
    required this.rhythmLabel,
    required this.evidenceDepth,
    required this.manageabilityResponse,
    required this.pauseFocusResponse,
    required this.obstacleResponse,
    required this.supportResponses,
    required this.accessibilityUsed,
    required this.strongestObservedPattern,
    required this.attentionNext,
    required this.planUnchangedNotice,
    required this.confidenceQualifier,
    required this.generatedAt,
    required this.modelVersion,
  });

  final String periodId;
  final String periodStartDayKey;
  final String periodEndDayKey;
  final int completedSessionCount;
  final int completedDayCount;
  final int minimumPathCount;
  final int standardPathCount;
  final PathMixLabel pathMixLabel;
  final RhythmLabel rhythmLabel;
  final EvidenceDepth evidenceDepth;
  final String manageabilityResponse;
  final int pauseFocusResponse;
  final String obstacleResponse;
  final List<String> supportResponses;
  final bool? accessibilityUsed;
  final String strongestObservedPattern;
  final String attentionNext;
  final bool planUnchangedNotice;
  final String confidenceQualifier;
  final DateTime generatedAt;
  final String modelVersion;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'periodId': periodId,
        'periodStartDayKey': periodStartDayKey,
        'periodEndDayKey': periodEndDayKey,
        'completedSessionCount': completedSessionCount,
        'completedDayCount': completedDayCount,
        'minimumPathCount': minimumPathCount,
        'standardPathCount': standardPathCount,
        'pathMixLabel': pathMixLabel.wireName,
        'rhythmLabel': rhythmLabel.wireName,
        'evidenceDepth': evidenceDepth.wireName,
        'manageabilityResponse': manageabilityResponse,
        'pauseFocusResponse': pauseFocusResponse,
        'obstacleResponse': obstacleResponse,
        'supportResponses': supportResponses,
        'accessibilityUsed': accessibilityUsed,
        'strongestObservedPattern': strongestObservedPattern,
        'attentionNext': attentionNext,
        'planUnchangedNotice': planUnchangedNotice,
        'confidenceQualifier': confidenceQualifier,
        'generatedAt': generatedAt.toUtc().toIso8601String(),
        'modelVersion': modelVersion,
      };

  factory WeeklyReviewSummary.fromJson(Map<String, dynamic> json) {
    return WeeklyReviewSummary(
      periodId: json['periodId'] as String,
      periodStartDayKey: json['periodStartDayKey'] as String,
      periodEndDayKey: json['periodEndDayKey'] as String,
      completedSessionCount: json['completedSessionCount'] as int,
      completedDayCount: json['completedDayCount'] as int,
      minimumPathCount: json['minimumPathCount'] as int,
      standardPathCount: json['standardPathCount'] as int,
      pathMixLabel: PathMixLabelX.fromWire(json['pathMixLabel'] as String?),
      rhythmLabel: RhythmLabelX.fromWire(json['rhythmLabel'] as String?),
      evidenceDepth: EvidenceDepthX.fromWire(json['evidenceDepth'] as String?),
      manageabilityResponse: json['manageabilityResponse'] as String,
      pauseFocusResponse: json['pauseFocusResponse'] as int,
      obstacleResponse: json['obstacleResponse'] as String,
      supportResponses: (json['supportResponses'] as List?)
              ?.map((e) => e as String)
              .toList(growable: false) ??
          const [],
      accessibilityUsed: json['accessibilityUsed'] as bool?,
      strongestObservedPattern: json['strongestObservedPattern'] as String,
      attentionNext: json['attentionNext'] as String,
      planUnchangedNotice: json['planUnchangedNotice'] as bool? ?? true,
      confidenceQualifier: json['confidenceQualifier'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String).toUtc(),
      modelVersion:
          json['modelVersion'] as String? ?? WeeklyReviewVersion.reviewModel,
    );
  }
}
