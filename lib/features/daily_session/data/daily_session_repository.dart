import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/daily_session.dart';
import '../domain/daily_session_status.dart';
import '../domain/daily_session_version.dart';
import '../domain/session_marked.dart';

abstract class DailySessionRepository {
  Future<DailySession?> active();
  Future<DailySession?> findById(String id);
  Future<DailySession?> findByTodayActAndDay({
    required String todayActId,
    required String dayKey,
  });
  Future<List<DailySession>> history();
  Future<SessionMarked?> latestMark();

  /// Upserts in-progress session; completed sessions become immutable.
  Future<DailySession> save(DailySession session);

  /// Idempotent completion attach.
  Future<DailySession> saveCompletion({
    required DailySession session,
    required SessionMarked mark,
  });
}

class DailySessionLocalRepository implements DailySessionRepository {
  DailySessionLocalRepository({Box<dynamic>? box}) : _boxOverride = box;

  static const historyKey = 'session_history';
  static const activeKey = 'active_session_id';
  static const schemaKey = 'schema_version';
  static const marksKey = 'session_marks';

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.dailySession);
  }

  Future<void> _ensureSchema(Box<dynamic> box) async {
    final existing = box.get(schemaKey);
    if (existing == null) {
      await box.put(schemaKey, DailySessionVersion.schema);
    }
  }

  List<DailySession> _decodeSessions(dynamic raw) {
    final out = <DailySession>[];
    if (raw is! List) return out;
    for (final item in raw) {
      if (item is! Map) continue;
      try {
        out.add(DailySession.fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        debugPrint('DailySessionLocalRepository: skip corrupt session: $e');
      }
    }
    return out;
  }

  List<SessionMarked> _decodeMarks(dynamic raw) {
    final out = <SessionMarked>[];
    if (raw is! List) return out;
    for (final item in raw) {
      if (item is! Map) continue;
      try {
        out.add(SessionMarked.fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        debugPrint('DailySessionLocalRepository: skip corrupt mark: $e');
      }
    }
    return out;
  }

  @override
  Future<List<DailySession>> history() async {
    try {
      final box = await _openBox();
      await _ensureSchema(box);
      return List.unmodifiable(_decodeSessions(box.get(historyKey)));
    } catch (e) {
      debugPrint('DailySessionLocalRepository.history failed: $e');
      return const [];
    }
  }

  @override
  Future<DailySession?> active() async {
    try {
      final box = await _openBox();
      await _ensureSchema(box);
      final id = box.get(activeKey) as String?;
      if (id == null || id.isEmpty) return null;
      return findById(id);
    } catch (e) {
      debugPrint('DailySessionLocalRepository.active failed: $e');
      return null;
    }
  }

  @override
  Future<DailySession?> findById(String id) async {
    if (id.isEmpty) return null;
    final all = await history();
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  Future<DailySession?> findByTodayActAndDay({
    required String todayActId,
    required String dayKey,
  }) async {
    final all = await history();
    for (final s in all.reversed) {
      if (s.todayActId == todayActId && s.dayKey == dayKey) return s;
    }
    return null;
  }

  @override
  Future<SessionMarked?> latestMark() async {
    try {
      final box = await _openBox();
      await _ensureSchema(box);
      final marks = _decodeMarks(box.get(marksKey));
      if (marks.isEmpty) return null;
      marks.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return marks.first;
    } catch (e) {
      debugPrint('DailySessionLocalRepository.latestMark failed: $e');
      return null;
    }
  }

  @override
  Future<DailySession> save(DailySession session) async {
    final box = await _openBox();
    await _ensureSchema(box);
    final existing = await findById(session.id);
    if (existing != null && existing.isImmutable) {
      return existing;
    }
    final list = _decodeSessions(box.get(historyKey));
    final idx = list.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      list[idx] = session;
    } else {
      list.add(session);
    }
    await box.put(
      historyKey,
      list.map((s) => s.toJson()).toList(growable: false),
    );
    await box.put(activeKey, session.id);
    return session;
  }

  @override
  Future<DailySession> saveCompletion({
    required DailySession session,
    required SessionMarked mark,
  }) async {
    final box = await _openBox();
    await _ensureSchema(box);
    final existing = await findById(session.id);
    if (existing != null &&
        existing.status == DailySessionStatus.completed &&
        existing.mark != null) {
      return existing;
    }

    final completed = session.copyWith(
      status: mark.fullCompletion
          ? DailySessionStatus.completed
          : DailySessionStatus.partial,
      mark: mark,
      completedAt: mark.completedAt,
      updatedAt: mark.completedAt,
    );

    final list = _decodeSessions(box.get(historyKey));
    final idx = list.indexWhere((s) => s.id == completed.id);
    if (idx >= 0) {
      if (list[idx].isImmutable && list[idx].mark != null) {
        return list[idx];
      }
      list[idx] = completed;
    } else {
      list.add(completed);
    }
    await box.put(
      historyKey,
      list.map((s) => s.toJson()).toList(growable: false),
    );

    final marks = _decodeMarks(box.get(marksKey));
    if (!marks.any((m) => m.id == mark.id)) {
      marks.add(mark);
      await box.put(
        marksKey,
        marks.map((m) => m.toJson()).toList(growable: false),
      );
    }
    await box.put(activeKey, completed.id);
    return completed;
  }
}
