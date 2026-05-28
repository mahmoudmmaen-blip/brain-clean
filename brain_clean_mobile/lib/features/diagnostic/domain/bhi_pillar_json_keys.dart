/// Canonical camelCase keys for BHI frozen pillar local / session JSON.
abstract final class BhiPillarJsonKeys {
  static const brainPerformance = 'brainPerformance';
  static const digitalDiscipline = 'digitalDiscipline';
  static const healthyHabits = 'healthyHabits';
  static const consistency = 'consistency';
  static const bcScore = 'bcScore';
  static const frozenAt = 'frozenAt';
  static const recoveryPenaltyDeduction = 'recoveryPenaltyDeduction';

  static const frozenPillars = 'frozenPillars';
  static const pillarMatrixBcScore = 'pillarMatrixBcScore';
  static const boundBcScore = 'boundBcScore';

  /// Legacy snake_case → camelCase (read-once migration).
  static const Map<String, String> _legacyToCamel = {
    'brain_performance': brainPerformance,
    'digital_discipline': digitalDiscipline,
    'healthy_habits': healthyHabits,
    'bc_score': bcScore,
    'frozen_at': frozenAt,
    'recovery_penalty_deduction': recoveryPenaltyDeduction,
    'frozen_pillars': frozenPillars,
    'pillar_matrix_bc_score': pillarMatrixBcScore,
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
}
