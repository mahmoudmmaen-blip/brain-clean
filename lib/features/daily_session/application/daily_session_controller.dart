import 'package:flutter/foundation.dart';

import '../../recovery_plan/data/recovery_plan_repository.dart';
import '../../recovery_plan/domain/recovery_plan.dart';
import '../../recovery_plan/domain/recovery_plan_versions.dart';
import '../data/daily_session_repository.dart';
import '../domain/daily_day_key.dart';
import '../domain/daily_session.dart';
import '../domain/daily_session_path.dart';
import '../domain/daily_session_reflection.dart';
import '../domain/daily_session_status.dart';
import '../domain/daily_session_step_state.dart';
import '../domain/session_marked.dart';

/// Application service: load Today, start/resume session, complete steps.
class DailySessionController extends ChangeNotifier {
  DailySessionController({
    required DailySessionRepository sessions,
    required RecoveryPlanRepository plans,
    SessionClock clock = systemSessionClock,
    Duration? timeZoneOffset,
    Future<bool> Function()? profilePackExists,
  })  : _sessions = sessions,
        _plans = plans,
        _clock = clock,
        _timeZoneOffset = timeZoneOffset,
        _profilePackExists = profilePackExists;

  final DailySessionRepository _sessions;
  final RecoveryPlanRepository _plans;
  final SessionClock _clock;
  final Duration? _timeZoneOffset;
  final Future<bool> Function()? _profilePackExists;

  RecoveryPlan? _plan;
  DailySession? _session;
  String? _errorKey;
  var _loading = false;
  var _hasProfilePack = false;

  RecoveryPlan? get plan => _plan;
  DailySession? get session => _session;
  String? get errorKey => _errorKey;
  bool get loading => _loading;
  bool get hasProfilePack => _hasProfilePack;

  DateTime get _nowLocal {
    final now = _clock();
    if (_timeZoneOffset != null) {
      return now.toUtc().add(_timeZoneOffset!);
    }
    return now.toLocal();
  }

  DateTime get _nowUtc => _clock().toUtc();

  String get todayDayKey => DailyDayKey.fromLocal(_nowLocal);

