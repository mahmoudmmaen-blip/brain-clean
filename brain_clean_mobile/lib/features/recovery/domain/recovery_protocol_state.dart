import 'recovery_day_record.dart';
import 'recovery_protocol_constants.dart';

/// In-memory 30-day recovery tracker (local-first).
class RecoveryProtocolState {
  const RecoveryProtocolState({
    this.protocolStartDate,
    this.selectedDayIndex = 1,
    this.days = const {},
    this.totalPenaltyCount = 0,
  });

  final DateTime? protocolStartDate;
  final int selectedDayIndex;
  final Map<int, RecoveryDayRecord> days;
  final int totalPenaltyCount;

  RecoveryDayRecord dayRecord(int dayIndex) =>
      days[dayIndex] ??
      RecoveryDayRecord(dayIndex: dayIndex);

  int get currentProtocolDay {
    if (protocolStartDate == null) return 1;
    final elapsed =
        DateTime.now().difference(protocolStartDate!).inDays + 1;
    return elapsed.clamp(1, RecoveryProtocolConstants.dayCount);
  }

  int get completedDaysCount =>
      days.values.where((d) => d.allTasksComplete).length;

  double get progressRatio =>
      completedDaysCount / RecoveryProtocolConstants.dayCount;

  RecoveryProtocolState copyWith({
    DateTime? protocolStartDate,
    int? selectedDayIndex,
    Map<int, RecoveryDayRecord>? days,
    int? totalPenaltyCount,
  }) {
    return RecoveryProtocolState(
      protocolStartDate: protocolStartDate ?? this.protocolStartDate,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      days: days ?? this.days,
      totalPenaltyCount: totalPenaltyCount ?? this.totalPenaltyCount,
    );
  }
}
