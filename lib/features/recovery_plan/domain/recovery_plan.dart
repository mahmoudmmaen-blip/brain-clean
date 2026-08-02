import '../../brain_profile/domain/measurement_confidence.dart';
import 'plan_because.dart';
import 'recovery_plan_cadence.dart';
import 'recovery_plan_day_template.dart';
import 'recovery_plan_explanation.dart';
import 'recovery_plan_intensity.dart';
import 'recovery_plan_priority.dart';
import 'recovery_plan_source_reference.dart';
import 'recovery_plan_status.dart';
import 'recovery_plan_step.dart';
import 'recovery_plan_versions.dart';

/// Immutable generated Recovery Plan (contract core object).
class RecoveryPlan {
  const RecoveryPlan({
    required this.id,
    required this.contentHash,
    required this.source,
    required this.createdAt,
    required this.status,
    required this.generationStatus,
    required this.priority,
    required this.confidence,
    required this.intensity,
    required this.cadence,
    required this.steps,
    required this.dayTemplate,
    required this.explanation,
    required this.engineVersion,
    required this.catalogVersion,
    required this.schemaVersion,
    this.missingIndicators = const [],
    this.isStarterFallback = false,
  });

  final String id;
  final String contentHash;
  final RecoveryPlanSourceReference source;
  final DateTime createdAt;

  /// active | historical (pointer role).
  final RecoveryPlanStatus status;

  /// ready | starter_fallback (generation outcome).
  final RecoveryPlanStatus generationStatus;

  final RecoveryPlanPriority priority;
  final MeasurementConfidence confidence;
  final RecoveryPlanIntensity intensity;
  final RecoveryPlanCadence cadence;
  final List<RecoveryPlanStep> steps;
  final RecoveryPlanDayTemplate dayTemplate;
  final RecoveryPlanExplanation explanation;
  final String engineVersion;
  final String catalogVersion;
  final String schemaVersion;
  final List<String> missingIndicators;
  final bool isStarterFallback;

  PlanBecause get todayBecause => explanation.todayBecause;

  List<RecoveryPlanStep> get requiredSteps =>
      steps.where((s) => !s.optional).toList(growable: false);

  List<RecoveryPlanStep> get optionalSteps =>
      steps.where((s) => s.optional).toList(growable: false);

  RecoveryPlan copyWithStatus(RecoveryPlanStatus status) {
    return RecoveryPlan(
      id: id,
      contentHash: contentHash,
      source: source,
      createdAt: createdAt,
      status: status,
      generationStatus: generationStatus,
      priority: priority,
      confidence: confidence,
      intensity: intensity,
      cadence: cadence,
      steps: steps,
      dayTemplate: dayTemplate,
      explanation: explanation,
      engineVersion: engineVersion,
      catalogVersion: catalogVersion,
      schemaVersion: schemaVersion,
      missingIndicators: missingIndicators,
      isStarterFallback: isStarterFallback,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'contentHash': contentHash,
        'source': source.toJson(),
        'createdAt': createdAt.toUtc().toIso8601String(),
        'status': status.wireName,
        'generationStatus': generationStatus.wireName,
        'priority': priority.toJson(),
        'confidence': confidence.wireName,
        'intensity': intensity.wireName,
        'cadence': cadence.toJson(),
        'steps': steps.map((s) => s.toJson()).toList(growable: false),
        'dayTemplate': dayTemplate.toJson(),
        'explanation': explanation.toJson(),
        'engineVersion': engineVersion,
        'catalogVersion': catalogVersion,
        'schemaVersion': schemaVersion,
        'missingIndicators': missingIndicators,
        'isStarterFallback': isStarterFallback,
      };

  factory RecoveryPlan.fromJson(Map<String, dynamic> json) {
    final steps = <RecoveryPlanStep>[];
    final rawSteps = json['steps'];
    if (rawSteps is List) {
      for (final item in rawSteps) {
        if (item is Map) {
          steps.add(
            RecoveryPlanStep.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    final missing = <String>[];
    final rawMissing = json['missingIndicators'];
    if (rawMissing is List) {
      for (final item in rawMissing) {
        missing.add(item.toString());
      }
    }
    return RecoveryPlan(
      id: json['id'] as String,
      contentHash: json['contentHash'] as String? ?? '',
      source: RecoveryPlanSourceReference.fromJson(
        Map<String, dynamic>.from(json['source'] as Map? ?? const {}),
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')
              ?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      status: RecoveryPlanStatusX.fromWire(json['status'] as String?),
      generationStatus:
          RecoveryPlanStatusX.fromWire(json['generationStatus'] as String?),
      priority: RecoveryPlanPriority.fromJson(
        Map<String, dynamic>.from(json['priority'] as Map? ?? const {}),
      ),
      confidence:
          MeasurementConfidenceX.fromWire(json['confidence'] as String?),
      intensity:
          RecoveryPlanIntensityX.fromWire(json['intensity'] as String?),
      cadence: RecoveryPlanCadence.fromJson(
        Map<String, dynamic>.from(json['cadence'] as Map? ?? const {}),
      ),
      steps: List<RecoveryPlanStep>.unmodifiable(steps),
      dayTemplate: RecoveryPlanDayTemplate.fromJson(
        Map<String, dynamic>.from(json['dayTemplate'] as Map? ?? const {}),
      ),
      explanation: RecoveryPlanExplanation.fromJson(
        Map<String, dynamic>.from(json['explanation'] as Map? ?? const {}),
      ),
      engineVersion:
          json['engineVersion'] as String? ?? RecoveryPlanVersions.engine,
      catalogVersion:
          json['catalogVersion'] as String? ?? RecoveryPlanVersions.catalog,
      schemaVersion:
          json['schemaVersion'] as String? ?? RecoveryPlanVersions.schema,
      missingIndicators: List<String>.unmodifiable(missing),
      isStarterFallback: json['isStarterFallback'] as bool? ?? false,
    );
  }
}

/// Persisted pack wrapper (schema recovery_plan_pack_v1).
class RecoveryPlanPack {
  const RecoveryPlanPack({
    required this.plan,
    required this.schemaVersion,
  });

  final RecoveryPlan plan;
  final String schemaVersion;

  String get id => plan.id;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'schemaVersion': schemaVersion,
        'plan': plan.toJson(),
      };

  factory RecoveryPlanPack.fromJson(Map<String, dynamic> json) {
    return RecoveryPlanPack(
      schemaVersion:
          json['schemaVersion'] as String? ?? RecoveryPlanVersions.schema,
      plan: RecoveryPlan.fromJson(
        Map<String, dynamic>.from(json['plan'] as Map? ?? json),
      ),
    );
  }
}
