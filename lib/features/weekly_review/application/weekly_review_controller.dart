import 'package:flutter/foundation.dart';

import '../../daily_session/data/daily_session_repository.dart';
import '../../daily_session/domain/daily_day_key.dart';
import '../../daily_session/domain/daily_session.dart';
import '../../progress/data/progress_repository.dart';
import '../../progress/domain/progress_engine.dart';
import '../../progress/domain/progress_snapshot.dart';
import '../../recovery_plan/data/recovery_plan_repository.dart';
import '../data/weekly_review_repository.dart';
import '../domain/weekly_artifact.dart';
import '../domain/weekly_period.dart';
import '../domain/weekly_period_resolver.dart';
import '../domain/weekly_review_eligibility.dart';
import '../domain/weekly_review_enums.dart';
import '../domain/weekly_review_question.dart';
import '../domain/weekly_review_record.dart';
import '../domain/weekly_review_response.dart';
import '../domain/weekly_review_signal.dart';
import '../domain/weekly_review_signal_engine.dart';
import '../domain/weekly_review_source_reference.dart';
import '../domain/weekly_activity_facts.dart';
import '../domain/weekly_review_summary.dart';
import '../domain/weekly_review_summary_engine.dart';
import '../domain/weekly_review_version.dart';

enum WeeklyReviewUiPhase {
  loading,
  notEligible,
  draft,
  readyToComplete,
  completed,
  saveFailed,
  unsupported,
}

/// Orchestrates period → eligibility → draft → completion (no Plan/Score mutation).
class WeeklyReviewController extends ChangeNotifier {
  WeeklyReviewController({
    required DailySessionRepository sessions,
    required ProgressRepository progress,
    required WeeklyReviewRepository reviews,
    RecoveryPlanRepository? plans,
    SessionClock clock = systemSessionClock,
    Duration? timeZoneOffset,
  })  : _sessions = sessions,
        _progress = progress,
        _reviews = reviews,
        _plans = plans,
        _clock = clock,
        _timeZoneOffset = timeZoneOffset;

  final DailySessionRepository _sessions;
  final ProgressRepository _progress;
  final WeeklyReviewRepository _reviews;
  final RecoveryPlanRepository? _plans;
  final SessionClock _clock;
  final Duration? _timeZoneOffset;

  WeeklyReviewUiPhase phase = WeeklyReviewUiPhase.loading;
  WeeklyPeriod? period;
  WeeklyReviewEligibility? eligibility;
  WeeklyReviewRecord? record;
  WeeklyArtifact? artifact;
  WeeklyReviewSignal? signal;
  WeeklyReviewSummary? summary;
  WeeklyActivityFacts? activityFacts;
  String? errorKey;
  WeeklyReviewNotEligibleReason? notEligibleReason;
  String? validationError;

  Duration get _offset {
    if (_timeZoneOffset != null) return _timeZoneOffset!;
    return _clock().timeZoneOffset;
  }

  DateTime get _nowLocal {
    final now = _clock();
    if (_timeZoneOffset != null) {
      return now.toUtc().add(_timeZoneOffset!);
    }
    return now.toLocal();
  }

  DateTime get _nowUtc => _clock().toUtc();

  WeeklyReviewQuestion? get currentQuestion {
    final r = record;
    if (r == null || r.isCompleted) return null;
    final idx = r.questionIndex.clamp(
      0,
      WeeklyReviewQuestionCatalog.inOrder.length - 1,
    );
    return WeeklyReviewQuestionCatalog.inOrder[idx];
  }

  int get questionCount => WeeklyReviewQuestionCatalog.inOrder.length;

  bool get canComplete {
    final r = record;
    if (r == null || r.isCompleted) return false;
    return WeeklyReviewResponseValidator.requiredAnswersComplete(
      r.responsesById,
    );
  }

