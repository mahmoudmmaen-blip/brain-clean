import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../../../core/utils/date_format_utils.dart';
import '../application/structured_daily_program_provider.dart';

/// Full-screen countdown for reading / screen-free daily program activities.
class DailyProgramTimerScreen extends ConsumerStatefulWidget {
  const DailyProgramTimerScreen({
    super.key,
    required this.activityId,
    required this.minutes,
    required this.title,
    this.day,
  });

  final String activityId;
  final int minutes;
  final String title;
  final DateTime? day;

  @override
  ConsumerState<DailyProgramTimerScreen> createState() =>
      _DailyProgramTimerScreenState();
}

class _DailyProgramTimerScreenState
    extends ConsumerState<DailyProgramTimerScreen> {
  Timer? _timer;
  late int _remainingSeconds;
  var _running = false;
  var _done = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = (widget.minutes.clamp(1, 180)) * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DateTime get _day {
    final raw = widget.day ?? DateTime.now();
    return DateTime(raw.year, raw.month, raw.day);
  }

  void _start() {
    if (_done || _running) return;
    setState(() => _running = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _timer?.cancel();
        setState(() {
          _remainingSeconds = 0;
          _running = false;
          _done = true;
        });
        unawaited(_markComplete());
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _done = false;
      _remainingSeconds = (widget.minutes.clamp(1, 180)) * 60;
    });
  }

  Future<void> _markComplete() async {
    await ref.read(structuredDailyProgramControllerProvider).toggle(
          day: _day,
          activityId: widget.activityId,
          completed: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final palette = AppColors.of(context);
    final theme = Theme.of(context);
    final label = DateFormatUtils.countdown(_remainingSeconds);
    final isNsdr = widget.activityId.contains('nsdr');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          key: const Key('daily_program_timer_back'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.v2Home);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isNsdr) ...[
                Text(
                  loc.dailyProgramNsdrTimerDescription,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              const Spacer(),
              Text(
                label,
                textAlign: TextAlign.center,
                style: V2ShellVisual.heroMetricValue(theme)?.copyWith(
                  fontSize: 64,
                  color: palette.textPrimary,
                ),
              ),
              if (_done) ...[
                const SizedBox(height: 24),
                Text(
                  loc.dailyProgramTimerDoneMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
              const Spacer(),
              if (!_done) ...[
                SizedBox(
                  height: AppDesignConstants.minTouchTarget,
                  child: FilledButton(
                    key: const Key('daily_program_timer_primary'),
                    onPressed: _running ? _pause : _start,
                    style: V2ShellVisual.primaryFilled(),
                    child: Text(
                      _running
                          ? loc.homePomodoroPause
                          : loc.homePomodoroStart,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: AppDesignConstants.minTouchTarget,
                  child: OutlinedButton(
                    key: const Key('daily_program_timer_reset'),
                    onPressed: _reset,
                    style: V2ShellVisual.secondaryOutlined(),
                    child: Text(loc.pomodoroReset),
                  ),
                ),
              ] else
                SizedBox(
                  height: AppDesignConstants.minTouchTarget,
                  child: FilledButton(
                    key: const Key('daily_program_timer_done_back'),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.v2Home);
                      }
                    },
                    style: V2ShellVisual.primaryFilled(),
                    child: Text(loc.commonBack),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
