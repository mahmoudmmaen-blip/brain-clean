import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/progress_snapshot.dart';
import '../domain/progress_version.dart';

abstract class ProgressRepository {
  Future<ProgressSnapshot?> latest();
  Future<List<ProgressSnapshot>> history();
  Future<ProgressSnapshot?> findById(String id);

  /// Append-only: identical contentHash returns existing snapshot.
  Future<ProgressSnapshot> saveIfNew(ProgressSnapshot snapshot);
}

class ProgressLocalRepository implements ProgressRepository {
  ProgressLocalRepository({Box<dynamic>? box}) : _boxOverride = box;

  static const historyKey = 'progress_history';
  static const latestKey = 'latest_snapshot_id';
  static const schemaKey = 'schema_version';

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.progress);
  }

  Future<void> _ensureSchema(Box<dynamic> box) async {
    final existing = box.get(schemaKey);
    if (existing == null) {
      await box.put(schemaKey, ProgressVersion.schema);
    }
  }

  List<ProgressSnapshot> _decode(dynamic raw) {
    final out = <ProgressSnapshot>[];
    if (raw is! List) return out;
    for (final item in raw) {
      if (item is! Map) continue;
      try {
        out.add(ProgressSnapshot.fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        debugPrint('ProgressLocalRepository: skip corrupt snapshot: $e');
      }
    }
    return out;
  }

  @override
  Future<List<ProgressSnapshot>> history() async {
    try {
      final box = await _openBox();
      await _ensureSchema(box);
      return List.unmodifiable(_decode(box.get(historyKey)));
    } catch (e) {
      debugPrint('ProgressLocalRepository.history failed: $e');
      return const [];
    }
  }

  @override
  Future<ProgressSnapshot?> latest() async {
    try {
      final box = await _openBox();
      await _ensureSchema(box);
      final id = box.get(latestKey) as String?;
      if (id != null && id.isNotEmpty) {
        final found = await findById(id);
        if (found != null) return found;
      }
      final all = await history();
      if (all.isEmpty) return null;
      return all.last;
    } catch (e) {
      debugPrint('ProgressLocalRepository.latest failed: $e');
      return null;
    }
  }

  @override
  Future<ProgressSnapshot?> findById(String id) async {
    if (id.isEmpty) return null;
    final all = await history();
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  Future<ProgressSnapshot> saveIfNew(ProgressSnapshot snapshot) async {
    final box = await _openBox();
    await _ensureSchema(box);
    final list = _decode(box.get(historyKey));
    for (final existing in list) {
      if (existing.contentHash == snapshot.contentHash) {
        await box.put(latestKey, existing.id);
        return existing;
      }
    }
    list.add(snapshot);
    await box.put(
      historyKey,
      list.map((s) => s.toJson()).toList(growable: false),
    );
    await box.put(latestKey, snapshot.id);
    return snapshot;
  }
}
