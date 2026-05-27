import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/bc_score_constants.dart';
import '../../diagnostic/domain/diagnostic_metrics_mapper.dart';
import '../../diagnostic/presentation/diagnostic_controller.dart';
import '../data/detox_ai_coach_service_provider.dart';
import '../data/detox_protocol_repository.dart';
import '../data/detox_protocol_repository_provider.dart';
import '../domain/ai_coach/ai_coach_dynamic_context.dart';
import '../domain/ai_coach/ai_coach_pipeline_response.dart';
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

    // Optimistic update so UI reflects user intent immediately.
    state = AsyncValue.data(scored);

    // Await Firestore sync only — never block on AI/LLM latency.
    state = const AsyncLoading<DetoxProtocolState>().copyWithPrevious(
      AsyncValue.data(scored),
    );
    try {
      final reconciled = await _syncCheckInToRemote(scored);
      state = AsyncValue.data(reconciled);

      if (requestAiCoaching) {
        _startBackgroundAiCoaching(reconciled, locale: locale);
      }
    } catch (error, stackTrace) {
      state = AsyncValue<DetoxProtocolState>.error(
        error,
        stackTrace,
      ).copyWithPrevious(AsyncValue.data(scored));
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
  ///
  /// This is intentionally "fire-and-forget" — all errors are swallowed and
  /// never affect the habit tracking pipeline.
  void _startBackgroundAiCoaching(
    DetoxProtocolState detoxState, {
    required String locale,
  }) {
    final bcScore = _computeLiveBcScore(detoxState);
    final notifier = ref.read(detoxAiInsightsProvider.notifier);
    notifier.publishLoading();

    // Future(() async {}) ensures synchronous exceptions are isolated too.
    unawaited(
      Future<void>(() async {
        try {
          final service = ref.read(detoxAiCoachServiceProvider);
          final context = _buildAiContext(
            detoxState: detoxState,
            bcScore: bcScore,
            locale: locale,
          );
          final AiCoachPipelineResponse result = await service
              .fetchInsights(context)
              .timeout(const Duration(seconds: 12));
          notifier.publishInsight(result);
        } catch (error, stackTrace) {
          assert(() {
            debugPrint('DetoxAiCoach: background insight failed — $error');
            debugPrint('$stackTrace');
            return true;
          }());
          notifier.publishInsight(null);
        }
      }),
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

  AiCoachDynamicContext _buildAiContext({
    required DetoxProtocolState detoxState,
    required double bcScore,
    required String locale,
  }) {
    return AiCoachDynamicContext(
      userMessage: 'Daily detox check-in saved',
      locale: locale,
      bcScore: bcScore,
      variables: <String, Object?>{
        'boredomBefriended': detoxState.boredomBefriended,
        'delayedGratificationCount': detoxState.delayedGratificationCount,
        'bodyActivated': detoxState.bodyActivated,
        'detoxHabitScore': detoxState.detoxHabitScore,
      },
    );
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
