import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/hive_meta_keys.dart';
import '../../../core/data/app_meta_box_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/services/app_notification_service.dart';
import '../../daily_program/application/structured_daily_program_provider.dart';
import '../../daily_program/data/structured_daily_program_repository_provider.dart';
import '../../daily_session/data/home_dashboard_provider.dart';
import '../../daily_session/domain/daily_day_key.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../../gamification/data/xp_ledger_constants.dart';
import '../../gamification/domain/xp_source.dart';
import '../domain/pomodoro_logic.dart';

part 'pomodoro_provider.g.dart';

class PomodoroState {
  const PomodoroState({
    this.currentPhase = PomodoroPhase.focus,
    this.remainingSeconds = 0,
    this.completedRounds = 0,
    this.totalSessionsToday = 0,
    this.isRunning = false,
    this.focusMinutes = kPomodoroFocusMinutesShort,
  });

  final PomodoroPhase currentPhase;
  final int remainingSeconds;
  final int completedRounds;
  final int totalSessionsToday;
  final bool isRunning;
  final int focusMinutes;

  PomodoroState copyWith({
    PomodoroPhase? currentPhase,
    int? remainingSeconds,
    int? completedRounds,
    int? totalSessionsToday,
    bool? isRunning,
    int? focusMinutes,
  }) {
    return PomodoroState(
      currentPhase: currentPhase ?? this.currentPhase,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      completedRounds: completedRounds ?? this.completedRounds,
      totalSessionsToday: totalSessionsToday ?? this.totalSessionsToday,
      isRunning: isRunning ?? this.isRunning,
      focusMinutes: focusMinutes ?? this.focusMinutes,
    );
  }

  double get progress {
    final total = pomodoroPhaseDurationSeconds(
      currentPhase,
      focusMinutes: focusMinutes,
    );
    if (total <= 0) return 0;
    return (remainingSeconds / total).clamp(0.0, 1.0);
  }
}

@Riverpod(keepAlive: true)
class PomodoroController extends _$PomodoroController {
  Timer? _timer;

  @override
  PomodoroState build() {
    ref.onDispose(_cancelTimer);
    final sessions = _readSessionsToday();
    return PomodoroState(
      remainingSeconds: pomodoroPhaseDurationSeconds(PomodoroPhase.focus),
      totalSessionsToday: sessions,
      focusMinutes: kPomodoroFocusMinutesShort,
    );
  }

  /// Sets focus duration (5–120, step 5). Only applies when timer is idle.
  void setFocusMinutes(int minutes) {
    if (state.isRunning) return;
    final next = clampPomodoroFocusMinutes(minutes);
    if (state.currentPhase != PomodoroPhase.focus) {
      state = state.copyWith(focusMinutes: next);
      return;
    }
    state = state.copyWith(
      focusMinutes: next,
      remainingSeconds: pomodoroPhaseDurationSeconds(
        PomodoroPhase.focus,
        focusMinutes: next,
      ),
    );
  }

