import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/diagnostic_metrics.dart';
import '../domain/diagnostic_session.dart';
import 'bc_score_provider.dart';
import 'diagnostic_controller.dart';
import 'diagnostic_session_flow_provider.dart';

part 'diagnostic_in_progress_session_provider.g.dart';

/// Unified [DiagnosticSession] view for the active diagnostic flow.
///
/// Merges BHI snapshot, slider metrics, and questionnaire state so UI layers
/// consume one model instead of multiple providers.
@riverpod
DiagnosticSession diagnosticInProgressSession(DiagnosticInProgressSessionRef ref) {
  final metrics = ref.watch(diagnosticControllerProvider).value ??
      const DiagnosticMetrics();
  final questionnaire = ref.watch(diagnosticSessionFlowProvider);
  final liveModel = ref.watch(bcScoreLiveProvider);

  return DiagnosticSession.inProgress(
    metrics: metrics,
    model: liveModel,
    questionnaire: questionnaire,
  );
}
