import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../brain_check/domain/brain_check_mode.dart';
import '../../brain_profile/domain/measurement_confidence.dart';
import '../../brain_profile/domain/profile_pack.dart';
import '../../brain_profile/domain/recovery_score.dart';
import 'intensity_selector.dart';
import 'plan_because.dart';
import 'practice_mapper.dart';
import 'priority_selector.dart';
import 'recovery_plan.dart';
import 'recovery_plan_cadence.dart';
import 'recovery_plan_day_template.dart';
import 'recovery_plan_explanation.dart';
import 'recovery_plan_intensity.dart';
import 'recovery_plan_priority.dart';
import 'recovery_plan_source_reference.dart';
import 'recovery_plan_status.dart';
import 'recovery_plan_step.dart';
import 'recovery_plan_versions.dart';
import 'recovery_practice_catalog.dart';
import 'today_act.dart';

/// Pure deterministic Recovery Plan engine V1.
///
/// No AI, network, randomness, ads, or subscription inputs.
abstract final class RecoveryPlanEngineV1 {
  static const engineVersion = RecoveryPlanVersions.engine;
  static const catalogVersion = RecoveryPlanVersions.catalog;

  /// Generate a plan from a ProfilePack. Does not persist.
  ///
  /// [isPremium] is accepted only to prove Free/Premium identity — ignored.
  static RecoveryPlan generate(
    ProfilePack pack, {
    bool isPremium = false,
    String? requestedEngineVersion,
    String? requestedCatalogVersion,
    DateTime? createdAt,
  }) {
    // Ignore entitlement deliberately.
    // ignore: unused_local_variable
    final _ = isPremium;

    final engineOk = requestedEngineVersion == null ||
        requestedEngineVersion == engineVersion;
    final catalogOk = requestedCatalogVersion == null ||
        requestedCatalogVersion == catalogVersion;

    if (!engineOk || !catalogOk) {
      return _starter(pack, createdAt: createdAt, reason: 'unsupported_version');
    }

    if (!pack.hasValidRecoveryScore) {
      return _starter(pack, createdAt: createdAt, reason: 'score_unavailable');
    }

    final priority = PrioritySelector.select(pack);
    if (priority.priorities.isEmpty) {
      return _starter(pack, createdAt: createdAt, reason: 'no_priority_domains');
    }

    final intensity = IntensitySelector.select(
      pack: pack,
      priorityCount: priority.priorities.length,
    );
    final omitOptionals =
        pack.confidence == MeasurementConfidence.provisional;
    final steps = PracticeMapper.map(
      priority: priority,
      intensity: intensity,
      omitOptionals: omitOptionals,
    );

    if (steps.isEmpty) {
      return _starter(pack, createdAt: createdAt, reason: 'empty_mapping');
    }

    final cadence = RecoveryPlanCadence.forIntensity(intensity);
    final because = _selectBecause(
      pack: pack,
      priority: priority,
      starter: false,
    );
    final explanation = _buildExplanation(
      pack: pack,
      priority: priority,
      intensity: intensity,
      because: because,
      starter: false,
    );

    final contentHash = computeContentHash(
      profilePackId: pack.id,
      scoreValue: pack.recoveryScore.value,
      scoreBand: pack.recoveryScore.band.wireName,
      confidence: pack.confidence.wireName,
      priorityIds: priority.priorities.map((p) => p.domainId).toList(),
      intensity: intensity.wireName,
      practiceIds: steps.map((s) => s.practiceId).toList(),
      engineVersion: engineVersion,
      catalogVersion: catalogVersion,
    );
    final planId = 'rplan_$contentHash';
    final today = _buildTodayAct(
      planId: planId,
      dayIndex: 0,
      priority: priority,
      steps: steps,
      intensity: intensity,
      because: because,
    );

    return RecoveryPlan(
      id: planId,
      contentHash: contentHash,
      source: RecoveryPlanSourceReference(
        profilePackId: pack.id,
        brainCheckSessionId: pack.source.sessionId,
        scoreModelVersion: pack.recoveryScore.modelVersion,
        profileSchemaVersion: pack.profileSchemaVersion,
      ),
      createdAt: (createdAt ?? DateTime.now()).toUtc(),
      status: RecoveryPlanStatus.active,
      generationStatus: RecoveryPlanStatus.ready,
      priority: priority,
      confidence: pack.confidence,
      intensity: intensity,
      cadence: cadence,
      steps: steps,
      dayTemplate: RecoveryPlanDayTemplate(
        dayIndexSeed: 0,
        steps: steps,
        todayPreview: today,
      ),
      explanation: explanation,
      engineVersion: engineVersion,
      catalogVersion: catalogVersion,
      schemaVersion: RecoveryPlanVersions.schema,
      missingIndicators: pack.missingDataIndicators,
      isStarterFallback: false,
    );
  }

