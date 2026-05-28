import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../diagnostic/data/diagnostic_repository_provider.dart';
import '../../diagnostic/domain/pillar_bound_evaluation.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../domain/recovery_protocol_constants.dart';
import 'recovery_protocol_controller.dart';

part 'recovery_bc_penalty_provider.g.dart';

/// Total BC_score deducted from recovery penalty box entries (−15 each).
@Riverpod(keepAlive: true)
double recoveryBcPenaltyTotal(RecoveryBcPenaltyTotalRef ref) {
  final recovery = ref.watch(recoveryProtocolControllerProvider);
  return recovery.when(
    data: (state) =>
        state.totalPenaltyCount *
        RecoveryProtocolConstants.penaltyBcScoreDeduction.toDouble(),
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Syncs recovery penalties into committed diagnostic snapshots.
@Riverpod(keepAlive: true)
class RecoveryDiagnosticPenaltySync extends _$RecoveryDiagnosticPenaltySync {
  @override
  void build() {}

  /// Applies cumulative recovery-grid penalty total to the global diagnostic session.
  Future<void> syncFromRecoveryGrid() async {
    final recovery = ref.read(recoveryProtocolControllerProvider).valueOrNull;
    if (recovery == null) return;

    final totalDeduction = recovery.totalPenaltyCount *
        RecoveryProtocolConstants.penaltyBcScoreDeduction.toDouble();

    final committed = ref.read(bcScoreSessionProvider);
    if (committed == null) {
      ref.invalidate(recoveryBcPenaltyTotalProvider);
      return;
    }

    if (PillarBoundEvaluation.scoresMatch(
      committed.recoveryPenaltyDeduction,
      totalDeduction,
    )) {
      return;
    }

    final updated = committed.withRecoveryPenaltyTotal(totalDeduction);
    ref.read(bcScoreSessionProvider.notifier).commit(updated);
    try {
      await ref.read(diagnosticRepositoryProvider).upsertSession(session: updated);
    } catch (_) {
      // Local recovery state remains authoritative; sync retries on next open.
    }
  }
}
