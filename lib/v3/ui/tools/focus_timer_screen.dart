import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../features/focus/ambient_sound_player.dart';
import '../../../features/pro/application/subscription_service_provider.dart';
import '../../application/v3_state_providers.dart';
import '../../data/focus_log.dart';
import '../../routing/v3_routes.dart';

class V3FocusTimerScreen extends ConsumerStatefulWidget {
  const V3FocusTimerScreen({super.key});

  @override
  ConsumerState<V3FocusTimerScreen> createState() => _V3FocusTimerScreenState();
}

class _V3FocusTimerScreenState extends ConsumerState<V3FocusTimerScreen> {
  int _minutes = 10;
  int _remaining = 10 * 60;
  bool _running = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _selectMinutes(int minutes, {required bool isPro}) async {
    if (minutes == 50 && !isPro) {
      if (mounted) {
        context.push('${V3Routes.paywall}?source=tool');
      }
      return;
    }
    _timer?.cancel();
    await WakelockPlus.disable();
    setState(() {
      _minutes = minutes;
      _remaining = minutes * 60;
      _running = false;
    });
  }

  Future<void> _start() async {
    if (_running) return;
    await WakelockPlus.enable();
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_remaining <= 1) {
        _timer?.cancel();
        await _complete(completed: true);
        return;
      }
      setState(() => _remaining--);
    });
  }

  Future<void> _pause() async {
    _timer?.cancel();
    await WakelockPlus.disable();
    setState(() => _running = false);
  }

  Future<void> _stop() async {
    _timer?.cancel();
    await WakelockPlus.disable();
    final elapsed = (_minutes * 60) - _remaining;
    if (elapsed >= 60) {
      await _log(minutes: elapsed ~/ 60, completed: false);
    }
    setState(() {
      _running = false;
      _remaining = _minutes * 60;
    });
  }

  Future<void> _complete({required bool completed}) async {
    await WakelockPlus.disable();
    ref.read(ambientSoundControllerProvider.notifier).stop();
    await _log(minutes: _minutes, completed: completed);
    if (!mounted) return;
    setState(() {
      _running = false;
      _remaining = _minutes * 60;
    });
    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.v3ToolsFocusComplete)),
    );
  }

  Future<void> _log({required int minutes, required bool completed}) async {
    await ref.read(v3StateRepositoryProvider).appendFocusLog(
          FocusLog(
            at: DateTime.now(),
            minutes: minutes,
            completed: completed,
          ),
        );
    ref.invalidate(v3AppStateProvider);
  }

  String get _clock {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final isPro = ref.watch(isProUserProvider);
    final ambient = ref.watch(ambientSoundControllerProvider);

    return Scaffold(
      key: const Key('v3_focus_timer'),
      backgroundColor: AppDesignConstants.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(loc.v3ToolsFocusTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
          child: Column(
            children: [
              Text(
                loc.v3ToolsFocusHint,
                style: const TextStyle(
                  color: AppDesignConstants.darkOnSurfaceMuted,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (final m in [10, 25, 50])
                    ChoiceChip(
                      key: Key('v3_focus_preset_$m'),
                      label: Text(
                        m == 50 && !isPro
                            ? '${loc.v3ToolsFocusMin(m)} · ${loc.v3ToolsProBadge}'
                            : loc.v3ToolsFocusMin(m),
                      ),
                      selected: _minutes == m,
                      onSelected: (_) => _selectMinutes(m, isPro: isPro),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                _clock,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
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
              const Spacer(),
              if (!_running)
                FilledButton(
                  key: const Key('v3_focus_start'),
                  onPressed: _start,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppDesignConstants.brandGreen,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(loc.v3PracticeStart),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pause,
                        child: Text(loc.v3PracticePause),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: _stop,
                        child: Text(loc.v3PracticeStop),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
