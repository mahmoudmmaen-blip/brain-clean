import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../detox/domain/detox_habit_scorer.dart';
import '../../detox/presentation/detox_protocol_controller.dart';
import '../domain/diagnostic_metrics_mapper.dart';
import '../domain/diagnostic_model.dart';
import '../domain/diagnostic_session.dart';
import 'diagnostic_controller.dart';

part 'bc_score_provider.g.dart';

/// Recomputes BHI pillars whenever sliders or detox check-ins change.
@riverpod
DiagnosticModel bcScoreLive(BcScoreLiveRef ref) {
  final metrics = ref.watch(diagnosticControllerProvider);
  final detox = ref.watch(detoxProtocolDataProvider);
  final base = DiagnosticMetricsMapper.fromMetrics(metrics);

  return DetoxHabitScorer.applyDetoxToModel(
    base,
    boredomBefriended: detox.boredomBefriended,
    delayedGratificationCount: detox.delayedGratificationCount,
    bodyActivated: detox.bodyActivated,
  );
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
