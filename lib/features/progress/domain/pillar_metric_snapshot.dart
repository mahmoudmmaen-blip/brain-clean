/// One recorded snapshot of the four interactive diagnostic pillars.
class PillarMetricSnapshot {
  const PillarMetricSnapshot({
    required this.recordedAt,
    required this.attention,
    required this.workingMemory,
    required this.screenHabits,
    required this.sleepQuality,
  });

  final DateTime recordedAt;
  final int attention;
  final int workingMemory;
  final int screenHabits;
  final int sleepQuality;

  int valueForKey(String key) => switch (key) {
        'attention' => attention,
        'workingMemory' => workingMemory,
        'screenHabits' => screenHabits,
        'sleepQuality' => sleepQuality,
        _ => 0,
      };

  Map<String, dynamic> toJson() => {
        'recordedAt': recordedAt.toUtc().toIso8601String(),
        'attention': attention,
        'workingMemory': workingMemory,
        'screenHabits': screenHabits,
        'sleepQuality': sleepQuality,
      };

  factory PillarMetricSnapshot.fromJson(Map<String, dynamic> json) {
    return PillarMetricSnapshot(
      recordedAt: DateTime.parse(json['recordedAt'] as String).toUtc(),
      attention: (json['attention'] as num).round(),
      workingMemory: (json['workingMemory'] as num).round(),
      screenHabits: (json['screenHabits'] as num).round(),
      sleepQuality: (json['sleepQuality'] as num).round(),
    );
  }
}

/// Day-one vs latest comparison for Progress tab.
class PillarProgressComparison {
  const PillarProgressComparison({
    required this.baseline,
    required this.latest,
    required this.history,
  });

  final PillarMetricSnapshot? baseline;
  final PillarMetricSnapshot? latest;
  final List<PillarMetricSnapshot> history;

  bool get hasData => baseline != null && latest != null;

  int deltaFor(String key) {
    if (!hasData) return 0;
    return latest!.valueForKey(key) - baseline!.valueForKey(key);
  }
}
