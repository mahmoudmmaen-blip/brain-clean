enum DailySessionStepPhase {
  pending,
  active,
  completed,
  skipped,
}

extension DailySessionStepPhaseX on DailySessionStepPhase {
  String get wireName => name;

  static DailySessionStepPhase fromWire(String? raw) {
    switch (raw) {
      case 'active':
        return DailySessionStepPhase.active;
      case 'completed':
        return DailySessionStepPhase.completed;
      case 'skipped':
        return DailySessionStepPhase.skipped;
      case 'pending':
      default:
        return DailySessionStepPhase.pending;
    }
  }
}

/// Per-step state within a DailySession.
class DailySessionStepState {
  const DailySessionStepState({
    required this.stepId,
    required this.optional,
    required this.phase,
    this.completedAt,
    this.skippedAt,
  });

  final String stepId;
  final bool optional;
  final DailySessionStepPhase phase;
  final DateTime? completedAt;
  final DateTime? skippedAt;

  bool get isDone =>
      phase == DailySessionStepPhase.completed ||
      phase == DailySessionStepPhase.skipped;

  DailySessionStepState copyWith({
    DailySessionStepPhase? phase,
    DateTime? completedAt,
    DateTime? skippedAt,
    bool clearCompleted = false,
    bool clearSkipped = false,
  }) {
    return DailySessionStepState(
      stepId: stepId,
      optional: optional,
      phase: phase ?? this.phase,
      completedAt:
          clearCompleted ? null : (completedAt ?? this.completedAt),
      skippedAt: clearSkipped ? null : (skippedAt ?? this.skippedAt),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'stepId': stepId,
        'optional': optional,
        'phase': phase.wireName,
        if (completedAt != null)
          'completedAt': completedAt!.toUtc().toIso8601String(),
        if (skippedAt != null)
          'skippedAt': skippedAt!.toUtc().toIso8601String(),
      };

  factory DailySessionStepState.fromJson(Map<String, dynamic> json) {
    return DailySessionStepState(
      stepId: json['stepId'] as String? ?? '',
      optional: json['optional'] as bool? ?? false,
      phase: DailySessionStepPhaseX.fromWire(json['phase'] as String?),
      completedAt:
          DateTime.tryParse(json['completedAt'] as String? ?? '')?.toUtc(),
      skippedAt:
          DateTime.tryParse(json['skippedAt'] as String? ?? '')?.toUtc(),
    );
  }
}
