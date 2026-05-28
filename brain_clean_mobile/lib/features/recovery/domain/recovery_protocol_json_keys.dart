/// Canonical camelCase keys for Hive / local JSON persistence.
abstract final class RecoveryProtocolJsonKeys {
  static const protocolStartDate = 'protocolStartDate';
  static const selectedDayIndex = 'selectedDayIndex';
  static const totalPenaltyCount = 'totalPenaltyCount';
  static const days = 'days';

  static const dayIndex = 'dayIndex';
  static const taskCompleted = 'taskCompleted';
  static const penaltyApplied = 'penaltyApplied';

  /// Legacy snake_case keys — rejected on read to prevent payload drift.
  static const forbiddenDriftKeys = {
    'protocol_start_date',
    'selected_day_index',
    'total_penalty_count',
    'day_index',
    'task_completed',
    'penalty_applied',
  };

  static const allowedRootKeys = {
    protocolStartDate,
    selectedDayIndex,
    totalPenaltyCount,
    days,
  };

  static const allowedDayRecordKeys = {
    dayIndex,
    taskCompleted,
    penaltyApplied,
  };
}
