import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';

/// Persists structured daily program completion checkmarks keyed by day.
abstract class StructuredDailyProgramRepository {
  Future<Map<String, bool>> loadCompletions(String dayKey);

  Future<void> setCompleted({
    required String dayKey,
    required String activityId,
    required bool completed,
  });
}

class StructuredDailyProgramLocalRepository
    implements StructuredDailyProgramRepository {
  StructuredDailyProgramLocalRepository({Box<dynamic>? box})
      : _boxOverride = box;

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    try {
      await HiveBootstrap.warmUpPersistentBoxes();
      return Hive.box<dynamic>(HiveBoxes.structuredDailyProgram);
    } catch (_) {
      // Tests / cold start without cipher — plain box is acceptable for checkmarks.
      if (Hive.isBoxOpen(HiveBoxes.structuredDailyProgram)) {
        return Hive.box<dynamic>(HiveBoxes.structuredDailyProgram);
      }
      return Hive.openBox<dynamic>(HiveBoxes.structuredDailyProgram);
    }
  }

  @override
  Future<Map<String, bool>> loadCompletions(String dayKey) async {
    try {
      final box = await _openBox();
      final raw = box.get(dayKey);
      if (raw is! Map) return const {};
      final out = <String, bool>{};
      raw.forEach((key, value) {
        if (key == null) return;
        out[key.toString()] = value == true;
      });
      return Map<String, bool>.unmodifiable(out);
    } catch (e, st) {
      debugPrint('StructuredDailyProgramLocalRepository.loadCompletions: $e');
      debugPrint('$st');
      return const {};
    }
  }

  @override
  Future<void> setCompleted({
    required String dayKey,
    required String activityId,
    required bool completed,
  }) async {
    try {
      final box = await _openBox();
      final existing = Map<String, dynamic>.from(
        (box.get(dayKey) as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v),
            ) ??
            const <String, dynamic>{},
      );
      existing[activityId] = completed;
      await box.put(dayKey, existing);
    } catch (e, st) {
      debugPrint('StructuredDailyProgramLocalRepository.setCompleted: $e');
      debugPrint('$st');
    }
  }
}
