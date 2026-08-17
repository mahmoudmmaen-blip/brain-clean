import 'brain_profile_domain_result.dart';
import 'measurement_confidence.dart';
import 'recovery_score.dart';

/// Per-domain contribution for explainability (contract §8.3).
class DomainContribution {
  const DomainContribution({
    required this.domainId,
    required this.domainScoreInternal,
    required this.weight,
    required this.contribution,
  });

  final String domainId;
  final double domainScoreInternal;
  final double weight;
  final double contribution;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'domainId': domainId,
        'domainScoreInternal': domainScoreInternal,
        'weight': weight,
        'contribution': contribution,
      };

  factory DomainContribution.fromJson(Map<String, dynamic> json) {
    return DomainContribution(
      domainId: json['domainId'] as String,
      domainScoreInternal: (json['domainScoreInternal'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      contribution: (json['contribution'] as num).toDouble(),
    );
  }
}

/// Outcome of `recovery_score_v1` calculation.
sealed class ScoreCalculationResult {
  const ScoreCalculationResult();
}

class ScoreCalculationValid extends ScoreCalculationResult {
  const ScoreCalculationValid({
    required this.recoveryScore,
    required this.domains,
    required this.contributions,
    required this.confidence,
    required this.strongerDomainIds,
    required this.supportDomainIds,
    required this.flags,
    required this.overallInternal,
  });

  final RecoveryScore recoveryScore;
  final List<BrainProfileDomainResult> domains;
  final List<DomainContribution> contributions;
  final MeasurementConfidence confidence;
  final List<String> strongerDomainIds;
  final List<String> supportDomainIds;
  final List<String> flags;
  final double overallInternal;
}

class ScoreCalculationUnavailable extends ScoreCalculationResult {
  const ScoreCalculationUnavailable({
    required this.reason,
    required this.flags,
    this.confidence = MeasurementConfidence.provisional,
    this.domains = const [],
  });

  final ScoreUnavailableReason reason;
  final List<String> flags;
  final MeasurementConfidence confidence;
  final List<BrainProfileDomainResult> domains;
}

enum ScoreUnavailableReason {
  emptyAnswers,
  missingRequired,
  invalidRange,
  unknownQuestion,
  zeroWeight,
  incompleteDomains,
}