  static RecoveryPlan _starter(
    ProfilePack pack, {
    DateTime? createdAt,
    required String reason,
  }) {
    final step = RecoveryPlanStep.fromPractice(
      practiceId: 'prac_starter_calm',
      targetDomainId: pack.domains.isNotEmpty
          ? pack.domains.first.domainId
          : 'starter',
      optional: false,
    );
    final steps = <RecoveryPlanStep>[step];
    final intensity = RecoveryPlanIntensity.light;
    final cadence = RecoveryPlanCadence.forIntensity(intensity);
    final because = PlanBecauseTemplates.resolve(
      templateKey: PlanBecauseTemplates.starter,
    );
    final emptyPriority = const RecoveryPlanPriority(priorities: []);
    final explanation = _buildExplanation(
      pack: pack,
      priority: emptyPriority,
      intensity: intensity,
      because: because,
      starter: true,
    );
    final contentHash = computeContentHash(
      profilePackId: pack.id,
      scoreValue: pack.recoveryScore.value,
      scoreBand: pack.recoveryScore.band.wireName,
      confidence: pack.confidence.wireName,
      priorityIds: const ['__starter__'],
      intensity: intensity.wireName,
      practiceIds: const ['prac_starter_calm'],
      engineVersion: engineVersion,
      catalogVersion: catalogVersion,
      extra: reason,
    );
    final planId = 'rplan_$contentHash';
    final today = _buildTodayAct(
      planId: planId,
      dayIndex: 0,
      priority: emptyPriority,
      steps: steps,
      intensity: intensity,
      because: because,
    );

    return RecoveryPlan(
      id: planId,
      contentHash: contentHash,
      source: RecoveryPlanSourceReference(
        profilePackId: pack.id,
        brainCheckSessionId: pack.source.sessionId,
        scoreModelVersion: pack.recoveryScore.modelVersion,
        profileSchemaVersion: pack.profileSchemaVersion,
      ),
      createdAt: (createdAt ?? DateTime.now()).toUtc(),
      status: RecoveryPlanStatus.active,
      generationStatus: RecoveryPlanStatus.starterFallback,
      priority: emptyPriority,
      confidence: pack.confidence,
      intensity: intensity,
      cadence: cadence,
      steps: steps,
      dayTemplate: RecoveryPlanDayTemplate(
        dayIndexSeed: 0,
        steps: steps,
        todayPreview: today,
      ),
      explanation: explanation,
      engineVersion: engineVersion,
      catalogVersion: catalogVersion,
      schemaVersion: RecoveryPlanVersions.schema,
      missingIndicators: [
        ...pack.missingDataIndicators,
        reason,
      ],
      isStarterFallback: true,
    );
  }

  static PlanBecause _selectBecause({
    required ProfilePack pack,
    required RecoveryPlanPriority priority,
    required bool starter,
  }) {
    if (starter) {
      return PlanBecauseTemplates.resolve(
        templateKey: PlanBecauseTemplates.starter,
      );
    }
    if (pack.source.mode == BrainCheckMode.pulse) {
      return PlanBecauseTemplates.resolve(
        templateKey: PlanBecauseTemplates.pulse,
      );
    }
    final primary = priority.priorities.isNotEmpty
        ? priority.priorities.first
        : null;
    final domainEn = primary?.titleEn ?? '';
    final domainAr = primary?.titleAr ?? '';
    if (pack.confidence == MeasurementConfidence.provisional) {
      return PlanBecauseTemplates.resolve(
        templateKey: PlanBecauseTemplates.priorityLowConf,
        domainEn: domainEn,
        domainAr: domainAr,
      );
    }
    if (priority.strongerDomainId != null) {
      return PlanBecauseTemplates.resolve(
        templateKey: PlanBecauseTemplates.withStrength,
        domainEn: domainEn,
        domainAr: domainAr,
        strengthEn: priority.strongerTitleEn ?? '',
        strengthAr: priority.strongerTitleAr ?? '',
      );
    }
    return PlanBecauseTemplates.resolve(
      templateKey: PlanBecauseTemplates.priority,
      domainEn: domainEn,
      domainAr: domainAr,
    );
  }

