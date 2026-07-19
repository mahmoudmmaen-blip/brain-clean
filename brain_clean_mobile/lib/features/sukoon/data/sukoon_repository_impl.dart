import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/sukoon_repository.dart';
import '../domain/sukoon_session.dart';

class SukoonRepositoryImpl implements SukoonRepository {
  SukoonRepositoryImpl({Box<dynamic>? box}) : _boxOverride = box;

  static const _sessionsKey = 'sukoon_sessions';

  final Box<dynamic>? _boxOverride;

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.sukoon);
  }

  Future<List<SukoonSession>> _readAll() async {
    try {
      final box = await _openBox();
      final raw = box.get(_sessionsKey);
      if (raw is! List) return [];
      return raw
          .whereType<Map>()
          .map((item) => SukoonSession.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      debugPrint('SukoonRepositoryImpl: read failed: $e');
      return [];
    }
  }

  Future<void> _writeAll(List<SukoonSession> sessions) async {
    try {
      final box = await _openBox();
      await box.put(
        _sessionsKey,
        sessions.map((s) => s.toJson()).toList(),
      );
    } catch (e) {
      debugPrint('SukoonRepositoryImpl: write failed: $e');
    }
  }

  @override
  Future<void> saveSession(SukoonSession session) async {
    final all = await _readAll();
    all.add(session);
    await _writeAll(all);
  }

  @override
  Future<List<SukoonSession>> getTodaySessions() async {
    final today = _dateOnly(DateTime.now());
    final all = await _readAll();
    return all
        .where((s) => _dateOnly(s.completedAt) == today)
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  @override
  Future<List<SukoonSession>> getAllSessions() async {
    final all = await _readAll();
    all.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return all;
  }

  @override
  Future<int> getTotalMinutes() async {
    final all = await _readAll();
    var total = 0;
    for (final session in all) {
      total += session.durationMinutes;
    }
    return total;
  }
}
