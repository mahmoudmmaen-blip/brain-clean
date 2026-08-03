import '../../recovery_plan/domain/recovery_plan.dart';
import '../../recovery_plan/domain/recovery_plan_intensity.dart';
import '../../recovery_plan/domain/today_act.dart';
import 'daily_day_key.dart';
import 'daily_session_id.dart';
import 'daily_session_path.dart';
import 'daily_session_reflection.dart';
import 'daily_session_source_reference.dart';
import 'daily_session_status.dart';
import 'daily_session_step_state.dart';
import 'daily_session_version.dart';
import 'session_marked.dart';

/// In-progress / completed daily recovery session (local-first).
class DailySession {
  const DailySession({
    required this.id,
    required this.dayKey,
    required this.source,
    required this.status,
    required this.path,
    required this.orderedStepIds,
    required this.steps,
    required this.currentStepIndex,
    required this.startedAt,
    required this.updatedAt,
    required this.schemaVersion,
    this.completedAt,
    this.mark,
    this.reflectionDraft,
  });

  final String id;
  final String dayKey;
  final DailySessionSourceReference source;
  final DailySessionStatus status;
  final DailySessionPath path;
  final List<String> orderedStepIds;
  final List<DailySessionStepState> steps;
  final int currentStepIndex;
  final DateTime startedAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final SessionMarked? mark;
  final DailySessionReflection? reflectionDraft;
  final String schemaVersion;

  String get todayActId => source.todayActId;
  String get planId => source.planId;

  bool get isImmutable =>
      status == DailySessionStatus.completed ||
      (status == DailySessionStatus.partial && mark != null);

  DailySessionStepState? get currentStep {
    if (currentStepIndex < 0 || currentStepIndex >= steps.length) {
      return null;
    }
    return steps[currentStepIndex];
  }

  List<String> get completedStepIds => steps
      .where((s) => s.phase == DailySessionStepPhase.completed)
      .map((s) => s.stepId)
      .toList(growable: false);

  List<String> get skippedStepIds => steps
      .where((s) => s.phase == DailySessionStepPhase.skipped)
      .map((s) => s.stepId)
      .toList(growable: false);

  bool get allRequiredComplete {
    for (final s in steps) {
      if (!s.optional && s.phase != DailySessionStepPhase.completed) {
        return false;
      }
    }
    return steps.isNotEmpty;
  }

  bool get pathStepsFinished {
    for (final s in steps) {
      if (!s.isDone) return false;
    }
    return steps.isNotEmpty;
  }

  static DailySessionPath defaultPathFor(RecoveryPlan plan) {
    if (plan.intensity == RecoveryPlanIntensity.light) {
      return DailySessionPath.minimum;
    }
    return DailySessionPath.standard;
  }

  static List<String> stepIdsForPath(TodayAct act, DailySessionPath path) {
    return path == DailySessionPath.minimum
        ? List<String>.from(act.minimumPathStepIds)
        : List<String>.from(act.standardPathStepIds);
  }

  /// Creates or returns identity for today's session (not persisted).
  static DailySession draftFor({
    required RecoveryPlan plan,
    required DateTime nowLocal,
    DailySessionPath? path,
    DateTime? nowUtc,
  }) {
    final act = plan.dayTemplate.todayPreview;
    final dayKey = DailyDayKey.fromLocal(nowLocal);
    final selected = path ?? defaultPathFor(plan);
    final ids = stepIdsForPath(act, selected);
    final byId = {for (final s in plan.steps) s.stepId: s};
    final stepStates = <DailySessionStepState>[];
    for (var i = 0; i < ids.length; i++) {
      final id = ids[i];
      final step = byId[id];
      stepStates.add(
        DailySessionStepState(
          stepId: id,
          optional: step?.optional ?? false,
          phase: i == 0
              ? DailySessionStepPhase.active
              : DailySessionStepPhase.pending,
        ),
      );
    }
    final utc = (nowUtc ?? nowLocal.toUtc());
    return DailySession(
      id: DailySessionId.build(
        planId: plan.id,
        todayActId: act.id,
        dayKey: dayKey,
      ),
      dayKey: dayKey,
      source: DailySessionSourceReference(
        planId: plan.id,
        todayActId: act.id,
        profilePackId: plan.source.profilePackId,
        planEngineVersion: plan.engineVersion,
        practiceCatalogVersion: plan.catalogVersion,
        todayActVersion: act.version,
      ),
      status: DailySessionStatus.prepared,
      path: selected,
      orderedStepIds: ids,
      steps: stepStates,
      currentStepIndex: 0,
      startedAt: utc,
      updatedAt: utc,
      schemaVersion: DailySessionVersion.schema,
    );
  }

