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
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;

    return Scaffold(
      key: pomodoroScreenKey,
      appBar: AppBar(
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
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              PomodoroTimerRing(
                progress: pomodoro.progress,
                ringColor: pomodoro.currentPhase == PomodoroPhase.focus
                    ? colorScheme.primary
                    : colorScheme.secondary,
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
                      color: filled ? colorScheme.primary : dividerColor,
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
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                  FloatingActionButton.large(
                    backgroundColor: colorScheme.primary,
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
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dividerColor),
                ),
                child: Text(
                  isAr
                      ? 'جلسات اليوم: ${pomodoro.totalSessionsToday}'
                      : loc.pomodoroSessionsToday(pomodoro.totalSessionsToday),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface,
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
