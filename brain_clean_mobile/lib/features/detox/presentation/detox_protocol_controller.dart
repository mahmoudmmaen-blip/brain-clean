import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/bc_score_constants.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../data/detox_protocol_repository.dart';
import '../data/detox_protocol_repository_provider.dart';
import '../domain/daily_check_in_input.dart';
import '../domain/detox_protocol_scoring.dart';
import '../domain/detox_protocol_state.dart';
import 'detox_ai_coach_insight_provider.dart';

part 'detox_protocol_controller.g.dart';

/// Orchestrates the 7-Day Dopamine Detox protocol for Brain Clean.
///
/// ## Data flow
///
/// ```
/// User Input (DailyCheckInInput)
///   → DetoxHabitScorer (via DetoxProtocolState.fromDailyCheckIn)
///   → Repository Transformation Layer (snake_case conversion)
///   → Firestore Write
///   → BC_score Update (bcScoreLiveProvider via detoxProtocolDataProvider)
/// ```
///
/// ## Transformation Layer
///
/// The controller never writes camelCase keys to Firestore. After local scoring,
/// [DetoxProtocolRepository.transformLocalMetricsToFirestorePayload] acts as
/// the final gatekeeper — converting Dart field names to `boredom_befriended`,
/// `delayed_gratification_count`, and `body_activated` before any remote upsert.
///
/// ## Remote data handling (prevents stale state)
///
/// - **Startup:** [build] hydrates from Firestore; remote snake_case values
///   override any stale local cache.
/// - **Write path:** [processDailyCheckIn] scores locally, upserts validated
///   snake_case payload, then re-fetches from server to reconcile.
/// - **Error path:** Failed upserts preserve optimistic local data via
///   [AsyncValue.copyWithPrevious] so check-in progress is never lost.
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
  // Daily check-in → DetoxHabitScorer → snake_case Firestore → BC_score
  // ---------------------------------------------------------------------------

  /// Unified entry point for daily habit updates.
  ///
  /// Scoring runs through [DetoxProtocolState.fromDailyCheckIn] (which calls
  /// [DetoxHabitScorer]) *before* any Firestore write. The remote payload is
  /// built exclusively with [DetoxFirestorePayload.fromScoredState].
  ///
  /// When [requestAiCoaching] is true, optionally invokes [DetoxAiCoachService]
  /// after a successful save (never blocks check-in on AI failure).
  Future<void> processDailyCheckIn(
    DailyCheckInInput checkIn, {
    bool requestAiCoaching = false,
    String locale = 'ar',
  }) async {
    // Flow: [Local Metrics] → [DetoxHabitScorer] → [Repository Transformation
    // (snake_case conversion)] → [Firestore Write] → [BC_score refresh].
    final scored = DetoxProtocolState.fromDailyCheckIn(
      current: _currentData,
      checkIn: checkIn,
    );

    // Precedence Handling: local state is optimistically updated so UI and
    // bcScoreLiveProvider refresh immediately; the subsequent Firestore upsert
    // + fetchLatest reconciles local state with the authoritative server
    // response, preventing stale data from lingering after sync completes.
    state = AsyncValue.data(scored);

    state = const AsyncValue<DetoxProtocolState>.loading().copyWithPrevious(
          AsyncValue.data(scored),
        );

    state = await AsyncValue.guard(() async {
      await _repository.upsert(scored);
      final reconciled = await _repository.fetchLatest();
      final finalState =
          reconciled ?? scored.copyWith(lastSyncedAt: DateTime.now());

      if (requestAiCoaching) {
        await _maybeFetchAiCoachingInsight(
          finalState,
          locale: locale,
        );
      }

      return finalState;
    });
  }

  /// Optional AI coaching — failures are swallowed so check-in sync is preserved.
  Future<void> _maybeFetchAiCoachingInsight(
    DetoxProtocolState detoxState, {
    required String locale,
  }) async {
    try {
      final bcScore = ref.read(bcScoreLiveProvider).bcScore;
      await ref.read(detoxAiCoachInsightProvider.notifier).fetchForCheckIn(
            detoxState: detoxState,
            bcScore: bcScore,
            locale: locale,
          );
    } catch (_) {
      // AI insight is optional; check-in data remains authoritative.
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
