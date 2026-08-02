import '../../brain_check/domain/brain_check_mode.dart';
import '../../brain_check/domain/measurement_event.dart';
import 'brain_profile_domain_result.dart';
import 'measurement_confidence.dart';
import 'profile_version.dart';
import 'recovery_score_engine.dart';
import 'score_calculation_result.dart';

/// Domain helpers — Recovery Score V1 engine is the calculation authority.
abstract final class DomainAggregator {
  static const modelVersion = ProfileVersion.domainAggregationModel;

  /// Aggregate domains via [RecoveryScoreEngine] (polarity + reject OOR).
  static List<BrainProfileDomainResult> aggregate(MeasurementEvent event) {
    final result = RecoveryScoreEngine.compute(event);
    return switch (result) {
      ScoreCalculationValid(:final domains) => domains,
      ScoreCalculationUnavailable(:final domains) => domains,
    };
  }

  static MeasurementConfidence confidenceFor({
    required BrainCheckMode mode,
    required List<BrainProfileDomainResult> domains,
  }) {
    return RecoveryScoreEngine.confidenceFor(mode: mode);
  }

  static List<BrainProfileDomainResult> rankedStronger(
    List<BrainProfileDomainResult> domains, {
    int limit = 2,
  }) {
    final withData = domains.where((d) => d.hasData).toList()
      ..sort(
        (a, b) => (b.normalizedMean ?? 0).compareTo(a.normalizedMean ?? 0),
      );
    return withData.take(limit).toList(growable: false);
  }

  static List<BrainProfileDomainResult> rankedSupport(
    List<BrainProfileDomainResult> domains, {
    int limit = 2,
  }) {
    final withData = domains.where((d) => d.hasData).toList()
      ..sort(
        (a, b) => (a.normalizedMean ?? 0).compareTo(b.normalizedMean ?? 0),
      );
    return withData.take(limit).toList(growable: false);
  }
}
