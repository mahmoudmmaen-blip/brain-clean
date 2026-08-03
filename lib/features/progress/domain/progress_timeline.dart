/// One day on the progress timeline (derived from completed sessions).
class ProgressTimelineEntry {
  const ProgressTimelineEntry({
    required this.dayKey,
    required this.sessionIds,
    required this.fullCompletions,
    required this.usedMinimumPath,
    required this.usedStandardPath,
    required this.skippedOptionalSteps,
    required this.requiredStepsCompleted,
  });

  final String dayKey;
  final List<String> sessionIds;
  final int fullCompletions;
  final bool usedMinimumPath;
  final bool usedStandardPath;
  final int skippedOptionalSteps;
  final int requiredStepsCompleted;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'dayKey': dayKey,
        'sessionIds': sessionIds,
        'fullCompletions': fullCompletions,
        'usedMinimumPath': usedMinimumPath,
        'usedStandardPath': usedStandardPath,
        'skippedOptionalSteps': skippedOptionalSteps,
        'requiredStepsCompleted': requiredStepsCompleted,
      };

  factory ProgressTimelineEntry.fromJson(Map<String, dynamic> json) {
    final ids = <String>[];
    final raw = json['sessionIds'];
    if (raw is List) {
      for (final item in raw) {
        ids.add(item.toString());
      }
    }
    return ProgressTimelineEntry(
      dayKey: json['dayKey'] as String? ?? '',
      sessionIds: List<String>.unmodifiable(ids),
      fullCompletions: (json['fullCompletions'] as num?)?.toInt() ?? 0,
      usedMinimumPath: json['usedMinimumPath'] as bool? ?? false,
      usedStandardPath: json['usedStandardPath'] as bool? ?? false,
      skippedOptionalSteps:
          (json['skippedOptionalSteps'] as num?)?.toInt() ?? 0,
      requiredStepsCompleted:
          (json['requiredStepsCompleted'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Chronological completed-day timeline (ascending by dayKey).
class ProgressTimeline {
  const ProgressTimeline({required this.entries});

  final List<ProgressTimelineEntry> entries;

  bool get isEmpty => entries.isEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'entries': entries.map((e) => e.toJson()).toList(growable: false),
      };

  factory ProgressTimeline.fromJson(Map<String, dynamic> json) {
    final entries = <ProgressTimelineEntry>[];
    final raw = json['entries'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          entries.add(
            ProgressTimelineEntry.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return ProgressTimeline(entries: List.unmodifiable(entries));
  }

  static const empty = ProgressTimeline(entries: []);
}
