import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/hive_meta_keys.dart';
import '../../../core/data/app_meta_box_provider.dart';
import '../domain/adaptive_program_protocol.dart';

/// Persisted adaptive-engine state (difficulty + streak helpers + feeling).
class AdaptiveProgramState {
  const AdaptiveProgramState({
    this.difficultyOffset = 0,
    this.consecutiveCompleteDays = 0,
    this.consecutiveMissedDays = 0,
    this.lastCompletedDayKey,
    this.lastFeeling,
    this.weekOverride = 0,
  });

  final int difficultyOffset;
  final int consecutiveCompleteDays;
  final int consecutiveMissedDays;
  final String? lastCompletedDayKey;
  final AdaptiveSessionFeeling? lastFeeling;

  /// When > 0, forces protocol week (miss-day rewind).
  final int weekOverride;

  AdaptiveProgramState copyWith({
    int? difficultyOffset,
    int? consecutiveCompleteDays,
    int? consecutiveMissedDays,
    String? lastCompletedDayKey,
    AdaptiveSessionFeeling? lastFeeling,
    int? weekOverride,
    bool clearFeeling = false,
  }) {
    return AdaptiveProgramState(
      difficultyOffset: difficultyOffset ?? this.difficultyOffset,
      consecutiveCompleteDays:
          consecutiveCompleteDays ?? this.consecutiveCompleteDays,
      consecutiveMissedDays:
          consecutiveMissedDays ?? this.consecutiveMissedDays,
      lastCompletedDayKey: lastCompletedDayKey ?? this.lastCompletedDayKey,
      lastFeeling: clearFeeling ? null : (lastFeeling ?? this.lastFeeling),
      weekOverride: weekOverride ?? this.weekOverride,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'difficultyOffset': difficultyOffset,
        'consecutiveCompleteDays': consecutiveCompleteDays,
        'consecutiveMissedDays': consecutiveMissedDays,
        'lastCompletedDayKey': lastCompletedDayKey,
        'lastFeeling': lastFeeling?.name,
        'weekOverride': weekOverride,
      };

  factory AdaptiveProgramState.fromJson(Map<String, dynamic> json) {
    AdaptiveSessionFeeling? feeling;
    final feelingName = json['lastFeeling'] as String?;
    if (feelingName != null) {
      for (final value in AdaptiveSessionFeeling.values) {
        if (value.name == feelingName) {
          feeling = value;
          break;
        }
      }
    }
    return AdaptiveProgramState(
      difficultyOffset:
          (json['difficultyOffset'] as num?)?.round().clamp(-2, 2) ?? 0,
      consecutiveCompleteDays:
          (json['consecutiveCompleteDays'] as num?)?.round() ?? 0,
      consecutiveMissedDays:
          (json['consecutiveMissedDays'] as num?)?.round() ?? 0,
      lastCompletedDayKey: json['lastCompletedDayKey'] as String?,
      lastFeeling: feeling,
      weekOverride: (json['weekOverride'] as num?)?.round() ?? 0,
    );
  }
}

class AdaptiveProgramStateController
    extends StateNotifier<AdaptiveProgramState> {
  AdaptiveProgramStateController(this._box) : super(const AdaptiveProgramState()) {
    state = _load();
  }

  final Box<dynamic> _box;

  AdaptiveProgramState _load() {
    try {
      final raw = _box.get(HiveMetaKeys.adaptiveProgramStateJson);
      if (raw is! String || raw.isEmpty) return const AdaptiveProgramState();
      return AdaptiveProgramState.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('AdaptiveProgramState: load failed: $e');
      return const AdaptiveProgramState();
    }
  }

  Future<void> _persist(AdaptiveProgramState next) async {
    try {
      await _box.put(
        HiveMetaKeys.adaptiveProgramStateJson,
        jsonEncode(next.toJson()),
      );
      state = next;
    } catch (e) {
      debugPrint('AdaptiveProgramState: persist failed: $e');
      state = next;
    }
  }

  /// Record end-of-day feeling → adjusts tomorrow difficulty.
  Future<void> recordFeeling({
    required AdaptiveSessionFeeling feeling,
    required String dayKey,
  }) async {
    final delta = feelingDifficultyDelta(feeling);
    final nextOffset = (state.difficultyOffset + delta).clamp(-2, 2);
    await _persist(
      state.copyWith(
        difficultyOffset: nextOffset,
        lastFeeling: feeling,
        lastCompletedDayKey: dayKey,
        consecutiveCompleteDays: state.consecutiveCompleteDays + 1,
        consecutiveMissedDays: 0,
        weekOverride: 0,
      ),
    );
  }

  Future<void> noteMissedDay({required int currentProtocolWeek}) async {
    final missed = state.consecutiveMissedDays + 1;
    await _persist(
      state.copyWith(
        consecutiveMissedDays: missed,
        consecutiveCompleteDays: 0,
        weekOverride: missed >= 2 ? currentProtocolWeek : state.weekOverride,
        difficultyOffset: missed >= 2
            ? (state.difficultyOffset - 1).clamp(-2, 2)
            : state.difficultyOffset,
      ),
    );
  }
}

final adaptiveProgramStateProvider = StateNotifierProvider<
    AdaptiveProgramStateController, AdaptiveProgramState>((ref) {
  return AdaptiveProgramStateController(ref.watch(appMetaBoxProvider));
});
