import 'package:flutter/foundation.dart';

import '../../brain_profile/data/brain_profile_repository.dart';
import '../../daily_session/data/daily_session_repository.dart';
import '../../daily_session/domain/daily_day_key.dart';
import '../../recovery_plan/data/recovery_plan_repository.dart';
import '../../weekly_review/data/weekly_review_repository.dart';
import '../data/progress_repository.dart';
import '../domain/progress_engine.dart';
import '../domain/progress_experience_builder.dart';
import '../domain/progress_experience_enums.dart';
import '../domain/progress_view_model.dart';

enum ProgressExperiencePhase {
  loading,
  ready,
  empty,
  snapshotMissing,
  unsupported,
  persistenceFailed,
}

/// Loads ProgressSnapshot + Weekly Review status for PRG-01 (read-only assemble).
class ProgressExperienceController extends ChangeNotifier {
  ProgressExperienceController({
    required DailySessionRepository sessions,
    required ProgressRepository progress,
    required WeeklyReviewRepository reviews,
    RecoveryPlanRepository? plans,
    BrainProfileRepository? profiles,
    SessionClock clock = systemSessionClock,
    Duration? timeZoneOffset,
  })  : _sessions = sessions,
        _progress = progress,
        _reviews = reviews,
        _plans = plans,
        _profiles = profiles,
        _clock = clock,
        _timeZoneOffset = timeZoneOffset;

  final DailySessionRepository _sessions;
  final ProgressRepository _progress;
  final WeeklyReviewRepository _reviews;
  final RecoveryPlanRepository? _plans;
  final BrainProfileRepository? _profiles;
  final SessionClock _clock;
  final Duration? _timeZoneOffset;

  ProgressExperiencePhase phase = ProgressExperiencePhase.loading;
  ProgressViewModel viewModel = ProgressViewModel.empty();
  String? errorKey;

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

  Future<void> load() async {
    phase = ProgressExperiencePhase.loading;
    errorKey = null;
    notifyListeners();
    try {
      final history = await _sessions.history();
      final plan = await _plans?.active();
      final profile = await _profiles?.latest();

      final built = ProgressEngine.build(
        sessions: history,
        nowUtc: _nowUtc,
        asOfDayKey: DailyDayKey.fromLocal(_nowLocal),
        activePlanId: plan?.id,
        profilePackId: plan?.source.profilePackId ?? profile?.id,
        recoveryScoreModelVersion: plan?.source.scoreModelVersion ??
            profile?.recoveryScore.modelVersion,
      );
      final snapshot = await _progress.saveIfNew(built);

      final period = ProgressExperienceBuilder.resolveTargetPeriod(
        localNow: _nowLocal,
        timezoneOffset: _offset,
      );
      final review = await _reviews.findByPeriod(period.periodId);
      var artifactSummary = review?.summary;
      if (artifactSummary == null &&
          review != null &&
          review.artifactId != null) {
        final art = await _reviews.artifactById(review.artifactId!);
        artifactSummary = art?.summary;
      }

      viewModel = ProgressExperienceBuilder.build(
        snapshot: snapshot,
        sessionHistory: history,
        profilePack: profile,
        previousPeriod: period,
        localNow: _nowLocal,
        timezoneOffset: _offset,
        reviewForPeriod: review,
        artifactSummary: artifactSummary,
        schemasSupported: true,
      );

      phase = viewModel.hasHistory
          ? ProgressExperiencePhase.ready
          : ProgressExperiencePhase.empty;
      notifyListeners();
    } catch (e) {
      debugPrint('ProgressExperienceController.load failed: $e');
      errorKey = 'persistence_failed';
      phase = ProgressExperiencePhase.persistenceFailed;
      notifyListeners();
    }
  }
}
