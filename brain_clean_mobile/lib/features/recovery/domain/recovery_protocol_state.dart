import 'recovery_day_record.dart';
import 'recovery_hive_payload.dart';
import 'recovery_protocol_constants.dart';
import 'recovery_protocol_json_keys.dart';

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

  /// camelCase JSON for Hive persistence (write path).
  Map<String, dynamic> toJson() => {
        RecoveryProtocolJsonKeys.protocolStartDate:
            protocolStartDate?.toIso8601String(),
        RecoveryProtocolJsonKeys.selectedDayIndex: selectedDayIndex,
        RecoveryProtocolJsonKeys.totalPenaltyCount: totalPenaltyCount,
        RecoveryProtocolJsonKeys.days: days.map(
          (key, value) => MapEntry(key.toString(), value.toJson()),
        ),
      };

  /// camelCase JSON after [RecoveryHivePayload] normalization (read path).
  factory RecoveryProtocolState.fromJson(Map<String, dynamic> json) {
    final daysRaw = json[RecoveryProtocolJsonKeys.days];
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

    final startRaw = json[RecoveryProtocolJsonKeys.protocolStartDate];
    DateTime? startDate;
    if (startRaw is String) {
      startDate = DateTime.tryParse(startRaw);
    }

    final selected = json[RecoveryProtocolJsonKeys.selectedDayIndex];
    final penalties = json[RecoveryProtocolJsonKeys.totalPenaltyCount];

    return RecoveryProtocolState(
      protocolStartDate: startDate,
      selectedDayIndex: selected is int
          ? selected.clamp(1, RecoveryProtocolConstants.dayCount)
          : (selected is num ? selected.round() : 1).clamp(
              1,
              RecoveryProtocolConstants.dayCount,
            ),
      days: parsedDays,
      totalPenaltyCount: penalties is int
          ? penalties
          : (penalties is num ? penalties.round() : 0),
    );
  }

  /// Safe Hive read — legacy migration + drift normalization.
  factory RecoveryProtocolState.fromPersistenceJson(
    Map<String, dynamic> json,
  ) =>
      RecoveryHivePayload.decodeState(json);
}
