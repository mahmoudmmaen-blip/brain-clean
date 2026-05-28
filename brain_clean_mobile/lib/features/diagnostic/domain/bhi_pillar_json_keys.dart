/// Canonical camelCase keys for BHI frozen pillar, snapshot, and session JSON.
abstract final class BhiPillarJsonKeys {
  // —— Frozen pillar fields ——
  static const brainPerformance = 'brainPerformance';
  static const digitalDiscipline = 'digitalDiscipline';
  static const healthyHabits = 'healthyHabits';
  static const consistency = 'consistency';
  static const bcScore = 'bcScore';
  static const frozenAt = 'frozenAt';
  static const recoveryPenaltyDeduction = 'recoveryPenaltyDeduction';

  // —— DiagnosticBhiSnapshot envelope ——
  static const metrics = 'metrics';
  static const model = 'model';
  static const frozenPillars = 'frozenPillars';
  static const pillarMatrixBcScore = 'pillarMatrixBcScore';
  static const boundBcScore = 'boundBcScore';

  // —— Firestore / remote repository (snake_case boundary only) ——
  static const recoveryPenaltyDeductionSnake = 'recovery_penalty_deduction';
  static const pillarMatrixBcScoreSnake = 'pillar_matrix_bc_score';
  static const bcScoreSnake = 'bc_score';
  static const brainPerformanceSnake = 'brain_performance';
  static const digitalDisciplineSnake = 'digital_discipline';
  static const healthyHabitsSnake = 'healthy_habits';
  static const bhiFrozenSnapshotSnake = 'bhi_frozen_snapshot';

  /// Legacy snake_case → camelCase (read-once migration).
  static const Map<String, String> _legacyToCamel = {
    brainPerformanceSnake: brainPerformance,
    digitalDisciplineSnake: digitalDiscipline,
    healthyHabitsSnake: healthyHabits,
    bcScoreSnake: bcScore,
    'frozen_at': frozenAt,
    recoveryPenaltyDeductionSnake: recoveryPenaltyDeduction,
    'frozen_pillars': frozenPillars,
    pillarMatrixBcScoreSnake: pillarMatrixBcScore,
    'bound_bc_score': boundBcScore,
  };

  /// Normalizes legacy snake_case keys to camelCase without mutating unknown keys.
  static Map<String, dynamic> normalizeIncoming(Map<String, dynamic> raw) {
    final out = <String, dynamic>{};
    for (final entry in raw.entries) {
      final key = _legacyToCamel[entry.key] ?? entry.key;
      final value = entry.value;
      if (value is Map<String, dynamic>) {
        out[key] = normalizeIncoming(value);
      } else {
        out[key] = value;
      }
    }
    return out;
  }

  static double readPenalty(Map<String, dynamic> json) =>
      (json[recoveryPenaltyDeduction] as num?)?.toDouble() ?? 0;

  static double readBcScore(Map<String, dynamic> json) =>
      (json[bcScore] as num?)?.toDouble() ?? 0;

  static double readPillarMatrixBcScore(Map<String, dynamic> json) =>
      (json[pillarMatrixBcScore] as num?)?.toDouble() ?? 0;

  static double readBoundBcScore(Map<String, dynamic> json) =>
      (json[boundBcScore] as num?)?.toDouble() ?? 0;

  static Map<String, dynamic>? readFrozenPillarsMap(Map<String, dynamic> json) {
    final raw = json[frozenPillars];
    if (raw is Map<String, dynamic>) return raw;
    return null;
  }

  /// Embeds recovery accountability fields on a BHI or session JSON map.
  static void writePenaltyEnvelope(
    Map<String, dynamic> target, {
    required double recoveryPenaltyDeduction,
    required double pillarMatrixBcScore,
    required double boundBcScore,
  }) {
    target[BhiPillarJsonKeys.recoveryPenaltyDeduction] = recoveryPenaltyDeduction;
    target[BhiPillarJsonKeys.pillarMatrixBcScore] = pillarMatrixBcScore;
    target[BhiPillarJsonKeys.boundBcScore] = boundBcScore;
    target[BhiPillarJsonKeys.bcScore] = boundBcScore;
  }
}
