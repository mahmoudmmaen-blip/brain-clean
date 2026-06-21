import 'recovery_day_record.dart';
import 'recovery_persistence_exception.dart';
import 'recovery_protocol_json_keys.dart';
import 'recovery_protocol_load_result.dart';
import 'recovery_protocol_state.dart';

/// Validates, normalizes, and migrates recovery protocol maps for Hive I/O.
abstract final class RecoveryHivePayload {
  RecoveryHivePayload._();

  /// Rejects snake_case drift keys at any depth (strict encode / assert paths).
  static void assertCamelCaseOnly(Map<String, dynamic> json) {
    for (final key in json.keys) {
      if (RecoveryProtocolJsonKeys.forbiddenDriftKeys.contains(key)) {
        throw RecoveryPersistenceException(
          'Forbidden drift key "$key" — use camelCase persistence keys only.',
        );
      }
      if (!_isAllowedRootKey(key)) {
        throw RecoveryPersistenceException(
          'Unexpected root key "$key" in recovery protocol payload.',
        );
      }
    }

    final daysRaw = json[RecoveryProtocolJsonKeys.days];
    if (daysRaw is Map) {
      for (final dayEntry in daysRaw.entries) {
        if (dayEntry.value is Map) {
          _assertDayRecordCamelCaseOnly(
            Map<String, dynamic>.from(dayEntry.value as Map),
          );
        }
      }
    }
  }

  static void _assertDayRecordCamelCaseOnly(Map<String, dynamic> json) {
    for (final key in json.keys) {
      if (RecoveryProtocolJsonKeys.forbiddenDriftKeys.contains(key)) {
        throw RecoveryPersistenceException(
          'Forbidden drift key "$key" in day record.',
        );
      }
      if (!RecoveryProtocolJsonKeys.allowedDayRecordKeys.contains(key)) {
        throw RecoveryPersistenceException(
          'Unexpected day record key "$key".',
        );
      }
    }
  }

  static bool _isAllowedRootKey(String key) =>
      RecoveryProtocolJsonKeys.allowedRootKeys.contains(key);

  static bool hasLegacyDriftKeys(Map<String, dynamic> raw) =>
      raw.keys.any(RecoveryProtocolJsonKeys.forbiddenDriftKeys.contains) ||
      _daysMapHasLegacyDrift(raw[RecoveryProtocolJsonKeys.days] ?? raw['days']);

  static bool _daysMapHasLegacyDrift(Object? daysRaw) {
    if (daysRaw is! Map) return false;
    for (final entry in daysRaw.entries) {
      if (entry.value is! Map) continue;
      final dayMap = entry.value as Map;
      if (dayMap.keys.any(
        RecoveryProtocolJsonKeys.forbiddenDriftKeys.contains,
      )) {
        return true;
      }
    }
    return false;
  }

