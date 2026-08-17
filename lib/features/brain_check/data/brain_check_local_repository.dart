import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/brain_check_progress.dart';
import '../domain/brain_check_result.dart';

/// Local-first Brain Check draft + completed result store.
class BrainCheckLocalRepository {
  BrainCheckLocalRepository({Box<dynamic>? box}) : _boxOverride = box;

  static const draftKey = 'draft_progress';
  static const resultKey = 'completed_result';

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.brainCheck);
  }

  Future<BrainCheckProgress?> loadDraft() async {
    try {
      final box = await _openBox();
      final raw = box.get(draftKey);
      if (raw is! Map) return null;
      return BrainCheckProgress.fromJson(Map<String, dynamic>.from(raw));
    } catch (e) {
      debugPrint('BrainCheckLocalRepository: load draft failed: $e');
      return null;
    }
  }

  Future<void> saveDraft(BrainCheckProgress progress) async {
    try {
      final box = await _openBox();
      await box.put(draftKey, progress.toJson());
    } catch (e) {
      debugPrint('BrainCheckLocalRepository: save draft failed: $e');
      rethrow;
    }
  }

  Future<void> clearDraft() async {
    try {
      final box = await _openBox();
      await box.delete(draftKey);
    } catch (e) {
      debugPrint('BrainCheckLocalRepository: clear draft failed: $e');
    }
  }

  Future<BrainCheckResult?> loadResult() async {
    try {
      final box = await _openBox();
      final raw = box.get(resultKey);
      if (raw is! Map) return null;
      return BrainCheckResult.fromJson(Map<String, dynamic>.from(raw));
    } catch (e) {
      debugPrint('BrainCheckLocalRepository: load result failed: $e');
      return null;
    }
  }

  Future<void> saveResult(BrainCheckResult result) async {
    try {
      final box = await _openBox();
      await box.put(resultKey, result.toJson());
    } catch (e) {
      debugPrint('BrainCheckLocalRepository: save result failed: $e');
      rethrow;
    }
  }

  Future<void> clearResult() async {
    try {
      final box = await _openBox();
      await box.delete(resultKey);
    } catch (e) {
      debugPrint('BrainCheckLocalRepository: clear result failed: $e');
    }
  }
}
