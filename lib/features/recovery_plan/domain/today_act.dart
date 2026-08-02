import 'plan_because.dart';
import 'recovery_plan_versions.dart';

/// Local completion placeholder — Today slice owns real state later.
class TodayActCompletionState {
  const TodayActCompletionState({
    this.completedStepIds = const [],
    this.skippedStepIds = const [],
    this.finished = false,
  });

  final List<String> completedStepIds;
  final List<String> skippedStepIds;
  final bool finished;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'completedStepIds': completedStepIds,
        'skippedStepIds': skippedStepIds,
        'finished': finished,
      };

  factory TodayActCompletionState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TodayActCompletionState();
    final completed = <String>[];
    final skipped = <String>[];
    final rawC = json['completedStepIds'];
    if (rawC is List) {
      for (final item in rawC) {
        completed.add(item.toString());
      }
    }
    final rawS = json['skippedStepIds'];
    if (rawS is List) {
      for (final item in rawS) {
        skipped.add(item.toString());
      }
    }
    return TodayActCompletionState(
      completedStepIds: List<String>.unmodifiable(completed),
      skippedStepIds: List<String>.unmodifiable(skipped),
      finished: json['finished'] as bool? ?? false,
    );
  }
}

/// TodayAct-ready daily instance (contract §12.2).
class TodayAct {
  const TodayAct({
    required this.id,
    required this.planId,
    required this.dayIndex,
    required this.primaryDomainId,
    required this.requiredStepIds,
    required this.optionalStepIds,
    required this.minimumPathStepIds,
    required this.standardPathStepIds,
    required this.estimatedMinutesMin,
    required this.estimatedMinutesMax,
    required this.because,
    required this.accessibilityAltKeys,
    required this.completionRule,
    required this.skipBehavior,
    required this.version,
    this.supportDomainId,
    this.localCompletion = const TodayActCompletionState(),
  });

  final String id;
  final String planId;
  final int dayIndex;
  final String? primaryDomainId;
  final String? supportDomainId;
  final List<String> requiredStepIds;
  final List<String> optionalStepIds;
  final List<String> minimumPathStepIds;
  final List<String> standardPathStepIds;
  final int estimatedMinutesMin;
  final int estimatedMinutesMax;
  final PlanBecause because;
  final List<String> accessibilityAltKeys;
  final String completionRule;
  final String skipBehavior;
  final String version;
  final TodayActCompletionState localCompletion;

  static String buildId(String planId, int dayIndex) =>
      'tact_${planId}_$dayIndex';

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'planId': planId,
        'dayIndex': dayIndex,
        if (primaryDomainId != null) 'primaryDomainId': primaryDomainId,
        if (supportDomainId != null) 'supportDomainId': supportDomainId,
        'requiredStepIds': requiredStepIds,
        'optionalStepIds': optionalStepIds,
        'minimumPathStepIds': minimumPathStepIds,
        'standardPathStepIds': standardPathStepIds,
        'estimatedMinutesMin': estimatedMinutesMin,
        'estimatedMinutesMax': estimatedMinutesMax,
        'because': because.toJson(),
        'accessibilityAltKeys': accessibilityAltKeys,
        'completionRule': completionRule,
        'skipBehavior': skipBehavior,
        'version': version,
        'localCompletion': localCompletion.toJson(),
      };

  factory TodayAct.fromJson(Map<String, dynamic> json) {
    List<String> asStrings(dynamic raw) {
      if (raw is! List) return const [];
      return raw.map((e) => e.toString()).toList(growable: false);
    }

    return TodayAct(
      id: json['id'] as String,
      planId: json['planId'] as String,
      dayIndex: (json['dayIndex'] as num?)?.toInt() ?? 0,
      primaryDomainId: json['primaryDomainId'] as String?,
      supportDomainId: json['supportDomainId'] as String?,
      requiredStepIds: asStrings(json['requiredStepIds']),
      optionalStepIds: asStrings(json['optionalStepIds']),
      minimumPathStepIds: asStrings(json['minimumPathStepIds']),
      standardPathStepIds: asStrings(json['standardPathStepIds']),
      estimatedMinutesMin: (json['estimatedMinutesMin'] as num?)?.toInt() ?? 0,
      estimatedMinutesMax: (json['estimatedMinutesMax'] as num?)?.toInt() ?? 0,
      because: PlanBecause.fromJson(
        Map<String, dynamic>.from(json['because'] as Map? ?? const {}),
      ),
      accessibilityAltKeys: asStrings(json['accessibilityAltKeys']),
      completionRule: json['completionRule'] as String? ?? 'user_mark_or_timer',
      skipBehavior: json['skipBehavior'] as String? ?? 'allowed_no_penalty',
      version: json['version'] as String? ?? RecoveryPlanVersions.engine,
      localCompletion: TodayActCompletionState.fromJson(
        json['localCompletion'] is Map
            ? Map<String, dynamic>.from(json['localCompletion'] as Map)
            : null,
      ),
    );
  }
}
