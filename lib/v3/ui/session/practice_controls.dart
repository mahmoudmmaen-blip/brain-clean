import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../features/focus/ambient_sound_player.dart';
import '../../content/exercises_content.dart';

class PracticeModeControl extends ConsumerStatefulWidget {
  const PracticeModeControl({
    super.key,
    required this.exercise,
    required this.onComplete,
  });

  final ExerciseContent exercise;
  final VoidCallback onComplete;

  @override
  ConsumerState<PracticeModeControl> createState() =>
      _PracticeModeControlState();
}

class _PracticeModeControlState extends ConsumerState<PracticeModeControl>
    with SingleTickerProviderStateMixin {
  final _checked = <int>{};
  Timer? _timer;
  int _remaining = 0;
  bool _running = false;
  late AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    final ex = widget.exercise;
    if (ex.mode == ExerciseMode.guided) {
      _remaining = ex.guidedSeconds ?? 60;
    } else if (ex.mode == ExerciseMode.timer ||
        ex.mode == ExerciseMode.focusTimer) {
      _remaining = (ex.timerMinutes ?? 10) * 60;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breath.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (_running) return;
    setState(() => _running = true);
    if (widget.exercise.mode == ExerciseMode.guided) {
      _breath.repeat(reverse: true);
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _timer?.cancel();
        _breath.stop();
        setState(() {
          _remaining = 0;
          _running = false;
        });
        widget.onComplete();
        return;
      }
      setState(() => _remaining--);
    });
  }

  void _pause() {
    _timer?.cancel();
    _breath.stop();
    setState(() => _running = false);
  }

  String get _clock {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final ex = widget.exercise;

    switch (ex.mode) {
      case ExerciseMode.steps:
        final steps = ex.steps.resolve(locale);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < steps.length; i++)
              CheckboxListTile(
                value: _checked.contains(i),
                onChanged: (v) => setState(() {
                  if (v == true) {
                    _checked.add(i);
                  } else {
                    _checked.remove(i);
                  }
                }),
                title: Text('${i + 1}. ${steps[i]}'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: widget.onComplete,
              style: FilledButton.styleFrom(
                backgroundColor: AppDesignConstants.brandGreen,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(loc.v3PracticeDone),
            ),
          ],
        );
      case ExerciseMode.guided:
        return Column(
          children: [
            AnimatedBuilder(
              animation: _breath,
              builder: (context, _) {
                final scale = 0.7 + (_breath.value * 0.4);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppDesignConstants.brandGreen
                          .withValues(alpha: 0.25),
                      border: Border.all(
                        color: AppDesignConstants.brandGreen,
                        width: 3,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              _clock,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppDesignConstants.darkOnSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (!_running)
              FilledButton(
                onPressed: _startCountdown,
                style: FilledButton.styleFrom(
                  backgroundColor: AppDesignConstants.brandGreen,
                ),
                child: Text(loc.v3PracticeStart),
              )
            else
              TextButton(onPressed: _pause, child: Text(loc.v3PracticePause)),
          ],
        );
      case ExerciseMode.timer:
      case ExerciseMode.focusTimer:
        final ambient = ref.watch(ambientSoundControllerProvider);
        final isAr = locale == 'ar';
        return Column(
          children: [
            Text(
              _clock,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: AppDesignConstants.darkOnSurface,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: AmbientSound.values.map((s) {
                final active = ambient.active == s;
                return ChoiceChip(
                  label: Text('${s.emoji} ${s.localizedLabel(isAr)}'),
                  selected: active,
                  onSelected: (_) {
                    final ctrl =
                        ref.read(ambientSoundControllerProvider.notifier);
                    if (active) {
                      ctrl.stop();
                    } else {
                      ctrl.play(s);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_running)
                  FilledButton(
                    onPressed: _startCountdown,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppDesignConstants.brandGreen,
                    ),
                    child: Text(loc.v3PracticeStart),
                  )
                else ...[
                  OutlinedButton(
                    onPressed: _pause,
                    child: Text(loc.v3PracticePause),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      _timer?.cancel();
                      setState(() {
                        _running = false;
                        _remaining = (ex.timerMinutes ?? 10) * 60;
                      });
                    },
                    child: Text(loc.v3PracticeStop),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.onComplete,
              child: Text(loc.v3PracticeDone),
            ),
          ],
        );
    }
  }
}

/// Simple sine-based breathing hint for tests (no animation dependency).
double breathScale(double t) => 0.7 + 0.3 * (0.5 + 0.5 * math.sin(t * math.pi));
