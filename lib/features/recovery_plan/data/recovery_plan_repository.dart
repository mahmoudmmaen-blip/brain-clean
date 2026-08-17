import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/recovery_plan.dart';
import '../domain/recovery_plan_status.dart';
import '../domain/recovery_plan_versions.dart';

/// Abstract persistence for Recovery Plan history.
abstract class RecoveryPlanRepository {
  Future<RecoveryPlan?> active();
  Future<RecoveryPlan?> findById(String planId);
  Future<RecoveryPlan?> findByProfilePackId(String profilePackId);
  Future<List<RecoveryPlan>> history();

  /// Idempotent: same profilePackId + contentHash returns existing.
  Future<RecoveryPlan> save(RecoveryPlan plan);

  /// Explicit rebuild entry — unchanged inputs do not duplicate.
  Future<RecoveryPlan> saveIfNew(RecoveryPlan plan);
}

/// Append-only Hive store — never mutates prior plan JSON payloads.
class RecoveryPlanLocalRepository implements RecoveryPlanRepository {
  RecoveryPlanLocalRepository({Box<dynamic>? box}) : _boxOverride = box;

  static const historyKey = 'plan_history';
  static const schemaKey = 'schema_version';
  static const activeKey = 'active_plan_id';

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.recoveryPlan);
  }

  Future<void> _ensureSchema(Box<dynamic> box) async {
    final existing = box.get(schemaKey);
    if (existing == null) {
      await box.put(schemaKey, RecoveryPlanVersions.schema);
    }
  }

  List<RecoveryPlan> _decodeHistory(dynamic raw) {
    final plans = <RecoveryPlan>[];
    if (raw is! List) return plans;
    for (final item in raw) {
      if (item is! Map) continue;
      try {
        final map = Map<String, dynamic>.from(item);
        if (map.containsKey('plan')) {
          plans.add(RecoveryPlanPack.fromJson(map).plan);
        } else {
          plans.add(RecoveryPlan.fromJson(map));
        }
      } catch (e) {
        debugPrint('RecoveryPlanLocalRepository: skip corrupt plan: $e');
      }
    }
    return plans;
  }

  RecoveryPlan _withPointerStatus(RecoveryPlan plan, String? activeId) {
    if (activeId == null) return plan;
    if (plan.id == activeId) {
      return plan.copyWithStatus(RecoveryPlanStatus.active);
    }
    return plan.copyWithStatus(RecoveryPlanStatus.historical);
  }

  @override
  Future<List<RecoveryPlan>> history() async {
    try {
      final box = await _openBox();
      await _ensureSchema(box);
      final activeId = box.get(activeKey) as String?;
      final plans = _decodeHistory(box.get(historyKey))
          .map((p) => _withPointerStatus(p, activeId))
          .toList();
      plans.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return List<RecoveryPlan>.unmodifiable(plans);
    } catch (e) {
      debugPrint('RecoveryPlanLocalRepository: history failed: $e');
      return const [];
    }
  }

  @override
  Future<RecoveryPlan?> active() async {
    try {
      final box = await _openBox();
      await _ensureSchema(box);
      final activeId = box.get(activeKey) as String?;
      final plans = _decodeHistory(box.get(historyKey));
      if (activeId != null) {
        for (final p in plans) {
          if (p.id == activeId) {
            return p.copyWithStatus(RecoveryPlanStatus.active);
          }
        }
      }
      if (plans.isEmpty) return null;
      return plans.last.copyWithStatus(RecoveryPlanStatus.active);
    } catch (e) {
      debugPrint('RecoveryPlanLocalRepository: active failed: $e');
      return null;
    }
  }

  @override
  Future<RecoveryPlan?> findById(String planId) async {
    final plans = await history();
    for (final p in plans) {
      if (p.id == planId) return p;
    }
    return null;
  }

  @override
  Future<RecoveryPlan?> findByProfilePackId(String profilePackId) async {
    final plans = await history();
    RecoveryPlan? latest;
    for (final p in plans) {
      if (p.source.profilePackId == profilePackId) {
        latest = p;
      }
    }
    return latest;
  }

  @override
  Future<RecoveryPlan> save(RecoveryPlan plan) => saveIfNew(plan);

  @override
  Future<RecoveryPlan> saveIfNew(RecoveryPlan plan) async {
    try {
      final box = await _openBox();
      await _ensureSchema(box);
      final existingRaw = box.get(historyKey);
      final existing = _decodeHistory(existingRaw);

      for (final prior in existing) {
        if (prior.id == plan.id ||
            (prior.source.profilePackId == plan.source.profilePackId &&
                prior.contentHash == plan.contentHash)) {
          await box.put(activeKey, prior.id);
          return prior.copyWithStatus(RecoveryPlanStatus.active);
        }
      }

      // Append-only: keep prior JSON bytes untouched.
      final next = <dynamic>[
        if (existingRaw is List) ...existingRaw,
        RecoveryPlanPack(
          plan: plan,
          schemaVersion: RecoveryPlanVersions.schema,
        ).toJson(),
      ];
      await box.put(historyKey, next);
      await box.put(activeKey, plan.id);
      return plan.copyWithStatus(RecoveryPlanStatus.active);
    } catch (e) {
      debugPrint('RecoveryPlanLocalRepository: save failed: $e');
      rethrow;
    }
  }
}
