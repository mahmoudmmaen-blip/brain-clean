import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/bc_score_constants.dart';
import '../../diagnostic/domain/diagnostic_metrics_mapper.dart';
import '../../diagnostic/presentation/diagnostic_controller.dart';
import '../data/detox_protocol_repository.dart';
import '../data/detox_protocol_repository_provider.dart';
import '../domain/daily_check_in_input.dart';
import '../domain/detox_habit_scorer.dart';
import '../domain/detox_protocol_scoring.dart';
import '../domain/detox_protocol_state.dart';
import 'detox_ai_coach_insight_provider.dart';

part 'detox_protocol_controller.g.dart';

/// Orchestrates the 7-Day Dopamine Detox protocol for Brain Clean.
///
/// ## Core pipeline (blocking)
///
/// ```
/// User Input → DetoxHabitScorer → snake_case Firestore upsert → UI refresh
/// ```
///
/// ## Optional AI pipeline (non-blocking)
///
/// ```
/// After successful sync → unawaited DetoxAiCoachService → detoxAiCoachInsightProvider
/// ```
///
/// AI failures never affect habit state or Firestore sync.
@riverpod
class DetoxProtocolController extends _$DetoxProtocolController {
  @override
  Future<DetoxProtocolState> build() async {
    try {
      final remote = await ref.read(detoxProtocolRepositoryProvider).fetchLatest();
      return remote ?? const DetoxProtocolState();
    } on DetoxProtocolSyncException {
      return const DetoxProtocolState();
    }
  }

  DetoxProtocolRepository get _repository =>
      ref.read(detoxProtocolRepositoryProvider);

  DetoxProtocolState get _currentData =>
      state.value ?? const DetoxProtocolState();

  double get currentDetoxHabitScore => _currentData.detoxHabitScore;

  DetoxHabitSubScores get currentSubScores => _currentData.subScores;

  Future<void> loadFromRemote() async {
    state = const AsyncValue<DetoxProtocolState>.loading().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final remote = await _repository.fetchLatest();
      return remote ?? const DetoxProtocolState();
    });
  }

  /// Unified entry point for daily habit updates.
  ///
  /// Firestore sync is awaited; AI coaching (when [requestAiCoaching] is true)
  /// runs in the background and never blocks this method.
  Future<void> processDailyCheckIn(
    DailyCheckInInput checkIn, {
    bool requestAiCoaching = false,
    String locale = 'ar',
  }) async {
    final scored = DetoxProtocolState.fromDailyCheckIn(
      current: _currentData,
      checkIn: checkIn,
    );

    state = AsyncValue.data(scored);

    state = const AsyncValue<DetoxProtocolState>.loading().copyWithPrevious(
          AsyncValue.data(scored),
        );

    state = await AsyncValue.guard(() => _syncCheckInToRemote(scored));

    if (requestAiCoaching && state.hasValue) {
      _scheduleBackgroundAiCoaching(state.requireValue, locale: locale);
    }
  }

  /// Persists scored habits and reconciles with the remote source of truth.
  Future<DetoxProtocolState> _syncCheckInToRemote(
    DetoxProtocolState scored,
  ) async {
    await _repository.upsert(scored);
    final reconciled = await _repository.fetchLatest();
    return reconciled ?? scored.copyWith(lastSyncedAt: DateTime.now());
  }

  /// Fires AI insight retrieval without blocking the check-in return path.
  void _scheduleBackgroundAiCoaching(
    DetoxProtocolState detoxState, {
    required String locale,
  }) {
    final bcScore = _computeLiveBcScore(detoxState);
    unawaited(
      _fetchAiCoachingInsightSafely(
        detoxState,
        bcScore: bcScore,
        locale: locale,
      ),
    );
  }

  /// Mirrors [bcScoreLiveProvider] without creating a Riverpod circular dependency.
  double _computeLiveBcScore(DetoxProtocolState detox) {
    final metrics = ref.read(diagnosticControllerProvider);
    final base = DiagnosticMetricsMapper.fromMetrics(metrics);
    return DetoxHabitScorer.applyDetoxToModel(
      base,
      boredomBefriended: detox.boredomBefriended,
      delayedGratificationCount: detox.delayedGratificationCount,
      bodyActivated: detox.bodyActivated,
    ).bcScore;
  }

  /// Optional AI layer — errors are swallowed so habit tracking never crashes.
  Future<void> _fetchAiCoachingInsightSafely(
    DetoxProtocolState detoxState, {
    required double bcScore,
    required String locale,
  }) async {
    try {
      await ref.read(detoxAiCoachInsightProvider.notifier).fetchForCheckIn(
            detoxState: detoxState,
            bcScore: bcScore,
            locale: locale,
          );
    } catch (error, stackTrace) {
      assert(() {
        debugPrint('DetoxAiCoach: background insight failed — $error');
        debugPrint('$stackTrace');
        return true;
      }());
    }
  }

  Future<void> setBoredomBefriended(bool value) => processDailyCheckIn(
        DailyCheckInInput(boredomBefriended: value),
      );

  Future<void> setBodyActivated(bool value) => processDailyCheckIn(
        DailyCheckInInput(bodyActivated: value),
      );

  Future<void> recordDelayedGratificationWin() async {
    if (_currentData.delayedGratificationCount >=
        BcScoreConstants.maxDelayedGratificationCount) {
      return;
    }
    await processDailyCheckIn(
      DailyCheckInInput(
        delayedGratificationCount: _currentData.delayedGratificationCount + 1,
      ),
    );
  }

  Future<void> resetDailyCheckIns() => processDailyCheckIn(
        const DailyCheckInInput(
          boredomBefriended: false,
          bodyActivated: false,
        ),
      );
}

@riverpod
DetoxProtocolState detoxProtocolData(DetoxProtocolDataRef ref) {
  return ref.watch(detoxProtocolControllerProvider).value ??
      const DetoxProtocolState();
}