  Future<void> bootstrap() async {
    phase = WeeklyReviewUiPhase.loading;
    errorKey = null;
    validationError = null;
    notifyListeners();
    try {
      final target = WeeklyPeriodResolver.previousCompletedWeek(
        localNow: _nowLocal,
        timezoneOffset: _offset,
        materializedAtUtc: _nowUtc,
      );
      period = target;

      final existing = await _reviews.findByPeriod(target.periodId);
      if (existing != null && existing.isCompleted) {
        record = existing;
        summary = existing.summary;
        artifact = existing.artifactId != null
            ? await _reviews.artifactById(existing.artifactId!)
            : await _reviews.artifactByReviewId(existing.id);
        if (artifact != null) {
          signal = await _reviews.signalByArtifactId(artifact!.artifactId);
        }
        final history = await _sessions.history();
        final snapshot = await _progress.latest();
        _applyFacts(target, history, snapshot);
        phase = WeeklyReviewUiPhase.completed;
        notEligibleReason = WeeklyReviewNotEligibleReason.alreadyCompleted;
        notifyListeners();
        return;
      }

      final history = await _sessions.history();
      final plan = await _plans?.active();
      String? planId = plan?.id;
      String? profileId = plan?.source.profilePackId;
      String? scoreModel = plan?.source.scoreModelVersion;

      final snapshot = await _ensureProgressSnapshot(
        history: history,
        planId: planId,
        profileId: profileId,
        scoreModel: scoreModel,
      );

      final result = WeeklyReviewEligibilityEngine.evaluate(
        period: target,
        localNow: _nowLocal,
        timezoneOffset: _offset,
        history: history,
        progressSnapshot: snapshot,
        planId: planId,
        profilePackId: profileId,
        existingForPeriod: existing,
      );
      eligibility = result;
      _applyFacts(target, history, snapshot);

      if (result.alreadyCompleted && result.existingCompleted != null) {
        record = result.existingCompleted;
        summary = record?.summary;
        phase = WeeklyReviewUiPhase.completed;
        notifyListeners();
        return;
      }

      if (!result.isEligible) {
        notEligibleReason = result.reason;
        phase = result.reason == WeeklyReviewNotEligibleReason.unsupportedSchema
            ? WeeklyReviewUiPhase.unsupported
            : WeeklyReviewUiPhase.notEligible;
        notifyListeners();
        return;
      }

      final inPeriod = result.completedSessions;
      final resolvedPlanId = planId ?? inPeriod.first.source.planId;
      final resolvedProfileId = profileId ?? inPeriod.first.source.profilePackId;
      final resolvedScore = scoreModel ?? '';

      final source = WeeklyReviewSourceReference(
        progressSnapshotId: snapshot!.id,
        planId: resolvedPlanId,
        profilePackId: resolvedProfileId,
        recoveryScoreReference: resolvedScore,
      );

      if (existing != null && existing.isDraft) {
        record = existing;
      } else {
        record = await _reviews.saveDraft(
          WeeklyReviewRecord.draft(
            period: target,
            source: source,
            completedSessionIds: inPeriod.map((s) => s.id).toList(),
            nowUtc: _nowUtc,
          ),
        );
      }

      phase = canComplete
          ? WeeklyReviewUiPhase.readyToComplete
          : WeeklyReviewUiPhase.draft;
      notifyListeners();
    } catch (e) {
      debugPrint('WeeklyReviewController.bootstrap failed: $e');
      errorKey = 'persistence_failed';
      phase = WeeklyReviewUiPhase.saveFailed;
      notifyListeners();
    }
  }

  Future<ProgressSnapshot?> _ensureProgressSnapshot({
    required List<DailySession> history,
    required String? planId,
    required String? profileId,
    required String? scoreModel,
  }) async {
    final built = ProgressEngine.build(
      sessions: history,
      nowUtc: _nowUtc,
      asOfDayKey: DailyDayKey.fromLocal(_nowLocal),
      activePlanId: planId,
      profilePackId: profileId,
      recoveryScoreModelVersion: scoreModel,
    );
    try {
      return await _progress.saveIfNew(built);
    } catch (e) {
      debugPrint('WeeklyReview progress stamp failed: $e');
      return built;
    }
  }

  Future<bool> answerCurrent(WeeklyReviewResponse response) async {
    final r = record;
    if (r == null || r.isCompleted) return false;
    final validation = WeeklyReviewResponseValidator.validate(response);
    if (!validation.isValid) {
      validationError = validation.errorCode;
      notifyListeners();
      return false;
    }
    validationError = null;
    final byId = Map<String, WeeklyReviewResponse>.from(r.responsesById);
    byId[response.questionId] = response;
    final next = r.copyWith(
      responses: byId.values.toList(growable: false),
      updatedAt: _nowUtc,
    );
    try {
      record = await _reviews.saveDraft(next);
      phase = canComplete
          ? WeeklyReviewUiPhase.readyToComplete
          : WeeklyReviewUiPhase.draft;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('WeeklyReviewController.answerCurrent failed: $e');
      errorKey = 'persistence_failed';
      phase = WeeklyReviewUiPhase.saveFailed;
      notifyListeners();
      return false;
    }
  }

