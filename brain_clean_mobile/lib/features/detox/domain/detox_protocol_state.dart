import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/constants/bc_score_constants.dart';
import 'daily_check_in_input.dart';
import 'detox_habit_scorer.dart';

part 'detox_protocol_state.freezed.dart';

/// Daily 7-Day Dopamine Detox check-in payload (local + last remote sync).
@freezed
class DetoxProtocolState with _$DetoxProtocolState {
  const factory DetoxProtocolState({
    @Default(false) bool boredomBefriended,
    @Default(0) int delayedGratificationCount,
    @Default(false) bool bodyActivated,

    /// Weighted detox habit score (0–100), recalculated via [DetoxHabitScorer]
    /// on every check-in before state is committed.
    @Default(0.0) double detoxHabitScore,
    DateTime? lastSyncedAt,
  }) = _DetoxProtocolState;

  /// Merges [checkIn] into [current], clamps metrics, and runs [DetoxHabitScorer].
  factory DetoxProtocolState.fromDailyCheckIn({
    required DetoxProtocolState current,
    DailyCheckInInput? checkIn,
  }) {
    final boredom = checkIn?.boredomBefriended ?? current.boredomBefriended;
    final delayed = (checkIn?.delayedGratificationCount ??
            current.delayedGratificationCount)
        .clamp(0, BcScoreConstants.maxDelayedGratificationCount);
    final body = checkIn?.bodyActivated ?? current.bodyActivated;

    final score = DetoxHabitScorer.detoxHabitScore(
      boredomBefriended: boredom,
      delayedGratificationCount: delayed,
      bodyActivated: body,
    );

    return DetoxProtocolState(
      boredomBefriended: boredom,
      delayedGratificationCount: delayed,
      bodyActivated: body,
      detoxHabitScore: score,
      lastSyncedAt: current.lastSyncedAt,
    );
  }
}
