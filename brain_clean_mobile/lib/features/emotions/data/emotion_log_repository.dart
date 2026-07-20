import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/storage/hive_boxes.dart';
import '../domain/emotion_log_entry.dart';
import '../domain/emotion_model.dart';

/// Persists emotion log entries to Hive box [emotion_log].
class EmotionLogRepository {
  EmotionLogRepository(this._box);

  final Box<dynamic> _box;

  Future<void> append({
    required EmotionModel emotion,
    required double appliedImpact,
    required DateTime timestamp,
  }) async {
    final key = timestamp.millisecondsSinceEpoch.toString();
    await _box.put(key, {
      'label': emotion.label,
      'category': emotion.category.name,
      'intensity': emotion.intensity,
      'appliedImpact': appliedImpact,
      'timestamp': timestamp.toIso8601String(),
    });
  }

  int get count => _box.length;

  /// True if any emotion log entry falls on today's calendar date.
  /// When [after] is set, only entries strictly newer than [after] count.
  bool hasLoggedToday({DateTime? after}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final entry in recentEntries(limit: 200)) {
      final day = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      if (day != today) continue;
      if (after == null || entry.timestamp.isAfter(after)) return true;
    }
    return false;
  }

  /// Latest emotion timestamp for today, or null if none.
  DateTime? latestTodayTimestamp() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? latest;
    for (final entry in recentEntries(limit: 200)) {
      final day = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      if (day != today) continue;
      if (latest == null || entry.timestamp.isAfter(latest)) {
        latest = entry.timestamp;
      }
    }
    return latest;
  }

  List<EmotionLogEntry> recentEntries({int limit = 5}) {
    final entries = <EmotionLogEntry>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final label = map['label'] as String?;
      final category = map['category'] as String?;
      final impact = map['appliedImpact'];
      final ts = map['timestamp'] as String?;
      if (label == null || category == null || ts == null) continue;
      entries.add(
        EmotionLogEntry(
          label: label,
          category: category,
          recoveryImpact: (impact as num?)?.toDouble() ?? 0,
          timestamp: DateTime.tryParse(ts) ?? DateTime.now(),
        ),
      );
    }
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (entries.length <= limit) return entries;
    return entries.sublist(0, limit);
  }
}

final emotionLogBoxProvider = Provider<Box<dynamic>>((ref) {
  if (!Hive.isBoxOpen(HiveBoxes.emotionLog)) {
    throw StateError('Hive box ${HiveBoxes.emotionLog} is not open');
  }
  return Hive.box<dynamic>(HiveBoxes.emotionLog);
});

final emotionLogRepositoryProvider = Provider<EmotionLogRepository>((ref) {
  return EmotionLogRepository(ref.watch(emotionLogBoxProvider));
});