  /// Adjusts focus duration by [deltaMinutes] (typically ±5).
  void adjustFocusMinutes(int deltaMinutes) {
    setFocusMinutes(state.focusMinutes + deltaMinutes);
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  int _readSessionsToday() {
    try {
      final box = ref.read(appMetaBoxProvider);
      final storedDate = box.get(HiveMetaKeys.pomodoroSessionsDate) as String?;
      final today = _todayKey();
      if (storedDate != today) return 0;
      return box.get(HiveMetaKeys.pomodoroSessionsToday, defaultValue: 0) as int;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _persistSessionsToday(int count) async {
    try {
      final box = ref.read(appMetaBoxProvider);
      await box.put(HiveMetaKeys.pomodoroSessionsDate, _todayKey());
      await box.put(HiveMetaKeys.pomodoroSessionsToday, count);
    } catch (_) {}
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  void start() {
    if (state.isRunning) return;
    var remaining = state.remainingSeconds;
    if (remaining <= 0) {
      remaining = pomodoroPhaseDurationSeconds(
        state.currentPhase,
        focusMinutes: state.focusMinutes,
      );
    }
    state = state.copyWith(isRunning: true, remainingSeconds: remaining);
    _cancelTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    _cancelTimer();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _cancelTimer();
    state = PomodoroState(
      currentPhase: PomodoroPhase.focus,
      remainingSeconds: pomodoroPhaseDurationSeconds(
        PomodoroPhase.focus,
        focusMinutes: state.focusMinutes,
      ),
      completedRounds: 0,
      totalSessionsToday: state.totalSessionsToday,
      isRunning: false,
      focusMinutes: state.focusMinutes,
    );
  }

  void skip() {
    _cancelTimer();
    _onPhaseComplete();
  }

  void _tick() {
    if (state.remainingSeconds <= 1) {
      _cancelTimer();
      state = state.copyWith(remainingSeconds: 0, isRunning: false);
      _onPhaseComplete();
      return;
    }
    state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
  }

  /// Completes the current phase — used by timer, skip, and tests.
  void completeCurrentPhase() => _onPhaseComplete();

  void _onPhaseComplete() {
    final completed = state.currentPhase;
    final advance = advancePomodoro(
      completedPhase: completed,
      completedRounds: state.completedRounds,
    );

    var sessionsToday = state.totalSessionsToday;
    if (completed == PomodoroPhase.focus) {
      sessionsToday++;
      _persistSessionsToday(sessionsToday);
      final bonus = advance.focusBonus;
      if (bonus != null) {
        final day = XpLedgerConstants.utcDayKey(DateTime.now().toUtc());
        ref.read(bcScoreProvider.notifier).applyBonus(
              bonus,
              xpSource: XpSource.pomodoro,
              xpRefId: 'pomodoro_focus_${advance.completedRounds}_$day',
            );
      }
      _notifyPhaseComplete(wasFocus: true);
      // ignore: discarded_futures
      _markDailyProgramPomodoroComplete();
    } else if (completed == PomodoroPhase.longBreak) {
      final bonus = advance.longBreakBonus;
      if (bonus != null) {
        final day = XpLedgerConstants.utcDayKey(DateTime.now().toUtc());
        ref.read(bcScoreProvider.notifier).applyBonus(
              bonus,
              xpSource: XpSource.pomodoro,
              xpRefId: 'pomodoro_longbreak_$day',
            );
      }
    } else if (completed == PomodoroPhase.shortBreak) {
      _notifyPhaseComplete(wasFocus: false);
    }

    final nextSeconds = pomodoroPhaseDurationSeconds(
      advance.nextPhase,
      focusMinutes: state.focusMinutes,
    );
    state = PomodoroState(
      currentPhase: advance.nextPhase,
      remainingSeconds: nextSeconds,
      completedRounds: advance.completedRounds,
      totalSessionsToday: sessionsToday,
      isRunning: false,
      focusMinutes: state.focusMinutes,
    );
  }

  Future<void> _notifyPhaseComplete({required bool wasFocus}) async {
    if (!wasFocus) return;
    try {
      final isAr = ref.read(localeProvider).languageCode == 'ar';
      final service = ref.read(appNotificationServiceProvider);
      await service.showSimple(
        id: 8001,
        title: isAr ? 'انتهى وقت التركيز!' : 'Focus session done!',
        body: isAr
            ? 'خذ استراحة ☕'
            : 'Take a break ☕',
      );
    } catch (_) {}
  }

  Future<void> _markDailyProgramPomodoroComplete() async {
    try {
      final now = DateTime.now();
      final day = DateTime(now.year, now.month, now.day);
      final dayKey = DailyDayKey.fromLocal(day);
      final repo = ref.read(structuredDailyProgramRepositoryProvider);
      final completions = await repo.loadCompletions(dayKey);
      const candidates = <String>[
        'focus_pomodoro',
        'extra_pomodoro_1',
        'extra_pomodoro_2',
        'extra_pomodoro_3',
        'heavy_pomodoro_1',
        'heavy_pomodoro_2',
        'heavy_pomodoro_3',
        'heavy_pomodoro_4',
        'heavy_pomodoro_5',
        'h09_pomodoro_1',
        'h11_pomodoro_2',
        'h13_pomodoro_3',
        'h16_pomodoro_4',
      ];
      for (final id in candidates) {
        if (completions[id] == true) continue;
        await repo.setCompleted(
          dayKey: dayKey,
          activityId: id,
          completed: true,
        );
        break;
      }
      ref.invalidate(structuredDailyProgramForDayProvider(day));
      ref.invalidate(homeDashboardProvider);
    } catch (_) {}
  }
}
