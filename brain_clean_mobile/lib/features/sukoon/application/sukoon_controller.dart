import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../daily_program/application/daily_program_provider.dart';
import '../../daily_program/domain/daily_step.dart';
import '../../daily_program/domain/daily_step_status.dart';
import '../data/sukoon_repository_provider.dart';
import '../domain/sukoon_session.dart';
import 'sukoon_daily_program_gate.dart';

part 'sukoon_controller.g.dart';

class SukoonControllerState {
  const SukoonControllerState({
    this.selectedDuration = 3,
    this.remainingSeconds = 3 * 60,
    this.isRunning = false,
    this.isPaused = false,
    this.isComplete = false,
    this.wasInterrupted = false,
    this.showInterruptPrompt = false,
  });

  final int selectedDuration;
  final int remainingSeconds;
  final bool isRunning;
  final bool isPaused;
  final bool isComplete;
  final bool wasInterrupted;
  final bool showInterruptPrompt;

  double get progress {
    final total = selectedDuration * 60;
    if (total <= 0) return 0;
    return (remainingSeconds / total).clamp(0.0, 1.0);
  }

  SukoonControllerState copyWith({
    int? selectedDuration,
    int? remainingSeconds,
    bool? isRunning,
    bool? isPaused,
    bool? isComplete,
    bool? wasInterrupted,
    bool? showInterruptPrompt,
  }) {
    return SukoonControllerState(
      selectedDuration: selectedDuration ?? this.selectedDuration,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      isComplete: isComplete ?? this.isComplete,
      wasInterrupted: wasInterrupted ?? this.wasInterrupted,
      showInterruptPrompt: showInterruptPrompt ?? this.showInterruptPrompt,
    );
  }
}

@Riverpod(keepAlive: true)
class SukoonController extends _$SukoonController {
  static const allowedDurations = <int>[3, 5, 10, 15];
  static const _uuid = Uuid();

  Timer? _timer;

  @override
  SukoonControllerState build() {
    ref.onDispose(_cancelTimer);
    return const SukoonControllerState();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void selectDuration(int minutes) {
    if (state.isRunning || state.isPaused || state.isComplete) return;
    if (!allowedDurations.contains(minutes)) return;
    state = SukoonControllerState(
      selectedDuration: minutes,
      remainingSeconds: minutes * 60,
    );
  }

  void start() {
    if (state.isRunning || state.isComplete) return;
    final seconds = state.remainingSeconds > 0
        ? state.remainingSeconds
        : state.selectedDuration * 60;
    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      remainingSeconds: seconds,
      showInterruptPrompt: false,
    );
    _cancelTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void pause() {
    if (!state.isRunning) return;
    _cancelTimer();
    state = state.copyWith(isRunning: false, isPaused: true);
  }

  void resume() {
    if (!state.isPaused || state.isComplete) return;
    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      showInterruptPrompt: false,
    );
    _cancelTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void reset() {
    _cancelTimer();
    state = SukoonControllerState(
      selectedDuration: state.selectedDuration,
      remainingSeconds: state.selectedDuration * 60,
    );
  }

  void tick() {
    if (!state.isRunning || state.isComplete) return;
    if (state.remainingSeconds <= 1) {
      complete();
      return;
    }
    state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
  }

  void complete() {
    _cancelTimer();
    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      isComplete: true,
      remainingSeconds: 0,
      showInterruptPrompt: false,
    );
  }

  /// App left mid-session — pause gently and flag interruption.
  void markInterrupted() {
    if (!state.isRunning || state.isComplete) return;
    _cancelTimer();
    state = state.copyWith(
      isRunning: false,
      isPaused: true,
      wasInterrupted: true,
      showInterruptPrompt: true,
    );
  }

  void dismissInterruptPrompt() {
    state = state.copyWith(showInterruptPrompt: false);
  }

  Future<void> saveWithNote(String? note) async {
    final trimmed = note?.trim();
    final session = SukoonSession(
      id: _uuid.v4(),
      durationMinutes: state.selectedDuration,
      completedAt: DateTime.now(),
      wanderNote: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
      wasInterrupted: state.wasInterrupted,
    );

    try {
      await ref.read(sukoonRepositoryProvider).saveSession(session);
    } catch (_) {
      // Persistence is best-effort.
    }

    await _completeDailySukoonIfOpenedFromDailyProgram();
    reset();
  }

  Future<void> _completeDailySukoonIfOpenedFromDailyProgram() async {
    try {
      final fromDailyProgram =
          ref.read(sukoonDailyProgramGateProvider.notifier).consume();
      if (!fromDailyProgram) return;

      final program = ref.read(dailyProgramProvider).valueOrNull;
      final current = program?.currentStep;
      if (current == null || current.step != DailyStep.sukoon) return;
      if (current.status != DailyStepStatus.current) return;
      await ref
          .read(dailyProgramProvider.notifier)
          .completeStep(DailyStep.sukoon);
    } catch (_) {
      // Daily Program sync is best-effort.
    }
  }
}
