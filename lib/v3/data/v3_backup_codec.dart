import 'dart:convert';

/// Serialize / restore the whole v3 Hive box as JSON-safe maps.
abstract final class V3BackupCodec {
  V3BackupCodec._();

  static const payloadVersion = 1;

  /// Wraps a raw box dump for encryption.
  static String encodePayload(Map<String, dynamic> boxDump) {
    return jsonEncode({
      'version': payloadVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'box': boxDump,
    });
  }

  /// Validates and returns the box map from decrypted JSON.
  static Map<String, dynamic> decodePayload(String json) {
    final decoded = jsonDecode(json);
    if (decoded is! Map) {
      throw const FormatException('backup payload not a map');
    }
    final map = Map<String, dynamic>.from(decoded);
    final version = map['version'];
    if (version != payloadVersion) {
      throw FormatException('unsupported backup version: $version');
    }
    final box = map['box'];
    if (box is! Map) {
      throw const FormatException('backup missing box');
    }
    return _jsonSafeMap(Map<String, dynamic>.from(box));
  }

  /// Makes Hive values JSON-encodable (Maps/Lists/primitives).
  static Map<String, dynamic> dumpBox(Map<dynamic, dynamic> entries) {
    final out = <String, dynamic>{};
    for (final entry in entries.entries) {
      out[entry.key.toString()] = jsonSafe(entry.value);
    }
    return out;
  }

  static dynamic jsonSafe(dynamic value) {
    if (value == null ||
        value is String ||
        value is bool ||
        value is int ||
        value is double) {
      return value;
    }
    if (value is num) return value.toDouble();
    if (value is Map) {
      return _jsonSafeMap(Map<String, dynamic>.from(
        value.map((k, v) => MapEntry(k.toString(), v)),
      ));
    }
    if (value is List) {
      return value.map(jsonSafe).toList(growable: false);
    }
    return value.toString();
  }

  static Map<String, dynamic> _jsonSafeMap(Map<String, dynamic> map) {
    return map.map((k, v) => MapEntry(k, jsonSafe(v)));
  }
}
