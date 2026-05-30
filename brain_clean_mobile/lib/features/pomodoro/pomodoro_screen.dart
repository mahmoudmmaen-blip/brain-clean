import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/presentation/language_toggle_button.dart';
import '../../core/providers/locale_provider.dart';
import 'application/pomodoro_provider.dart';
import 'domain/pomodoro_logic.dart';
import 'widgets/pomodoro_timer_ring.dart';

const pomodoroScreenKey = Key('pomodoro_screen');

/// Pomodoro focus timer with BCS rewards per completed focus round.
class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  String _phaseLabel(PomodoroPhase phase, AppLocalizations loc, bool isAr) {
    switch (phase) {
      case PomodoroPhase.focus:
        return isAr ? 'وقت التركيز 🎯' : loc.pomodoroPhaseFocus;
      case PomodoroPhase.shortBreak:
        return isAr ? 'استراحة قصيرة ☕' : loc.pomodoroPhaseShortBreak;
      case PomodoroPhase.longBreak:
        return isAr ? 'استراحة طويلة 🌿' : loc.pomodoroPhaseLongBreak;
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final pomodoro = ref.watch(pomodoroControllerProvider);
    final notifier = ref.read(pomodoroControllerProvider.notifier);

    return Scaffold(
      key: pomodoroScreenKey,
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: Text(loc.pomodoroTitle),
        actions: const [LanguageToggleButton()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                _phaseLabel(pomodoro.currentPhase, loc, isAr),
                style: const TextStyle(
                  color: Color(0xFFE6EDF3),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              PomodoroTimerRing(
                progress: pomodoro.progress,
                ringColor: Color(pomodoroRingColor(pomodoro.currentPhase)),
                timeLabel: _formatTime(pomodoro.remainingSeconds),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final filled = index < pomodoro.completedRounds;
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? const Color(0xFF1D9E75)
                          : const Color(0xFF30363D),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: notifier.reset,
                    child: Text(
                      loc.pomodoroReset,
                      style: const TextStyle(color: Color(0xFF8B949E)),
                    ),
                  ),
                  FloatingActionButton.large(
                    backgroundColor: const Color(0xFF1D9E75),
                    onPressed: pomodoro.isRunning ? notifier.pause : notifier.start,
                    child: Icon(
                      pomodoro.isRunning ? Icons.pause : Icons.play_arrow,
                      size: 36,
                    ),
                  ),
                  TextButton(
                    onPressed: notifier.skip,
                    child: Text(
                      loc.pomodoroSkip,
                      style: const TextStyle(color: Color(0xFF8B949E)),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Text(
                  isAr
                      ? 'جلسات اليوم: ${pomodoro.totalSessionsToday}'
                      : loc.pomodoroSessionsToday(pomodoro.totalSessionsToday),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