  Future<void> goToQuestion(int index) async {
    final r = record;
    if (r == null || r.isCompleted) return;
    final clamped = index.clamp(0, questionCount - 1);
    try {
      record = await _reviews.saveDraft(
        r.copyWith(questionIndex: clamped, updatedAt: _nowUtc),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('WeeklyReviewController.goToQuestion failed: $e');
      errorKey = 'persistence_failed';
      phase = WeeklyReviewUiPhase.saveFailed;
      notifyListeners();
    }
  }

  Future<void> goForward() async {
    final r = record;
    if (r == null) return;
    final q = currentQuestion;
    if (q != null && q.required && r.responsesById[q.id] == null) {
      validationError = 'required_missing';
      notifyListeners();
      return;
    }
    if (r.questionIndex >= questionCount - 1) {
      notifyListeners();
      return;
    }
    await goToQuestion(r.questionIndex + 1);
  }

  Future<void> goBack() async {
    final r = record;
    if (r == null || r.questionIndex <= 0) return;
    await goToQuestion(r.questionIndex - 1);
  }

  /// Exit: draft preserved; no summary/artifact/signal.
  void exitPreservingDraft() {
    // No-op mutate — persistence already holds draft.
    notifyListeners();
  }

  Future<bool> complete() async {
    final r = record;
    final p = period;
    if (r == null || p == null || r.isCompleted) {
      if (r?.isCompleted == true) {
        phase = WeeklyReviewUiPhase.completed;
        notifyListeners();
        return true;
      }
      return false;
    }
    if (!canComplete) {
      validationError = 'required_missing';
      notifyListeners();
      return false;
    }

    try {
      final history = await _sessions.history();
      final inPeriod =
          WeeklyReviewEligibilityEngine.sessionsInPeriod(history, p);
      final summaryBuilt = WeeklyReviewSummaryEngine.build(
        period: p,
        completedInPeriod: inPeriod,
        responses: r.responsesById,
        generatedAtUtc: _nowUtc,
      );
      if (summaryBuilt == null) {
        validationError = 'required_missing';
        notifyListeners();
        return false;
      }

      final artifactId = WeeklyArtifact.idFor(p.periodId);
      final hash = WeeklyArtifact.computeHash(
        artifactId: artifactId,
        weeklyReviewRecordId: r.id,
        periodId: p.periodId,
        sourceProgressSnapshotId: r.source.progressSnapshotId,
        sourcePlanId: r.source.planId,
        sourceProfilePackId: r.source.profilePackId,
        sourceRecoveryScoreReference: r.source.recoveryScoreReference,
        summary: summaryBuilt,
        completedSessionIds: inPeriod.map((s) => s.id).toList(),
      );
      final art = WeeklyArtifact(
        artifactId: artifactId,
        weeklyReviewRecordId: r.id,
        periodId: p.periodId,
        sourceProgressSnapshotId: r.source.progressSnapshotId,
        sourcePlanId: r.source.planId,
        sourceProfilePackId: r.source.profilePackId,
        sourceRecoveryScoreReference: r.source.recoveryScoreReference,
        summary: summaryBuilt,
        completedSessionIds: inPeriod.map((s) => s.id).toList(growable: false),
        createdAt: _nowUtc,
        artifactSchemaVersion: WeeklyReviewVersion.artifactSchema,
        reviewModelVersion: WeeklyReviewVersion.reviewModel,
        immutableHash: hash,
      );
      final sig = WeeklyReviewSignalEngine.build(
        periodId: p.periodId,
        artifactId: art.artifactId,
        summary: summaryBuilt,
        responses: r.responsesById,
        createdAtUtc: _nowUtc,
      );

      final result = await _reviews.complete(
        record: r,
        artifact: art,
        signal: sig,
      );
      record = result.record;
      artifact = result.artifact;
      signal = result.signal;
      summary = result.artifact.summary;
      _applyFacts(p, history, await _progress.latest());
      phase = WeeklyReviewUiPhase.completed;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('WeeklyReviewController.complete failed: $e');
      errorKey = 'persistence_failed';
      phase = WeeklyReviewUiPhase.saveFailed;
      notifyListeners();
      return false;
    }
  }

  void _applyFacts(
    WeeklyPeriod target,
    List<DailySession> history,
    ProgressSnapshot? snapshot,
  ) {
    try {
      activityFacts = WeeklyActivityFacts.fromHistory(
        period: target,
        history: history,
        snapshot: snapshot,
      );
    } catch (error, stackTrace) {
      debugPrint('WeeklyReviewController facts failed: $error');
      debugPrint('$stackTrace');
      activityFacts = WeeklyActivityFacts.empty(target);
    }
  }
}
