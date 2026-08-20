import 'package:uuid/uuid.dart';

import '../../brain_check/domain/brain_check_mode.dart';
import '../../brain_profile/data/brain_profile_repository.dart';
import '../../brain_profile/domain/brain_profile_domain_result.dart';
import '../../brain_profile/domain/measurement_confidence.dart';
import '../../brain_profile/domain/measurement_explanation.dart';
import '../../brain_profile/domain/profile_pack.dart';
import '../../brain_profile/domain/profile_source_reference.dart';
import '../../brain_profile/domain/profile_version.dart';
import '../../brain_profile/domain/recovery_score.dart';
import '../../brain_profile/domain/recovery_score_engine.dart';
import '../../recovery_plan/application/recovery_plan_generator.dart';
import '../../recovery_plan/domain/recovery_plan.dart';
import '../../progress/data/pillar_metrics_repository.dart';
import '../domain/diag_metric.dart';
import '../domain/diag_scoring.dart';

/// Persists a ProfilePack from diagnostic scores and regenerates the plan.
class InteractiveDiagnosticProfileBridge {
  InteractiveDiagnosticProfileBridge({
    required BrainProfileRepository profileRepository,
    required RecoveryPlanGenerator planGenerator,
    required PillarMetricsRepository pillarMetricsRepository,
    Uuid? uuid,
    DateTime Function()? clock,
  })  : _profiles = profileRepository,
        _plans = planGenerator,
        _pillarMetrics = pillarMetricsRepository,
        _uuid = uuid ?? const Uuid(),
        _clock = clock ?? DateTime.now;

  final BrainProfileRepository _profiles;
  final RecoveryPlanGenerator _plans;
  final PillarMetricsRepository _pillarMetrics;
  final Uuid _uuid;
  final DateTime Function() _clock;

  Future<RecoveryPlan> persistAndUpdatePlan(DiagScoreResult result) async {
    final sessionId = _uuid.v4();
    final pack = _buildProfilePack(result, sessionId);
    await _profiles.save(pack);
    await _pillarMetrics.appendFromDiagnostic(result);
    return _plans.generateFor(pack);
  }

  ProfilePack _buildProfilePack(DiagScoreResult result, String sessionId) {
    final now = _clock().toUtc();
    final attentionScore = result.scoreFor(DiagMetric.attention).percent;
    final workingMemoryScore =
        result.scoreFor(DiagMetric.workingMemory).percent;
    final screenScore = result.scoreFor(DiagMetric.screenHabits).percent;
    final sleepScore = result.scoreFor(DiagMetric.sleepQuality).percent;

    final liteAttention = attentionScore < workingMemoryScore
        ? attentionScore
        : workingMemoryScore;
    final liteRecovery =
        screenScore < sleepScore ? screenScore : sleepScore;

    final domains = <BrainProfileDomainResult>[
      BrainProfileDomainResult(
        domainId: 'lite_attention',
        titleEn: 'Attention',
        titleAr: 'الانتباه',
        answeredCount: 2,
        expectedCount: 2,
        missingQuestionIds: const [],
        normalizedMean: liteAttention.toDouble(),
        displayScore: liteAttention,
      ),
      BrainProfileDomainResult(
        domainId: 'lite_recovery',
        titleEn: 'Recovery readiness',
        titleAr: 'جاهزية التعافي',
        answeredCount: 2,
        expectedCount: 2,
        missingQuestionIds: const [],
        normalizedMean: liteRecovery.toDouble(),
        displayScore: liteRecovery,
      ),
    ];

    final stronger = domains.where((d) => d.displayScore! >= 60).toList()
      ..sort((a, b) => b.displayScore!.compareTo(a.displayScore!));
    final support = domains.where((d) => d.displayScore! < 60).toList()
      ..sort((a, b) => a.displayScore!.compareTo(b.displayScore!));

    final explanation = ProfileExplanationCatalog.build(
      strongerTitlesEn: stronger.map((d) => d.titleEn).toList(growable: false),
      strongerTitlesAr: stronger.map((d) => d.titleAr).toList(growable: false),
      supportTitlesEn: support.map((d) => d.titleEn).toList(growable: false),
      supportTitlesAr: support.map((d) => d.titleAr).toList(growable: false),
      confidence: MeasurementConfidence.moderate,
      scorePending: false,
    );

    return ProfilePack(
      id: _uuid.v4(),
      source: ProfileSourceReference(
        sessionId: sessionId,
        mode: BrainCheckMode.lite,
        brainCheckSchemaVersion: ProfileVersion.brainCheckSchema,
        source: 'interactive_diagnostic',
      ),
      createdAt: now,
      lastRecalculatedAt: now,
      domains: domains,
      recoveryScore: RecoveryScore(
        modelVersion: ProfileVersion.recoveryScoreModel,
        band: RecoveryScoreEngine.bandForDisplay(result.overallPercent),
        value: result.overallPercent,
        valueInternal: result.overallPercent.toDouble(),
        weightSetVersion: ProfileVersion.weightSet,
      ),
      confidence: MeasurementConfidence.moderate,
      explanation: explanation,
      profileSchemaVersion: ProfileVersion.profileSchema,
      domainAggregationModelVersion: ProfileVersion.domainAggregationModel,
    );
  }
}
