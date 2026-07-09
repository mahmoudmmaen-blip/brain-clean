import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/anxiety_repository.dart';
import '../domain/anxiety_result.dart';

class AnxietyRepositoryImpl implements AnxietyRepository {
  AnxietyRepositoryImpl({Box<dynamic>? box}) : _boxOverride = box;

  static const _latestKey = 'anxiety_latest_result';

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.anxietyPersistence);
  }

  @override
  Future<void> saveResult(AnxietyResult result) async {
    try {
      final box = await _openBox();
      await box.put(_latestKey, result.toJson());
    } catch (e) {
      debugPrint('AnxietyRepositoryImpl: saveResult failed: $e');
    }
  }

  @override
  Future<AnxietyResult?> getLatestResult() async {
    try {
      final box = await _openBox();
      final raw = box.get(_latestKey);
      if (raw is! Map) return null;
      return AnxietyResult.fromJson(Map<String, dynamic>.from(raw));
    } catch (e) {
      debugPrint('AnxietyRepositoryImpl: getLatestResult failed: $e');
      return null;
    }
  }
}
