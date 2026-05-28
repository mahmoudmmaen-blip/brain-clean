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

  // —— Brain Rot questionnaire (live session tracking) ——
  static const answers = 'answers';
  static const currentIndex = 'currentIndex';
  static const phase = 'phase';

  // —— Brain Rot assessment (committed outcome) ——
  static const score = 'score';
  static const interpretationBand = 'interpretationBand';
  static const interpretationAr = 'interpretationAr';
  static const questionnaireCompletedAt = 'questionnaireCompletedAt';

  // —— DiagnosticModel habit persistence (camelCase local) ——
  static const boredomBefriended = 'boredomBefriended';
  static const delayedGratificationCount = 'delayedGratificationCount';
  static const bodyActivated = 'bodyActivated';

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

  // —— Session accountability metadata (serialized alongside penalties) ——
  static const hasRecoveryPenalty = 'hasRecoveryPenalty';
  static const accountabilityDeductionTotal = 'accountabilityDeductionTotal';

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
  static const boredomBefriendedSnake = 'boredom_befriended';
  static const delayedGratificationCountSnake = 'delayed_gratification_count';
  static const bodyActivatedSnake = 'body_activated';

  // —— Legacy aliases (read-once migration) ——
  static const frozenAtLegacy = 'frozen_at';
  static const frozenPillarsLegacy = 'frozen_pillars';
  static const boundBcScoreLegacy = 'bound_bc_score';
  static const brainRotLegacy = 'brain_rot';

  /// Legacy snake_case → camelCase (read-once migration).
  static const Map<String, String> _legacyToCamel = {
    brainPerformanceSnake: brainPerformance,
    digitalDisciplineSnake: digitalDiscipline,
    healthyHabitsSnake: healthyHabits,
    consistencySnake: consistency,
    bcScoreSnake: bcScore,
    bhiFrozenAtSnake: frozenAt,
    frozenAtLegacy: frozenAt,
    recoveryPenaltyDeductionSnake: recoveryPenaltyDeduction,
    frozenPillarsLegacy: frozenPillars,
    pillarMatrixBcScoreSnake: pillarMatrixBcScore,
    boundBcScoreLegacy: boundBcScore,
    committedAtSnake: committedAt,
    brainRotLegacy: brainRot,
    sleepQualitySnake: sleepQuality,
    sustainedAttentionSnake: sustainedAttention,
    dopamineSeekingSnake: dopamineSeeking,
    taskSwitchingSnake: taskSwitching,
    interpretationBandSnake: interpretationBand,
    interpretationArSnake: interpretationAr,
    questionnaireCompletedAtSnake: questionnaireCompletedAt,
    boredomBefriendedSnake: boredomBefriended,
    delayedGratificationCountSnake: delayedGratificationCount,
    bodyActivatedSnake: bodyActivated,
    accountabilityDeductionTotal: accountabilityDeductionTotal,
  };

  /// Normalizes legacy snake_case keys to camelCase without mutating unknown keys.
  static Map<String, dynamic> normalizeIncoming(Map<String, dynamic> raw) {
    final out = <String, dynamic>{};
    for (final entry in raw.entries) {
      final key = _legacyToCamel[entry.key] ?? entry.key;
      final value = entry.value;
      if (value is Map) {
        out[key] = normalizeIncoming(decodeHiveMap(value));
      } else if (value is List) {
        out[key] = decodeHiveList(value);
      } else {
        out[key] = value;
      }
    }
    return out;
  }

  /// Coerces Hive [Map<dynamic,dynamic>] into string-key maps for JSON parsers.
  static Map<String, dynamic> decodeHiveMap(Map source) {
    return source.map(
      (key, value) => MapEntry(key.toString(), decodeHiveValue(value)),
    );
  }

  static List<dynamic> decodeHiveList(List<dynamic> source) =>
      source.map(decodeHiveValue).toList();

  static dynamic decodeHiveValue(dynamic value) {
    if (value is Map) {
      return decodeHiveMap(Map<dynamic, dynamic>.from(value));
    }
    if (value is List) {
      return decodeHiveList(value);
    }
    return value;
  }

  /// RTL-safe pillar row keys → localized label lookup (AR/EN breakdown widgets).
  static Map<String, String> pillarRowLocalizationKeys() => {
        pillarRowBrainPerformance: pillarRowBrainPerformance,
        pillarRowDigitalDiscipline: pillarRowDigitalDiscipline,
        pillarRowHealthyHabits: pillarRowHealthyHabits,
        pillarRowConsistency: pillarRowConsistency,
      };

  static Map<String, dynamic> requireMap(
    Map<String, dynamic> json,
    String key,
  ) {
    final raw = json[key];
    if (raw is! Map<String, dynamic>) {
      throw FormatException('BhiPillarJsonKeys: missing map for "$key"');
    }
    return raw;
  }

  static double readPenalty(Map<String, dynamic> json) =>
      (json[recoveryPenaltyDeduction] as num?)?.toDouble() ??
      (json[accountabilityDeductionTotal] as num?)?.toDouble() ??
      0;

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

  /// Parses [committedAt] after [normalizeIncoming] (ISO-8601 camelCase).
  static DateTime parseCommittedAt(Map<String, dynamic> json) {
    final normalized = normalizeIncoming(json);
    final raw = normalized[committedAt];
    if (raw is! String) {
      throw FormatException(
        'BhiPillarJsonKeys: missing or invalid "$committedAt"',
      );
    }
    return DateTime.parse(raw);
  }

  /// Returns the nested BHI map or throws — never reads snake_case root keys.
  static Map<String, dynamic> requireBhiMap(Map<String, dynamic> json) {
    final normalized = normalizeIncoming(json);
    final bhiMap = readBhiMap(normalized);
    if (bhiMap != null) return bhiMap;
    throw FormatException('BhiPillarJsonKeys: missing "$bhi" envelope');
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
    target[BhiPillarJsonKeys.hasRecoveryPenalty] = recoveryPenaltyDeduction > 0;
    target[BhiPillarJsonKeys.accountabilityDeductionTotal] =
        recoveryPenaltyDeduction;
  }

  /// Full session JSON map using only [BhiPillarJsonKeys] field names.
  static Map<String, dynamic> sessionToJson({
    required Map<String, dynamic> bhiJson,
    required DateTime committedAt,
    required Map<String, dynamic> questionnaireJson,
    Map<String, dynamic>? brainRotJson,
    required double recoveryPenaltyDeduction,
    required double pillarMatrixBcScore,
    required double boundBcScore,
  }) {
    final map = <String, dynamic>{
      bhi: bhiJson,
      BhiPillarJsonKeys.committedAt: committedAt.toIso8601String(),
      questionnaire: questionnaireJson,
      if (brainRotJson != null) brainRot: brainRotJson,
    };
    writePenaltyEnvelope(
      map,
      recoveryPenaltyDeduction: recoveryPenaltyDeduction,
      pillarMatrixBcScore: pillarMatrixBcScore,
      boundBcScore: boundBcScore,
    );
    return map;
  }
}
