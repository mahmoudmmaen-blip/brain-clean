/// Cognitive pillars measured by the 5-question interactive diagnostic.
enum DiagMetric {
  attention,
  workingMemory,
  screenHabits,
  sleepQuality,
}

extension DiagMetricX on DiagMetric {
  String get l10nKey => switch (this) {
        DiagMetric.attention => 'diagMetricAttention',
        DiagMetric.workingMemory => 'diagMetricWorkingMemory',
        DiagMetric.screenHabits => 'diagMetricScreenHabits',
        DiagMetric.sleepQuality => 'diagMetricSleepQuality',
      };

  /// Maps to lite Brain Profile domains for recovery-plan prioritization.
  String get profileDomainId => switch (this) {
        DiagMetric.attention => 'lite_attention',
        DiagMetric.workingMemory => 'lite_attention',
        DiagMetric.screenHabits => 'lite_recovery',
        DiagMetric.sleepQuality => 'lite_recovery',
      };
}