  /// Coerces unknown Hive values into a map or marks payload unusable.
  static Map<String, dynamic>? coerceToMap(Object? raw) {
    if (raw == null) return null;
    if (raw is RecoveryProtocolState) {
      return encodeState(raw);
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  /// One-time normalization for legacy snake_case blobs.
  static Map<String, dynamic> normalizeIncoming(Map<String, dynamic> raw) {
    final sanitized = _sanitizeRootMap(raw);
    final hasDrift = hasLegacyDriftKeys(sanitized);
    if (!hasDrift) return _pickAllowedRootKeys(sanitized);

    return _pickAllowedRootKeys({
      RecoveryProtocolJsonKeys.protocolStartDate:
          sanitized[RecoveryProtocolJsonKeys.protocolStartDate] ??
              sanitized['protocol_start_date'],
      RecoveryProtocolJsonKeys.selectedDayIndex: _readInt(
        sanitized[RecoveryProtocolJsonKeys.selectedDayIndex] ??
            sanitized['selected_day_index'],
        fallback: 1,
      ),
      RecoveryProtocolJsonKeys.totalPenaltyCount: _readInt(
        sanitized[RecoveryProtocolJsonKeys.totalPenaltyCount] ??
            sanitized['total_penalty_count'],
        fallback: 0,
      ),
      RecoveryProtocolJsonKeys.days: _normalizeDaysMap(
        sanitized[RecoveryProtocolJsonKeys.days] ?? sanitized['days'],
      ),
    });
  }

  static Map<String, dynamic> _sanitizeRootMap(Map<String, dynamic> raw) {
    return Map<String, dynamic>.from(raw);
  }

  static Map<String, dynamic> _pickAllowedRootKeys(Map<String, dynamic> json) {
    final daysRaw = json[RecoveryProtocolJsonKeys.days];
    return {
      if (json.containsKey(RecoveryProtocolJsonKeys.protocolStartDate))
        RecoveryProtocolJsonKeys.protocolStartDate:
            json[RecoveryProtocolJsonKeys.protocolStartDate],
      RecoveryProtocolJsonKeys.selectedDayIndex: _readInt(
        json[RecoveryProtocolJsonKeys.selectedDayIndex],
        fallback: 1,
      ).clamp(1, 30),
      RecoveryProtocolJsonKeys.totalPenaltyCount: _readInt(
        json[RecoveryProtocolJsonKeys.totalPenaltyCount],
        fallback: 0,
      ),
      RecoveryProtocolJsonKeys.days:
          daysRaw is Map ? _normalizeDaysMap(daysRaw) : <String, dynamic>{},
    };
  }

  static int _readInt(Object? value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.round();
    return fallback;
  }

  static Map<String, dynamic> _normalizeDaysMap(Object? daysRaw) {
    if (daysRaw is! Map) return {};
    final out = <String, dynamic>{};
    for (final entry in daysRaw.entries) {
      if (entry.value is! Map) continue;
      final dayMap = Map<String, dynamic>.from(entry.value as Map);
      final index = _readInt(
        dayMap[RecoveryProtocolJsonKeys.dayIndex] ??
            dayMap['day_index'] ??
            int.tryParse(entry.key.toString()),
        fallback: 1,
      ).clamp(1, 30);
      out[entry.key.toString()] = {
        RecoveryProtocolJsonKeys.dayIndex: index,
        RecoveryProtocolJsonKeys.taskCompleted:
            _normalizeTaskList(dayMap),
        RecoveryProtocolJsonKeys.penaltyApplied:
            dayMap[RecoveryProtocolJsonKeys.penaltyApplied] == true ||
                dayMap['penalty_applied'] == true,
      };
    }
    return out;
  }

  static List<bool> _normalizeTaskList(Map<String, dynamic> dayMap) {
    final raw = dayMap[RecoveryProtocolJsonKeys.taskCompleted] ??
        dayMap['task_completed'];
    final tasks = List<bool>.filled(5, false);
    if (raw is List) {
      for (var i = 0; i < 5 && i < raw.length; i++) {
        tasks[i] = raw[i] == true;
      }
    }
    return tasks;
  }

  static Map<String, dynamic> encodeState(RecoveryProtocolState state) {
    final json = state.toJson();
    assertCamelCaseOnly(json);
    return json;
  }

  /// Strict decode for tests and verified camelCase payloads.
  static RecoveryProtocolState decodeState(Map<String, dynamic> raw) {
    final normalized = normalizeIncoming(raw);
    assertCamelCaseOnly(normalized);
    return RecoveryProtocolState.fromJson(normalized);
  }

  /// Non-throwing parse for Hive reads — migrates legacy, drops corrupt payloads.
  static RecoveryProtocolLoadResult tryParsePersisted(Object? raw) {
    final map = coerceToMap(raw);
    if (map == null) {
      if (raw == null) return const RecoveryProtocolLoadResult.missing();
      return const RecoveryProtocolLoadResult.corrupt();
    }

    try {
      final migrated = hasLegacyDriftKeys(map);
      final normalized = normalizeIncoming(map);
      final state = RecoveryProtocolState.fromJson(normalized);
      return RecoveryProtocolLoadResult.success(
        state,
        migratedFromLegacy: migrated,
      );
    } catch (_) {
      return const RecoveryProtocolLoadResult.corrupt();
    }
  }
}