  static RecoveryPlanExplanation _buildExplanation({
    required ProfilePack pack,
    required RecoveryPlanPriority priority,
    required RecoveryPlanIntensity intensity,
    required PlanBecause because,
    required bool starter,
  }) {
    final focusEn = starter
        ? 'Calm starter'
        : (priority.priorities.isNotEmpty
            ? priority.priorities.first.titleEn
            : 'Gentle support');
    final focusAr = starter
        ? 'بداية هادئة'
        : (priority.priorities.isNotEmpty
            ? priority.priorities.first.titleAr
            : 'دعم لطيف');

    return RecoveryPlanExplanation(
      mainFocusEn: focusEn,
      mainFocusAr: focusAr,
      whyFitsEn: starter
          ? 'This is a starter plan while personalization is limited.'
          : 'This plan follows your current Brain Profile priorities with a gentle daily load.',
      whyFitsAr: starter
          ? 'هذه خطة بداية بينما يكون التخصيص محدوداً.'
          : 'تتبع هذه الخطة أولويات ملف الدماغ الحالي بحمل يومي لطيف.',
      whyMayChangeEn:
          'Your plan may change later after a new Brain Check or an approved review.',
      whyMayChangeAr:
          'قد تتغير خطتك لاحقاً بعد فحص دماغ جديد أو مراجعة معتمدة.',
      nonMedicalBoundaryEn:
          'This is a product support plan, not medical treatment or a cure.',
      nonMedicalBoundaryAr:
          'هذه خطة دعم للمنتج وليست علاجاً طبياً أو شفاءً.',
      todayBecause: because,
      intensityLineEn:
          'Daily path: ${intensity.labelEn} · about ${intensity.minPathMinutesMin}–${intensity.standardPathMinutesMax} minutes.',
      intensityLineAr:
          'المسار اليومي: ${intensity.labelAr} · حوالي ${intensity.minPathMinutesMin}–${intensity.standardPathMinutesMax} دقيقة.',
      confidenceLineEn: pack.confidence == MeasurementConfidence.provisional
          ? 'Confidence is still early — keep the load light.'
          : null,
      confidenceLineAr: pack.confidence == MeasurementConfidence.provisional
          ? 'الثقة ما زالت مبكرة — اجعل الحمل خفيفاً.'
          : null,
    );
  }

  static TodayAct _buildTodayAct({
    required String planId,
    required int dayIndex,
    required RecoveryPlanPriority priority,
    required List<RecoveryPlanStep> steps,
    required RecoveryPlanIntensity intensity,
    required PlanBecause because,
  }) {
    final requiredIds =
        steps.where((s) => !s.optional).map((s) => s.stepId).toList();
    final optionalIds =
        steps.where((s) => s.optional).map((s) => s.stepId).toList();
    final minimumIds =
        requiredIds.isEmpty ? const <String>[] : [requiredIds.first];
    final standardIds = [...requiredIds, ...optionalIds];
    final a11y = steps
        .map((s) => 'a11y_${s.practiceId}')
        .toList(growable: false);

    return TodayAct(
      id: TodayAct.buildId(planId, dayIndex),
      planId: planId,
      dayIndex: dayIndex,
      primaryDomainId: priority.primaryDomainId,
      supportDomainId: priority.strongerDomainId,
      requiredStepIds: requiredIds,
      optionalStepIds: optionalIds,
      minimumPathStepIds: minimumIds,
      standardPathStepIds: standardIds,
      estimatedMinutesMin: intensity.minPathMinutesMin,
      estimatedMinutesMax: intensity.standardPathMinutesMax.clamp(0, 20),
      because: because,
      accessibilityAltKeys: a11y,
      completionRule: RecoveryPracticeCatalog.completionRule,
      skipBehavior: RecoveryPracticeCatalog.skipBehavior,
      version: engineVersion,
    );
  }

  /// Stable content hash (hex prefix) for idempotent plan identity.
  static String computeContentHash({
    required String profilePackId,
    required int? scoreValue,
    required String scoreBand,
    required String confidence,
    required List<String> priorityIds,
    required String intensity,
    required List<String> practiceIds,
    required String engineVersion,
    required String catalogVersion,
    String? extra,
  }) {
    final payload = jsonEncode(<String, dynamic>{
      'profilePackId': profilePackId,
      'scoreValue': scoreValue,
      'scoreBand': scoreBand,
      'confidence': confidence,
      'priorityIds': priorityIds,
      'intensity': intensity,
      'practiceIds': practiceIds,
      'engineVersion': engineVersion,
      'catalogVersion': catalogVersion,
      if (extra != null) 'extra': extra,
    });
    final digest = sha256.convert(utf8.encode(payload));
    return digest.toString().substring(0, 24);
  }

}
