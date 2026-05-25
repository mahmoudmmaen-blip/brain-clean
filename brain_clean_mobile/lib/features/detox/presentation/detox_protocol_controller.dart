import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/bc_score_constants.dart';
import '../data/detox_protocol_repository.dart';
import '../data/detox_protocol_repository_provider.dart';
import '../domain/detox_protocol_state.dart';

part 'detox_protocol_controller.g.dart';

/// Manages daily 7-Day Dopamine Detox check-ins and remote sync.
@riverpod
class DetoxProtocolController extends _$DetoxProtocolController {
  @override
  DetoxProtocolState build() => const DetoxProtocolState();

  DetoxProtocolRepository get _repository =>
      ref.read(detoxProtocolRepositoryProvider);

  /// Pulls the latest habit metrics from Supabase (Firestore-compatible keys).
  Future<void> loadFromRemote() async {
    try {
      state = state.copyWith(isSyncing: true, syncError: null);
      final remote = await _repository.fetchLatest();
      if (remote != null) {
        state = remote.copyWith(isSyncing: false, syncError: null);
      } else {
        state = state.copyWith(isSyncing: false);
      }
    } on DetoxProtocolSyncException catch (e) {
      state = state.copyWith(isSyncing: false, syncError: e.message);
    } catch (_) {
      state = state.copyWith(
        isSyncing: false,
        syncError: 'Could not load detox check-ins. Please try again.',
      );
    }
  }

  Future<void> setBoredomBefriended(bool value) async {
    state = state.copyWith(boredomBefriended: value, syncError: null);
    await _persist();
  }

  Future<void> setBodyActivated(bool value) async {
    state = state.copyWith(bodyActivated: value, syncError: null);
    await _persist();
  }

  /// Records one delayed-gratification win (capped at protocol maximum).
  Future<void> recordDelayedGratificationWin() async {
    if (state.delayedGratificationCount >=
        BcScoreConstants.maxDelayedGratificationCount) {
      return;
    }
    state = state.copyWith(
      delayedGratificationCount: state.delayedGratificationCount + 1,
      syncError: null,
    );
    await _persist();
  }

  Future<void> resetDailyCheckIns() async {
    state = state.copyWith(
      boredomBefriended: false,
      bodyActivated: false,
      syncError: null,
    );
    await _persist();
  }

  Future<void> _persist() async {
    try {
      state = state.copyWith(isSyncing: true, syncError: null);
      await _repository.upsert(state);
      state = state.copyWith(
        isSyncing: false,
        lastSyncedAt: DateTime.now(),
      );
    } on DetoxProtocolSyncException catch (e) {
      state = state.copyWith(isSyncing: false, syncError: e.message);
    } catch (_) {
      state = state.copyWith(
        isSyncing: false,
        syncError: 'Could not save detox check-ins. Please try again.',
      );
    }
  }
}
