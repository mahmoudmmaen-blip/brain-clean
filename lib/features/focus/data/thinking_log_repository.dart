import 'package:hive/hive.dart';

import '../../../core/constants/hive_meta_keys.dart';

/// Persists focused-thinking insight notes to Hive.
class ThinkingLogRepository {
  ThinkingLogRepository(this._box);

  final Box<dynamic> _box;

  List<String> loadEntries() {
    try {
      final raw = _box.get(HiveMetaKeys.thinkingLog);
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> appendEntry(String topic, String insight) async {
    if (insight.trim().isEmpty) return;
    final entries = loadEntries();
    entries.add('${DateTime.now().toIso8601String()}|$topic|${insight.trim()}');
    await _box.put(HiveMetaKeys.thinkingLog, entries);
  }
}
