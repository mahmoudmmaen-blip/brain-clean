import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/diagnostic_local_repository_provider.dart';
import '../domain/diagnostic_model.dart';
import '../domain/diagnostic_session.dart';
import 'diagnostic_controller.dart';

part 'bc_score_provider.g.dart';

/// Recomputes BHI pillars whenever sliders or detox check-ins change.
///
/// Delegates to [diagnosticLiveModelProvider] — authoritative path is
/// [DiagnosticSessionComposer.resolveLiveModel].
@riverpod
DiagnosticModel bcScoreLive(BcScoreLiveRef ref) =>
    ref.watch(diagnosticLiveModelProvider);

/// Snapshot saved on diagnostic submit — shown on dashboard.
@riverpod
class BcScoreSession extends _$BcScoreSession {
  @override
  DiagnosticSession? build() => null;

  void commit(DiagnosticSession session) {
    session.ensurePillarBoundCoherence();
    state = session;
    ref.read(diagnosticLocalRepositoryProvider).saveCommittedSession(session);
  }

  void clear() {
    state = null;
    ref.read(diagnosticLocalRepositoryProvider).clearCommittedSession();
  }

  /// Applies an accountability-room penalty (−[amount] BC_score).
  void applyPenalty(double amount) {
    final current = state;
    if (current == null) return;
    commit(
      current.withRecoveryPenaltyTotal(
        current.recoveryPenaltyDeduction + amount,
      ),
    );
  }

  /// Applies emotion-wheel impact as a fraction of current BC_score.
  void applyEmotionImpact(double impactFraction) {
    final current = state;
    if (current == null || impactFraction == 0) return;
    final delta = current.bcScore * impactFraction.abs();
    if (impactFraction < 0) {
      applyPenalty(delta);
    } else {
      final reducedPenalty =
          (current.recoveryPenaltyDeduction - delta).clamp(0.0, double.infinity);
      commit(current.withRecoveryPenaltyTotal(reducedPenalty));
    }
    _ensureBcsInRange();
  }

  void _ensureBcsInRange() {
    final current = state;
    if (current == null) return;
    final clamped = current.bcScore.clamp(0.0, 100.0);
    if ((current.bcScore - clamped).abs() < 0.001) return;
    final adjustment = current.bcScore - clamped;
    commit(
      current.withRecoveryPenaltyTotal(
        current.recoveryPenaltyDeduction + adjustment,
      ),
    );
  }

  /// Grants a focus-challenge bonus (+[amount] BC_score).
  void applyBonus(double amount) {
    final current = state;
    if (current == null || amount <= 0) return;
    final reducedPenalty =
        (current.recoveryPenaltyDeduction - amount).clamp(0.0, double.infinity);
    commit(current.withRecoveryPenaltyTotal(reducedPenalty));
  }

  /// Grants cognitive test bonus (+[amount] BC_score).
  void applyCognitiveBonus(double amount) => applyBonus(amount);
}

/// Alias for accountability UI — maps to [bcScoreSessionProvider].
final bcScoreProvider = bcScoreSessionProvider;
