enum DailySessionStatus {
  /// Reserved / empty.
  notStarted,

  /// SES-01 prepared; path may be chosen.
  prepared,

  /// SES-02 in progress.
  inProgress,

  /// SES-03 reflection.
  reflecting,

  /// Required path steps done + mark saved.
  completed,

  /// User left early without full required completion.
  partial,

  /// Persist/route failure recovery.
  invalid,
}

extension DailySessionStatusX on DailySessionStatus {
  String get wireName => switch (this) {
        DailySessionStatus.notStarted => 'not_started',
        DailySessionStatus.prepared => 'prepared',
        DailySessionStatus.inProgress => 'in_progress',
        DailySessionStatus.reflecting => 'reflecting',
        DailySessionStatus.completed => 'completed',
        DailySessionStatus.partial => 'partial',
        DailySessionStatus.invalid => 'invalid',
      };

  bool get isTerminal =>
      this == DailySessionStatus.completed ||
      this == DailySessionStatus.partial;

  bool get isDoneToday => this == DailySessionStatus.completed;

  static DailySessionStatus fromWire(String? raw) {
    switch (raw) {
      case 'prepared':
        return DailySessionStatus.prepared;
      case 'in_progress':
        return DailySessionStatus.inProgress;
      case 'reflecting':
        return DailySessionStatus.reflecting;
      case 'completed':
        return DailySessionStatus.completed;
      case 'partial':
        return DailySessionStatus.partial;
      case 'invalid':
        return DailySessionStatus.invalid;
      case 'not_started':
      default:
        return DailySessionStatus.notStarted;
    }
  }
}
