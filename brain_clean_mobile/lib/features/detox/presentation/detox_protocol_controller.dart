import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/bc_score_constants.dart';
import '../data/detox_protocol_repository.dart';
import '../data/detox_protocol_repository_provider.dart';
import '../domain/daily_check_in_input.dart';
import '../domain/detox_protocol_scoring.dart';
import '../domain/detox_protocol_state.dart';

part 'detox_protocol_controller.g.dart';

/// Orchestrates the 7-Day Dopamine Detox protocol for Brain Clean.
///
/// **Local check-ins → scoring → remote sync**
///
/// 1. Accepts daily habit toggles ([DailyCheckInInput]).
/// 2. Recalculates the habits component through [DetoxHabitScorer] before
///    committing local state.
/// 3. Persists to Supabase using Firestore-compatible **snake_case** keys
///    (`boredom_befriended`, `delayed_gratification_count`, `body_activated`)
///    via [DetoxProtocolRepository.upsert].
/// 4. Hydrates from remote on startup so Firestore data overrides stale cache.
/// 5. Downstream providers ([bcScoreLiveProvider], [detoxProtocolDataProvider])
///    recompute automatically via `ref.watch` whenever this controller's
///    [AsyncValue] transitions to new data.
///
/// Sync lifecycle is exposed as [AsyncValue] (`loading` / `error` / `data`).
@riverpod
class DetoxProtocolController extends _$DetoxProtocolController {
  static const _saveErrorMessage =
      'Could not save detox check-ins. Please try again.';
  static const _loadErrorMessage =
      'Could not load detox check-ins. Please try again.';

  @override
  AsyncValue<DetoxProtocolState> build() {
    Future.microtask(loadFromRemote);
    return const AsyncValue.data(DetoxProtocolState());
  }

  DetoxProtocolRepository get _repository =>
      ref.read(detoxProtocolRepositoryProvider);

  DetoxProtocolState get _currentData =>
      state.value ?? const DetoxProtocolState();

  // ---------------------------------------------------------------------------
  // Scoring — [detoxHabitScore] is precomputed on each check-in
  // ---------------------------------------------------------------------------

  /// Current weighted detox habit score (0–100) from today's check-ins.
  double get currentDetoxHabitScore => _currentData.detoxHabitScore;

  /// Sub-component breakdown (silence / delay / body).
  DetoxHabitSubScores get currentSubScores => _currentData.subScores;

  // ---------------------------------------------------------------------------
  // Remote sync (AsyncValue lifecycle)
  // ---------------------------------------------------------------------------

  /// Pulls the latest habit metrics from Supabase (snake_case keys).
  Future<void> loadFromRemote() async {
    state = const AsyncValue<DetoxProtocolState>.loading().copyWithPrevious(state);
    try {
      final remote = await _repository.fetchLatest();
      final next = remote ?? const DetoxProtocolState();
      state = AsyncValue.data(next);
    } on DetoxProtocolSyncException catch (e, st) {
      state = AsyncValue<DetoxProtocolState>.error(e.message, st)
          .copyWithPrevious(state);
    } catch (e, st) {
      state = AsyncValue<DetoxProtocolState>.error(_loadErrorMessage, st)
          .copyWithPrevious(state);
    }
  }

  // ---------------------------------------------------------------------------
  // Daily check-in → DetoxHabitScorer → local state → snake_case upsert
  // ---------------------------------------------------------------------------

  /// Unified entry point for daily habit updates.
  ///
  /// Merges [checkIn], recalculates [DetoxProtocolState.detoxHabitScore] via
  /// [DetoxHabitScorer], optimistically updates local state, then upserts
  /// snake_case fields to remote storage.
  Future<void> processDailyCheckIn(DailyCheckInInput checkIn) async {
    final scored = DetoxProtocolState.fromDailyCheckIn(
      current: _currentData,
      checkIn: checkIn,
    );

    state = AsyncValue.data(scored);

    state = const AsyncValue<DetoxProtocolState>.loading().copyWithPrevious(
          AsyncValue.data(scored),
        );

    try {
      await _repository.upsert(scored);
      final synced = scored.copyWith(lastSyncedAt: DateTime.now());
      state = AsyncValue.data(synced);
    } on DetoxProtocolSyncException catch (e, st) {
      state = AsyncValue<DetoxProtocolState>.error(e.message, st)
          .copyWithPrevious(AsyncValue.data(scored));
    } catch (e, st) {
      state = AsyncValue<DetoxProtocolState>.error(_saveErrorMessage, st)
          .copyWithPrevious(AsyncValue.data(scored));
    }
  }

  Future<void> setBoredomBefriended(bool value) => processDailyCheckIn(
        DailyCheckInInput(boredomBefriended: value),
      );

  Future<void> setBodyActivated(bool value) => processDailyCheckIn(
        DailyCheckInInput(bodyActivated: value),
      );

  /// Records one delayed-gratification win (capped at protocol maximum).
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

  /// Resets bool daily toggles; cumulative delay count is preserved.
  Future<void> resetDailyCheckIns() => processDailyCheckIn(
        const DailyCheckInInput(
          boredomBefriended: false,
          bodyActivated: false,
        ),
      );

}

/// Convenience accessor for habit data when sync [AsyncValue] is in error/loading.
@riverpod
DetoxProtocolState detoxProtocolData(DetoxProtocolDataRef ref) {
  return ref.watch(detoxProtocolControllerProvider).value ??
      const DetoxProtocolState();
}
