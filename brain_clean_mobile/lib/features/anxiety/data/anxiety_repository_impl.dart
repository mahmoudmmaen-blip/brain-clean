import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/anxiety_repository.dart';
import '../domain/anxiety_result.dart';

class AnxietyRepositoryImpl implements AnxietyRepository {
  AnxietyRepositoryImpl({Box<dynamic>? box}) : _boxOverride = box;

  static const _latestKey = 'anxiety_latest_result';
  static const _historyKey = 'anxiety_results_history';

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.anxietyPersistence);
  }

  List<AnxietyResult> _parseHistory(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) => AnxietyResult.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<AnxietyResult>> _readHistory(Box<dynamic> box) async {
    final history = _parseHistory(box.get(_historyKey));
    if (history.isNotEmpty) return history;

    final latest = box.get(_latestKey);
    if (latest is Map) {
      return [
        AnxietyResult.fromJson(Map<String, dynamic>.from(latest)),
      ];
    }
    return [];
  }

  @override
  Future<void> saveResult(AnxietyResult result) async {
    try {
      final box = await _openBox();
      var history = _parseHistory(box.get(_historyKey));

      // One-time legacy migration: latest-only storage before history existed.
      if (history.isEmpty && !box.containsKey(_historyKey)) {
        final legacy = box.get(_latestKey);
        if (legacy is Map) {
          final previous = AnxietyResult.fromJson(
            Map<String, dynamic>.from(legacy),
          );
          if (previous.timestamp != result.timestamp) {
            history = [previous];
          }
        }
      }

      await box.put(_latestKey, result.toJson());
      history.add(result);
      await box.put(
        _historyKey,
        history.map((entry) => entry.toJson()).toList(),
      );
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

  @override
  Future<List<AnxietyResult>> getAllResults() async {
    try {
      final box = await _openBox();
      final history = await _readHistory(box);
      history.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return history;
    } catch (e) {
      debugPrint('AnxietyRepositoryImpl: getAllResults failed: $e');
      return [];
    }
  }
}
