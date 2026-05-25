import 'package:freezed_annotation/freezed_annotation.dart';

part 'detox_protocol_state.freezed.dart';

/// Daily 7-Day Dopamine Detox check-in state (local + synced remote).
@freezed
class DetoxProtocolState with _$DetoxProtocolState {
  const factory DetoxProtocolState({
    @Default(false) bool boredomBefriended,
    @Default(0) int delayedGratificationCount,
    @Default(false) bool bodyActivated,
    @Default(false) bool isSyncing,
    String? syncError,
    DateTime? lastSyncedAt,
  }) = _DetoxProtocolState;
}
