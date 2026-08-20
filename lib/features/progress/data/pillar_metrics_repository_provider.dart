import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/pillar_metric_snapshot.dart';
import 'pillar_metrics_repository.dart';

final pillarMetricsRepositoryProvider = Provider<PillarMetricsRepository>(
  (ref) => PillarMetricsRepository(),
);

final pillarProgressComparisonProvider =
    FutureProvider<PillarProgressComparison>((ref) async {
  return ref.read(pillarMetricsRepositoryProvider).loadComparison();
});
