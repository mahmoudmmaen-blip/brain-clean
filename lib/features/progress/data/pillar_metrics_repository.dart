import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../../interactive_diagnostic/domain/diag_metric.dart';
import '../../interactive_diagnostic/domain/diag_scoring.dart';
import '../domain/pillar_metric_snapshot.dart';

/// Append-only local history of diagnostic pillar scores.
class PillarMetricsRepository {
  PillarMetricsRepository({Box<dynamic>? box}) : _boxOverride = box;

  static const historyKey = 'pillar_metric_history';

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.progress);
  }

  Future<List<PillarMetricSnapshot>> history() async {
    try {
      final box = await _openBox();
      final raw = box.get(historyKey);
      if (raw is! List) return const [];
      final out = <PillarMetricSnapshot>[];
      for (final item in raw) {
        if (item is! Map) continue;
        try {
          out.add(
            PillarMetricSnapshot.fromJson(Map<String, dynamic>.from(item)),
          );
        } catch (e) {
          debugPrint('PillarMetricsRepository: skip corrupt snapshot: $e');
        }
      }
      out.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
      return out;
    } catch (e) {
      debugPrint('PillarMetricsRepository.history: $e');
      return const [];
    }
  }

  Future<void> appendFromDiagnostic(DiagScoreResult result) async {
    final snapshot = PillarMetricSnapshot(
      recordedAt: DateTime.now().toUtc(),
      attention: result.scoreFor(DiagMetric.attention).percent,
      workingMemory: result.scoreFor(DiagMetric.workingMemory).percent,
      screenHabits: result.scoreFor(DiagMetric.screenHabits).percent,
      sleepQuality: result.scoreFor(DiagMetric.sleepQuality).percent,
    );
    final box = await _openBox();
    final existing = await history();
    final next = [...existing, snapshot];
    await box.put(
      historyKey,
      next.map((s) => s.toJson()).toList(growable: false),
    );
  }

  Future<PillarProgressComparison> loadComparison() async {
    final items = await history();
    if (items.isEmpty) {
      return const PillarProgressComparison(
        baseline: null,
        latest: null,
        history: [],
      );
    }
    return PillarProgressComparison(
      baseline: items.first,
      latest: items.last,
      history: List<PillarMetricSnapshot>.unmodifiable(items),
    );
  }
}
