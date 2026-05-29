import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/storage/hive_boxes.dart';
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