  Future<void> loadToday() async {
    _loading = true;
    _errorKey = null;
    notifyListeners();
    try {
      final plan = await _plans.active();
      if (plan == null) {
        _plan = null;
        _session = null;
        _errorKey = 'missing_plan';
        _hasProfilePack = await _lookupProfilePack();
        _loading = false;
        notifyListeners();
        return;
      }
      if (plan.schemaVersion != RecoveryPlanVersions.schema) {
        _plan = plan;
        _session = null;
        _errorKey = 'unsupported_plan_version';
        _loading = false;
        notifyListeners();
        return;
      }
      final act = plan.dayTemplate.todayPreview;
      if (act.id.isEmpty) {
        _plan = plan;
        _session = null;
        _errorKey = 'missing_today_act';
        _loading = false;
        notifyListeners();
        return;
      }

      final dayKey = todayDayKey;
      var session = await _sessions.findByTodayActAndDay(
        todayActId: act.id,
        dayKey: dayKey,
      );
      session ??= await _sessions.active();
      if (session != null &&
          (session.dayKey != dayKey || session.todayActId != act.id)) {
        // New day / different act — do not mutate yesterday.
        session = null;
      }

      _plan = plan;
      _session = session;
      _errorKey = null;
      _hasProfilePack = true;
      _loading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('DailySessionController.loadToday failed: $e');
      _errorKey = 'persistence_failed';
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> _lookupProfilePack() async {
    final lookup = _profilePackExists;
    if (lookup == null) return false;
    try {
      return await lookup();
    } catch (e) {
      debugPrint('DailySessionController.profilePackExists failed: $e');
      return false;
    }
  }

  /// Idempotent: same day + TodayAct returns existing session.
  Future<DailySession?> ensureSession({DailySessionPath? path}) async {
    if (_plan == null) await loadToday();
    final plan = _plan;
    if (plan == null) return null;
    if (_errorKey == 'unsupported_plan_version' ||
        _errorKey == 'missing_today_act') {
      return null;
    }

    final act = plan.dayTemplate.todayPreview;
    final dayKey = todayDayKey;
    final existing = await _sessions.findByTodayActAndDay(
      todayActId: act.id,
      dayKey: dayKey,
    );
    if (existing != null) {
      _session = existing;
      notifyListeners();
      return existing;
    }

    try {
      final draft = DailySession.draftFor(
        plan: plan,
        nowLocal: _nowLocal,
        path: path,
        nowUtc: _nowUtc,
      );
      final saved = await _sessions.save(draft);
      _session = saved;
      _errorKey = null;
      notifyListeners();
      return saved;
    } catch (e) {
      debugPrint('DailySessionController.ensureSession failed: $e');
      _errorKey = 'persistence_failed';
      notifyListeners();
      return null;
    }
  }

  Future<void> selectPath(DailySessionPath path) async {
    final session = _session;
    final plan = _plan;
    if (session == null || plan == null) return;
    if (session.isImmutable) return;
    if (session.status == DailySessionStatus.inProgress ||
        session.status == DailySessionStatus.reflecting) {
      // Mid-session path switch requires restart (new draft same id rebuilt).
      return;
    }
    if (session.path == path) return;

    final act = plan.dayTemplate.todayPreview;
    final ids = DailySession.stepIdsForPath(act, path);
    final byId = {for (final s in plan.steps) s.stepId: s};
    final steps = <DailySessionStepState>[];
    for (var i = 0; i < ids.length; i++) {
      final id = ids[i];
      steps.add(
        DailySessionStepState(
          stepId: id,
          optional: byId[id]?.optional ?? false,
          phase: i == 0
              ? DailySessionStepPhase.active
              : DailySessionStepPhase.pending,
        ),
      );
    }
    final next = session.copyWith(
      path: path,
      orderedStepIds: ids,
      steps: steps,
      currentStepIndex: 0,
      status: DailySessionStatus.prepared,
      updatedAt: _nowUtc,
    );
    try {
      _session = await _sessions.save(next);
      notifyListeners();
    } catch (e) {
      _errorKey = 'persistence_failed';
      notifyListeners();
    }
  }

  /// Restart in-progress session onto a new path (after confirmation).
  Future<void> restartWithPath(DailySessionPath path) async {
    final session = _session;
    final plan = _plan;
    if (session == null || plan == null || session.isImmutable) return;
    final draft = DailySession.draftFor(
      plan: plan,
      nowLocal: _nowLocal,
      path: path,
      nowUtc: _nowUtc,
    );
    // Preserve identity for the day.
    final restarted = draft.copyWith(
      status: DailySessionStatus.prepared,
      updatedAt: _nowUtc,
    );
    // Force same id
    final forced = DailySession(
      id: session.id,
      dayKey: session.dayKey,
      source: restarted.source,
      status: DailySessionStatus.prepared,
      path: path,
      orderedStepIds: restarted.orderedStepIds,
      steps: restarted.steps,
      currentStepIndex: 0,
      startedAt: session.startedAt,
      updatedAt: _nowUtc,
      schemaVersion: session.schemaVersion,
    );
    try {
      // Bypass immutability via direct replace only when not completed.
      _session = await _sessions.save(forced);
      notifyListeners();
    } catch (e) {
      _errorKey = 'persistence_failed';
      notifyListeners();
    }
  }

  Future<void> startAct() async {
    final session = await ensureSession();
    if (session == null || session.isImmutable) return;
    if (session.status == DailySessionStatus.inProgress) return;
    final next = session.copyWith(
      status: DailySessionStatus.inProgress,
      updatedAt: _nowUtc,
    );
    try {
      _session = await _sessions.save(next);
      notifyListeners();
    } catch (e) {
      _errorKey = 'persistence_failed';
      notifyListeners();
    }
  }

  Future<void> completeCurrentStep() async {
    final session = _session;
    if (session == null || session.isImmutable) return;
    final idx = session.currentStepIndex;
    if (idx < 0 || idx >= session.steps.length) return;
    final steps = List<DailySessionStepState>.from(session.steps);
    steps[idx] = steps[idx].copyWith(
      phase: DailySessionStepPhase.completed,
      completedAt: _nowUtc,
      clearSkipped: true,
    );
    await _advance(session, steps, idx);
  }

  Future<void> skipCurrentOptionalStep() async {
    final session = _session;
    if (session == null || session.isImmutable) return;
    final idx = session.currentStepIndex;
    if (idx < 0 || idx >= session.steps.length) return;
    final current = session.steps[idx];
    if (!current.optional) return;
    final steps = List<DailySessionStepState>.from(session.steps);
    steps[idx] = current.copyWith(
      phase: DailySessionStepPhase.skipped,
      skippedAt: _nowUtc,
      clearCompleted: true,
    );
    await _advance(session, steps, idx);
  }

  Future<void> _advance(
    DailySession session,
    List<DailySessionStepState> steps,
    int idx,
  ) async {
    var nextIndex = idx;
    DailySessionStatus status = DailySessionStatus.inProgress;
    if (idx + 1 < steps.length) {
      nextIndex = idx + 1;
      steps[nextIndex] = steps[nextIndex].copyWith(
        phase: DailySessionStepPhase.active,
      );
    } else {
      status = DailySessionStatus.reflecting;
      nextIndex = idx;
    }
    final next = session.copyWith(
      steps: steps,
      currentStepIndex: nextIndex,
      status: status,
      updatedAt: _nowUtc,
    );
    try {
      _session = await _sessions.save(next);
      notifyListeners();
    } catch (e) {
      _errorKey = 'persistence_failed';
      notifyListeners();
    }
  }

  Future<void> goToPreviousStep() async {
    final session = _session;
    if (session == null || session.isImmutable) return;
    if (session.status != DailySessionStatus.inProgress) return;
    final idx = session.currentStepIndex;
    if (idx <= 0) return;
    final steps = List<DailySessionStepState>.from(session.steps);
    if (steps[idx].phase == DailySessionStepPhase.active) {
      steps[idx] = steps[idx].copyWith(phase: DailySessionStepPhase.pending);
    }
    final prev = idx - 1;
    steps[prev] = steps[prev].copyWith(
      phase: DailySessionStepPhase.active,
      clearCompleted: true,
      clearSkipped: true,
    );
    final next = session.copyWith(
      steps: steps,
      currentStepIndex: prev,
      updatedAt: _nowUtc,
    );
    try {
      _session = await _sessions.save(next);
      notifyListeners();
    } catch (e) {
      _errorKey = 'persistence_failed';
      notifyListeners();
    }
  }

  Future<void> endActEarly() async {
    final session = _session;
    if (session == null || session.isImmutable) return;
    final next = session.copyWith(
      status: DailySessionStatus.reflecting,
      updatedAt: _nowUtc,
    );
    try {
      _session = await _sessions.save(next);
      notifyListeners();
    } catch (e) {
      _errorKey = 'persistence_failed';
      notifyListeners();
    }
  }

  Future<SessionMarked?> completeWithReflection({
    DailySessionReflection? reflection,
    bool leaveAnyway = false,
  }) async {
    final session = _session;
    if (session == null) return null;
    if (session.mark != null &&
        session.status == DailySessionStatus.completed) {
      return session.mark;
    }

    final full = session.allRequiredComplete && !leaveAnyway;
    if (!full && !leaveAnyway && !session.pathStepsFinished) {
      // Require either required complete or explicit leave-anyway.
      if (!session.allRequiredComplete) {
        // Allow partial mark when reflecting after early end.
      }
    }

    final mark = SessionMarked(
      id: SessionMarked.buildId(session.id),
      dailySessionId: session.id,
      todayActId: session.todayActId,
      planId: session.planId,
      dayKey: session.dayKey,
      path: session.path,
      completedAt: _nowUtc,
      fullCompletion: session.allRequiredComplete,
      reflection: reflection,
      schemaVersion: session.schemaVersion,
    );

    try {
      final saved = await _sessions.saveCompletion(
        session: session.copyWith(reflectionDraft: reflection),
        mark: mark,
      );
      _session = saved;
      notifyListeners();
      return saved.mark;
    } catch (e) {
      debugPrint('DailySessionController.complete failed: $e');
      _errorKey = 'persistence_failed';
      notifyListeners();
      return null;
    }
  }
}
