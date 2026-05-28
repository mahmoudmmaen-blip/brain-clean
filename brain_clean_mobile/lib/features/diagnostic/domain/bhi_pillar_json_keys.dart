/// Canonical camelCase keys for BHI frozen pillar, snapshot, session, and API JSON.
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

  // —— DiagnosticSession envelope ——
  static const bhi = 'bhi';
  static const committedAt = 'committedAt';
  static const brainRot = 'brainRot';
  static const questionnaire = 'questionnaire';

  // —— PillarBoundEvaluation row identifiers (UI + breakdown maps) ——
  static const pillarRowBrainPerformance = 'brain_performance';
  static const pillarRowDigitalDiscipline = 'digital_discipline';
  static const pillarRowHealthyHabits = 'healthy_habits';
  static const pillarRowConsistency = 'consistency';

  // —— DiagnosticMetrics (6-point slider) camelCase ——
  static const sleepQuality = 'sleepQuality';
  static const sustainedAttention = 'sustainedAttention';
  static const fragmentation = 'fragmentation';
  static const dopamineSeeking = 'dopamineSeeking';
  static const taskSwitching = 'taskSwitching';
  static const burnout = 'burnout';

  // —— Firestore / remote repository (snake_case boundary only) ——
  static const recoveryPenaltyDeductionSnake = 'recovery_penalty_deduction';
  static const pillarMatrixBcScoreSnake = 'pillar_matrix_bc_score';
  static const bcScoreSnake = 'bc_score';
  static const brainPerformanceSnake = 'brain_performance';
  static const digitalDisciplineSnake = 'digital_discipline';
  static const healthyHabitsSnake = 'healthy_habits';
  static const consistencySnake = 'consistency';
  static const bhiFrozenSnapshotSnake = 'bhi_frozen_snapshot';
  static const bhiFrozenAtSnake = 'bhi_frozen_at';
  static const bhiFrozenBcScoreSnake = 'bhi_frozen_bc_score';
  static const committedAtSnake = 'committed_at';
  static const sessionJsonSnake = 'session_json';
  static const questionnaireJsonSnake = 'questionnaire_json';
  static const mappedBrainPerformanceSnake = 'mapped_brain_performance';
  static const mappedDigitalDisciplineSnake = 'mapped_digital_discipline';
  static const mappedHealthyHabitsSnake = 'mapped_healthy_habits';
  static const mappedConsistencySnake = 'mapped_consistency';
  static const sleepQualitySnake = 'sleep_quality';
  static const sustainedAttentionSnake = 'sustained_attention';
  static const fragmentationSnake = 'fragmentation';
  static const dopamineSeekingSnake = 'dopamine_seeking';
  static const taskSwitchingSnake = 'task_switching';
  static const burnoutSnake = 'burnout';
  static const questionnairePhaseSnake = 'questionnaire_phase';
  static const questionnaireCurrentIndexSnake = 'questionnaire_current_index';
  static const questionnaireAnsweredCountSnake = 'questionnaire_answered_count';
  static const brainRotScoreSnake = 'brain_rot_score';
  static const interpretationBandSnake = 'interpretation_band';
  static const interpretationArSnake = 'interpretation_ar';
  static const brainRotAnswersSnake = 'brain_rot_answers';
  static const questionnaireCompletedAtSnake = 'questionnaire_completed_at';

  /// Legacy snake_case → camelCase (read-once migration).
  static const Map<String, String> _legacyToCamel = {
    brainPerformanceSnake: brainPerformance,
    digitalDisciplineSnake: digitalDiscipline,
    healthyHabitsSnake: healthyHabits,
    consistencySnake: consistency,
    bcScoreSnake: bcScore,
    bhiFrozenAtSnake: frozenAt,
    'frozen_at': frozenAt,
    recoveryPenaltyDeductionSnake: recoveryPenaltyDeduction,
    'frozen_pillars': frozenPillars,
    pillarMatrixBcScoreSnake: pillarMatrixBcScore,
    'bound_bc_score': boundBcScore,
    committedAtSnake: committedAt,
    'brain_rot': brainRot,
    sleepQualitySnake: sleepQuality,
    sustainedAttentionSnake: sustainedAttention,
    dopamineSeekingSnake: dopamineSeeking,
    taskSwitchingSnake: taskSwitching,
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

  static Map<String, dynamic>? readBhiMap(Map<String, dynamic> json) {
    final raw = json[bhi];
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
