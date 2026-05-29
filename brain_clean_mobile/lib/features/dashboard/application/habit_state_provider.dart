import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_state_provider.g.dart';

class HabitState {
  const HabitState({
    this.boredomBefriended = false,
    this.bodyActivated = false,
    this.delayedGratificationCount = 0,
  });

  final bool boredomBefriended;
  final bool bodyActivated;
  final int delayedGratificationCount;

  static const initial = HabitState();

  HabitState copyWith({
    bool? boredomBefriended,
    bool? bodyActivated,
    int? delayedGratificationCount,
  }) {
    return HabitState(
      boredomBefriended: boredomBefriended ?? this.boredomBefriended,
      bodyActivated: bodyActivated ?? this.bodyActivated,
      delayedGratificationCount:
          delayedGratificationCount ?? this.delayedGratificationCount,
    );
  }
}

@Riverpod(keepAlive: true)
class HabitStateController extends _$HabitStateController {
  @override
  HabitState build() => HabitState.initial;

  void resetAll() {
    state = HabitState.initial;
  }

  void setBoredomBefriended(bool value) {
    state = state.copyWith(boredomBefriended: value);
  }

  void setBodyActivated(bool value) {
    state = state.copyWith(bodyActivated: value);
  }

  void setDelayedGratificationCount(int value) {
    state = state.copyWith(delayedGratificationCount: value);
  }
}

/// Alias referenced by midnight reset service.
final habitStateProvider = habitStateControllerProvider;
