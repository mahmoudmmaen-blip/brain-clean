import '../../brain_profile/domain/measurement_confidence.dart';
import '../../brain_profile/domain/profile_pack.dart';
import '../../brain_profile/domain/recovery_score.dart';
import 'recovery_plan_intensity.dart';

/// Deterministic intensity selection (contract §8.1).
///
/// Supported is evaluated before the broad STANDARD rule for
/// building_rhythm / finding_steadiness so SUPPORTED remains reachable
/// when two priorities + strong confidence apply.
abstract final class IntensitySelector {
  static RecoveryPlanIntensity select({
    required ProfilePack pack,
    required int priorityCount,
  }) {
    final score = pack.recoveryScore;
    if (!score.isValid) {
      return RecoveryPlanIntensity.light;
    }

    final confidence = pack.confidence;
    final band = score.band;

    if (confidence == MeasurementConfidence.provisional) {
      return RecoveryPlanIntensity.light;
    }
    if (band == RecoveryScoreBand.gatheringFooting) {
      return RecoveryPlanIntensity.light;
    }
    if (band == RecoveryScoreBand.growingFoundation) {
      return RecoveryPlanIntensity.standard;
    }

    final eligibleSupportedBands = band == RecoveryScoreBand.buildingRhythm ||
        band == RecoveryScoreBand.findingSteadiness;
    if (priorityCount >= 2 &&
        confidence == MeasurementConfidence.strong &&
        eligibleSupportedBands) {
      return RecoveryPlanIntensity.supported;
    }

    if (band == RecoveryScoreBand.findingSteadiness ||
        (band == RecoveryScoreBand.buildingRhythm &&
            confidence == MeasurementConfidence.strong)) {
      return RecoveryPlanIntensity.standard;
    }

    return RecoveryPlanIntensity.standard;
  }
}
