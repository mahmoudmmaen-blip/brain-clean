import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/diagnostic_metrics_mapper.dart';
import '../domain/diagnostic_model.dart';
import '../domain/diagnostic_session.dart';
import 'diagnostic_controller.dart';

part 'bc_score_provider.g.dart';

/// Recomputes BHI pillars whenever any of the 6 diagnostic sliders changes.
@riverpod
DiagnosticModel bcScoreLive(BcScoreLiveRef ref) {
  final metrics = ref.watch(diagnosticControllerProvider);
  return DiagnosticMetricsMapper.fromMetrics(metrics);
}

/// Snapshot saved on diagnostic submit — shown on dashboard.
@riverpod
class BcScoreSession extends _$BcScoreSession {
  @override
  DiagnosticSession? build() => null;

  void commit(DiagnosticModel model) {
    state = DiagnosticSession(
      model: model,
      committedAt: DateTime.now(),
    );
  }

  void clear() => state = null;
}
