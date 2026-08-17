import 'recovery_plan_intensity.dart';

/// Daily cadence bounds derived from intensity (contract §8.2).
class RecoveryPlanCadence {
  const RecoveryPlanCadence({
    required this.intensity,
    required this.requiredSteps,
    required this.maxOptionalSteps,
    required this.maxTotalSteps,
    required this.minPathMinutesMin,
    required this.minPathMinutesMax,
    required this.standardPathMinutesMin,
    required this.standardPathMinutesMax,
  });

  final RecoveryPlanIntensity intensity;
  final int requiredSteps;
  final int maxOptionalSteps;
  final int maxTotalSteps;
  final int minPathMinutesMin;
  final int minPathMinutesMax;
  final int standardPathMinutesMin;
  final int standardPathMinutesMax;

  factory RecoveryPlanCadence.forIntensity(RecoveryPlanIntensity intensity) {
    return RecoveryPlanCadence(
      intensity: intensity,
      requiredSteps: intensity.requiredStepCount,
      maxOptionalSteps: intensity.maxOptionalSteps,
      maxTotalSteps: intensity.maxTotalSteps,
      minPathMinutesMin: intensity.minPathMinutesMin,
      minPathMinutesMax: intensity.minPathMinutesMax,
      standardPathMinutesMin: intensity.standardPathMinutesMin,
      standardPathMinutesMax: intensity.standardPathMinutesMax,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'intensity': intensity.wireName,
        'requiredSteps': requiredSteps,
        'maxOptionalSteps': maxOptionalSteps,
        'maxTotalSteps': maxTotalSteps,
        'minPathMinutesMin': minPathMinutesMin,
        'minPathMinutesMax': minPathMinutesMax,
        'standardPathMinutesMin': standardPathMinutesMin,
        'standardPathMinutesMax': standardPathMinutesMax,
      };

  factory RecoveryPlanCadence.fromJson(Map<String, dynamic> json) {
    final intensity =
        RecoveryPlanIntensityX.fromWire(json['intensity'] as String?);
    return RecoveryPlanCadence.forIntensity(intensity);
  }
}
