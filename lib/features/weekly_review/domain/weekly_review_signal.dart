import 'weekly_review_enums.dart';
import 'weekly_review_version.dart';

/// Structured future-adaptation signal — does not mutate Plan or Score.
class WeeklyReviewSignal {
  const WeeklyReviewSignal({
    required this.signalId,
    required this.periodId,
    required this.sourceArtifactId,
    required this.planFitSignal,
    required this.loadSignal,
    required this.obstacleSignal,
    required this.accessibilitySignal,
    required this.evidenceDepth,
    required this.confidence,
    required this.createdAt,
    required this.signalVersion,
  });

  final String signalId;
  final String periodId;
  final String sourceArtifactId;
  final PlanFitSignal planFitSignal;
  final LoadSignal loadSignal;
  final ObstacleSignal obstacleSignal;
  final AccessibilitySignal accessibilitySignal;
  final EvidenceDepth evidenceDepth;
  final SignalConfidence confidence;
  final DateTime createdAt;
  final String signalVersion;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'signalId': signalId,
        'periodId': periodId,
        'sourceArtifactId': sourceArtifactId,
        'planFitSignal': planFitSignal.wireName,
        'loadSignal': loadSignal.wireName,
        'obstacleSignal': obstacleSignal.wireName,
        'accessibilitySignal': accessibilitySignal.wireName,
        'evidenceDepth': evidenceDepth.wireName,
        'confidence': confidence.wireName,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'signalVersion': signalVersion,
      };

  factory WeeklyReviewSignal.fromJson(Map<String, dynamic> json) {
    return WeeklyReviewSignal(
      signalId: json['signalId'] as String,
      periodId: json['periodId'] as String,
      sourceArtifactId: json['sourceArtifactId'] as String,
      planFitSignal: PlanFitSignalX.fromWire(json['planFitSignal'] as String?),
      loadSignal: LoadSignalX.fromWire(json['loadSignal'] as String?),
      obstacleSignal:
          ObstacleSignalX.fromWire(json['obstacleSignal'] as String?),
      accessibilitySignal: AccessibilitySignalX.fromWire(
        json['accessibilitySignal'] as String?,
      ),
      evidenceDepth: EvidenceDepthX.fromWire(json['evidenceDepth'] as String?),
      confidence: SignalConfidenceX.fromWire(json['confidence'] as String?),
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      signalVersion:
          json['signalVersion'] as String? ?? WeeklyReviewVersion.signalModel,
    );
  }
}
