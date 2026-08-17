import 'package:flutter/foundation.dart';

import '../../daily_session/data/daily_session_repository.dart';
import '../../daily_session/domain/daily_day_key.dart';
import '../../recovery_plan/data/recovery_plan_repository.dart';
import '../data/progress_repository.dart';
import '../domain/progress_engine.dart';
import '../domain/progress_snapshot.dart';

/// Loads DailySession history, builds ProgressSnapshot, persists append-only.
class ProgressController extends ChangeNotifier {
  ProgressController({
    required DailySessionRepository sessions,
    required ProgressRepository progress,
    RecoveryPlanRepository? plans,
    SessionClock clock = systemSessionClock,
    Duration? timeZoneOffset,
  })  : _sessions = sessions,
        _progress = progress,
        _plans = plans,
        _clock = clock,
        _timeZoneOffset = timeZoneOffset;

  final DailySessionRepository _sessions;
  final ProgressRepository _progress;
  final RecoveryPlanRepository? _plans;
  final SessionClock _clock;
  final Duration? _timeZoneOffset;

  ProgressSnapshot? _snapshot;
  String? _errorKey;
  var _loading = false;

  ProgressSnapshot? get snapshot => _snapshot;
  String? get errorKey => _errorKey;
  bool get loading => _loading;
  bool get isEmpty => _snapshot == null || _snapshot!.isEmpty;

  DateTime get _nowLocal {
    final now = _clock();
    if (_timeZoneOffset != null) {
      return now.toUtc().add(_timeZoneOffset!);
    }
    return now.toLocal();
  }

  DateTime get _nowUtc => _clock().toUtc();

  Future<void> refresh({bool persist = true}) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();
    try {
      final history = await _sessions.history();
      String? planId;
      String? profileId;
      String? scoreModel;
      final plan = await _plans?.active();
      if (plan != null) {
        planId = plan.id;
        profileId = plan.source.profilePackId;
        scoreModel = plan.source.scoreModelVersion;
      }

      final built = ProgressEngine.build(
        sessions: history,
        nowUtc: _nowUtc,
        asOfDayKey: DailyDayKey.fromLocal(_nowLocal),
        activePlanId: planId,
        profilePackId: profileId,
        recoveryScoreModelVersion: scoreModel,
      );

      if (persist) {
        _snapshot = await _progress.saveIfNew(built);
      } else {
        _snapshot = built;
      }
      _errorKey = null;
      _loading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('ProgressController.refresh failed: $e');
      _errorKey = 'persistence_failed';
      _loading = false;
      notifyListeners();
    }
  }

  /// Loads last persisted snapshot without regenerating (restart-safe).
  Future<void> hydrateLatest() async {
    _loading = true;
    _errorKey = null;
    notifyListeners();
    try {
      _snapshot = await _progress.latest();
      _errorKey = null;
      _loading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('ProgressController.hydrateLatest failed: $e');
      _errorKey = 'persistence_failed';
      _loading = false;
      notifyListeners();
    }
  }
}
