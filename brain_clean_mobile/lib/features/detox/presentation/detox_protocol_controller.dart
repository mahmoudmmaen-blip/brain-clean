import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/bc_score_constants.dart';
import '../data/detox_protocol_repository.dart';
import '../data/detox_protocol_repository_provider.dart';
import '../domain/daily_check_in_input.dart';
import '../domain/detox_protocol_firestore.dart';
import '../domain/detox_protocol_scoring.dart';
import '../domain/detox_protocol_state.dart';

part 'detox_protocol_controller.g.dart';

/// Orchestrates the 7-Day Dopamine Detox protocol for Brain Clean.
///
/// ## Lifecycle
///
/// 1. **Receive** — UI submits partial daily metrics via [DailyCheckInInput].
/// 2. **Score** — [DetoxProtocolState.fromDailyCheckIn] merges inputs, clamps
///    values, and invokes [DetoxHabitScorer] to recalculate
///    [DetoxProtocolState.detoxHabitScore] *before* any state commit.
/// 3. **Commit local** — Optimistic [AsyncValue.data] so widgets and
///    [bcScoreLiveProvider] (via [detoxProtocolDataProvider]) refresh
///    immediately.
/// 4. **Sync remote** — Maps scored state to [DiagnosticModelJsonKeys]
///    snake_case fields (`boredom_befriended`, `delayed_gratification_count`,
///    `body_activated`) through [DetoxProtocolState.toFirestoreHabitPayload]
///    and performs an atomic upsert via [DetoxProtocolRepository.upsertSnakeCasePayload].
///
/// ## Local ↔ remote consistency
///
/// - **Startup:** [build] hydrates from Firestore; remote values override cache.
/// - **Write path:** Every check-in writes the same snake_case keys the
///   [DiagnosticModel] uses, keeping backend and BHI scoring aligned.
/// - **Error path:** Failed upserts preserve optimistic local data via
///   [AsyncValue.copyWithPrevious] so the user never loses check-in progress.
///
/// Implemented as an [AsyncNotifier] — UI observes `loading → data | error`.
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

  // ---------------------------------------------------------------------------
  // Scoring — [detoxHabitScore] is precomputed on each check-in
  // ---------------------------------------------------------------------------

  /// Current weighted detox habit score (0–100) from today's check-ins.
  double get currentDetoxHabitScore => _currentData.detoxHabitScore;

  /// Sub-component breakdown (silence / delay / body).
  DetoxHabitSubScores get currentSubScores => _currentData.subScores;

  // ---------------------------------------------------------------------------
  // Remote sync
  // ---------------------------------------------------------------------------

  /// Re-fetches habit metrics from Firestore (snake_case keys).
  Future<void> loadFromRemote() async {
    state = const AsyncValue<DetoxProtocolState>.loading().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final remote = await _repository.fetchLatest();
      return remote ?? const DetoxProtocolState();
    });
  }

  // ---------------------------------------------------------------------------
  // Daily check-in → DetoxHabitScorer → local state → snake_case upsert
  // ---------------------------------------------------------------------------

  /// Unified entry point for daily habit updates.
  ///
  /// 1. Merges [checkIn] and runs [DetoxHabitScorer] via [DetoxProtocolState.fromDailyCheckIn].
  /// 2. Commits optimistic local [AsyncValue.data] (triggers [bcScoreLiveProvider]).
  /// 3. Transitions to `loading` while upserting snake_case payload to Firestore.
  /// 4. Resolves to `data` with [DetoxProtocolState.lastSyncedAt] or `error`.
  Future<void> processDailyCheckIn(DailyCheckInInput checkIn) async {
    final scored = DetoxProtocolState.fromDailyCheckIn(
      current: _currentData,
      checkIn: checkIn,
    );

    // Immediate local commit — downstream providers refresh via ref.watch.
    state = AsyncValue.data(scored);

    final firestorePayload = scored.toFirestoreHabitPayload();

    state = const AsyncValue<DetoxProtocolState>.loading().copyWithPrevious(
          AsyncValue.data(scored),
        );

    state = await AsyncValue.guard(() async {
      await _repository.upsertSnakeCasePayload(firestorePayload);
      return scored.copyWith(lastSyncedAt: DateTime.now());
    });
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
