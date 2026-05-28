import 'recovery_day_record.dart';
import 'recovery_persistence_exception.dart';
import 'recovery_protocol_json_keys.dart';
import 'recovery_protocol_state.dart';

/// Validates and normalizes recovery protocol maps before persistence I/O.
abstract final class RecoveryHivePayload {
  RecoveryHivePayload._();

  /// Rejects snake_case drift keys at any depth (root + day records).
  static void assertCamelCaseOnly(Map<String, dynamic> json) {
    for (final key in json.keys) {
      if (RecoveryProtocolJsonKeys.forbiddenDriftKeys.contains(key)) {
        throw RecoveryPersistenceException(
          'Forbidden drift key "$key" — use camelCase persistence keys only.',
        );
      }
    }

    final daysRaw = json[RecoveryProtocolJsonKeys.days];
    if (daysRaw is Map) {
      for (final dayEntry in daysRaw.entries) {
        if (dayEntry.value is Map) {
          assertCamelCaseOnly(
            Map<String, dynamic>.from(dayEntry.value as Map),
          );
        }
      }
    }
  }

  /// One-time normalization for legacy snake_case blobs written before camelCase migration.
  static Map<String, dynamic> normalizeIncoming(Map<String, dynamic> raw) {
    final hasDrift = raw.keys.any(
      RecoveryProtocolJsonKeys.forbiddenDriftKeys.contains,
    );
    if (!hasDrift) return raw;

    return {
      RecoveryProtocolJsonKeys.protocolStartDate:
          raw[RecoveryProtocolJsonKeys.protocolStartDate] ??
              raw['protocol_start_date'],
      RecoveryProtocolJsonKeys.selectedDayIndex:
          raw[RecoveryProtocolJsonKeys.selectedDayIndex] ??
              raw['selected_day_index'] ??
              1,
      RecoveryProtocolJsonKeys.totalPenaltyCount:
          raw[RecoveryProtocolJsonKeys.totalPenaltyCount] ??
              raw['total_penalty_count'] ??
              0,
      RecoveryProtocolJsonKeys.days: _normalizeDaysMap(
        raw[RecoveryProtocolJsonKeys.days] ?? raw['days'],
      ),
    };
  }

  static Map<String, dynamic> _normalizeDaysMap(Object? daysRaw) {
    if (daysRaw is! Map) return {};
    final out = <String, dynamic>{};
    for (final entry in daysRaw.entries) {
      if (entry.value is! Map) continue;
      final dayMap = Map<String, dynamic>.from(entry.value as Map);
      out[entry.key.toString()] = {
        RecoveryProtocolJsonKeys.dayIndex:
            dayMap[RecoveryProtocolJsonKeys.dayIndex] ??
                dayMap['day_index'] ??
                int.tryParse(entry.key.toString()) ??
                1,
        RecoveryProtocolJsonKeys.taskCompleted:
            dayMap[RecoveryProtocolJsonKeys.taskCompleted] ??
                dayMap['task_completed'] ??
                <bool>[false, false, false, false, false],
        RecoveryProtocolJsonKeys.penaltyApplied:
            dayMap[RecoveryProtocolJsonKeys.penaltyApplied] ??
                dayMap['penalty_applied'] ??
                false,
      };
    }
    return out;
  }

  static Map<String, dynamic> encodeState(RecoveryProtocolState state) {
    final json = state.toJson();
    assertCamelCaseOnly(json);
    return json;
  }

  static RecoveryProtocolState decodeState(Map<String, dynamic> raw) {
    final normalized = normalizeIncoming(raw);
    assertCamelCaseOnly(normalized);
    return RecoveryProtocolState.fromJson(normalized);
  }
}