  DailySession copyWith({
    DailySessionStatus? status,
    DailySessionPath? path,
    List<String>? orderedStepIds,
    List<DailySessionStepState>? steps,
    int? currentStepIndex,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    SessionMarked? mark,
    bool clearMark = false,
    DailySessionReflection? reflectionDraft,
    bool clearReflectionDraft = false,
  }) {
    return DailySession(
      id: id,
      dayKey: dayKey,
      source: source,
      status: status ?? this.status,
      path: path ?? this.path,
      orderedStepIds: orderedStepIds ?? this.orderedStepIds,
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      startedAt: startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      mark: clearMark ? null : (mark ?? this.mark),
      reflectionDraft: clearReflectionDraft
          ? null
          : (reflectionDraft ?? this.reflectionDraft),
      schemaVersion: schemaVersion,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'dayKey': dayKey,
        'source': source.toJson(),
        'status': status.wireName,
        'path': path.wireName,
        'orderedStepIds': orderedStepIds,
        'steps': steps.map((s) => s.toJson()).toList(growable: false),
        'currentStepIndex': currentStepIndex,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        if (completedAt != null)
          'completedAt': completedAt!.toUtc().toIso8601String(),
        if (mark != null) 'mark': mark!.toJson(),
        if (reflectionDraft != null)
          'reflectionDraft': reflectionDraft!.toJson(),
        'schemaVersion': schemaVersion,
      };

  factory DailySession.fromJson(Map<String, dynamic> json) {
    final schema = json['schemaVersion'] as String?;
    if (schema != null && schema != DailySessionVersion.schema) {
      throw FormatException('unsupported_daily_session_schema:$schema');
    }
    final rawSteps = json['steps'];
    final steps = <DailySessionStepState>[];
    if (rawSteps is List) {
      for (final item in rawSteps) {
        if (item is Map) {
          steps.add(
            DailySessionStepState.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    final ordered = <String>[];
    final rawOrdered = json['orderedStepIds'];
    if (rawOrdered is List) {
      for (final item in rawOrdered) {
        ordered.add(item.toString());
      }
    }
    return DailySession(
      id: json['id'] as String? ?? '',
      dayKey: json['dayKey'] as String? ?? '',
      source: DailySessionSourceReference.fromJson(
        Map<String, dynamic>.from(json['source'] as Map? ?? const {}),
      ),
      status: DailySessionStatusX.fromWire(json['status'] as String?),
      path: DailySessionPathX.fromWire(json['path'] as String?),
      orderedStepIds: ordered,
      steps: steps,
      currentStepIndex: (json['currentStepIndex'] as num?)?.toInt() ?? 0,
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '')
              ?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '')
              ?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      completedAt:
          DateTime.tryParse(json['completedAt'] as String? ?? '')?.toUtc(),
      mark: json['mark'] is Map
          ? SessionMarked.fromJson(
              Map<String, dynamic>.from(json['mark'] as Map),
            )
          : null,
      reflectionDraft: json['reflectionDraft'] is Map
          ? DailySessionReflection.fromJson(
              Map<String, dynamic>.from(json['reflectionDraft'] as Map),
            )
          : null,
      schemaVersion: schema ?? DailySessionVersion.schema,
    );
  }
}
