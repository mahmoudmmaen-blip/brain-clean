import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/diagnostic_session.dart';
import '../../recovery/presentation/recovery_bc_penalty_provider.dart';
import 'diagnostic_controller.dart';
import 'diagnostic_session_flow_provider.dart';

part 'diagnostic_in_progress_session_provider.g.dart';

/// Unified [DiagnosticSession] view for the active diagnostic flow.
///
/// Built exclusively via [DiagnosticController.buildInProgressSession].
@riverpod
DiagnosticSession diagnosticInProgressSession(DiagnosticInProgressSessionRef ref) {
  ref.watch(diagnosticControllerProvider);
  ref.watch(diagnosticSessionFlowProvider);
  ref.watch(diagnosticLiveModelProvider);

  final penaltyTotal = ref.watch(recoveryBcPenaltyTotalProvider);
  return ref.read(diagnosticControllerProvider.notifier).buildInProgressSession(
        recoveryPenaltyTotal: penaltyTotal,
      );
}
