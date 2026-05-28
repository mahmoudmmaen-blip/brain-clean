import 'recovery_day_record.dart';
import 'recovery_protocol_constants.dart';

/// Persisted 30-day recovery tracker (local-first via Hive).
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
      days[dayIndex] ?? RecoveryDayRecord(dayIndex: dayIndex);

  int get currentProtocolDay {
    if (protocolStartDate == null) return 1;
    final elapsed = DateTime.now().difference(protocolStartDate!).inDays + 1;
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

  Map<String, dynamic> toJson() => {
        'protocol_start_date': protocolStartDate?.toIso8601String(),
        'selected_day_index': selectedDayIndex,
        'total_penalty_count': totalPenaltyCount,
        'days': days.map(
          (key, value) => MapEntry(key.toString(), value.toJson()),
        ),
      };

  factory RecoveryProtocolState.fromJson(Map<String, dynamic> json) {
    final daysRaw = json['days'];
    final parsedDays = <int, RecoveryDayRecord>{};
    if (daysRaw is Map) {
      for (final entry in daysRaw.entries) {
        final dayIndex = int.tryParse(entry.key.toString());
        if (dayIndex == null) continue;
        final value = entry.value;
        if (value is! Map) continue;
        parsedDays[dayIndex] = RecoveryDayRecord.fromJson(
          Map<String, dynamic>.from(value),
        );
      }
    }

    final startRaw = json['protocol_start_date'];
    DateTime? startDate;
    if (startRaw is String) {
      startDate = DateTime.tryParse(startRaw);
    }

    return RecoveryProtocolState(
      protocolStartDate: startDate,
      selectedDayIndex: json['selected_day_index'] as int? ?? 1,
      days: parsedDays,
      totalPenaltyCount: json['total_penalty_count'] as int? ?? 0,
    );
  }
}
