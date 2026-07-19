import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/glass_card.dart';
import '../application/sukoon_controller.dart';
import '../application/sukoon_daily_program_gate.dart';

const sukoonScreenKey = Key('sukoon_screen');
const sukoonStartButtonKey = Key('sukoon_start_button');
const sukoonCountdownKey = Key('sukoon_countdown');

/// Wakeful rest session — calm, minimal, evidence-based stillness.
class SukoonScreen extends ConsumerStatefulWidget {
  const SukoonScreen({super.key});

  @override
  ConsumerState<SukoonScreen> createState() => _SukoonScreenState();
}

class _SukoonScreenState extends ConsumerState<SukoonScreen>
    with WidgetsBindingObserver {
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ref.read(sukoonControllerProvider.notifier).markInterrupted();
    }
  }

  void _disarmDailyProgramGateSafely() {
    final gate = ref.read(sukoonDailyProgramGateProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gate.disarm();
    });
  }

  Future<void> _finish(String? note) async {
    final fromDailyProgram = ref.read(sukoonDailyProgramGateProvider);
    await ref.read(sukoonControllerProvider.notifier).saveWithNote(note);
    if (!mounted) return;
    if (fromDailyProgram) {
      context.go(AppRoutes.dailyProgram);
    } else {
      context.pop();
    }
  }

  String _formatCountdown(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _durationChipLabel(AppLocalizations loc, int minutes) {
    return switch (minutes) {
      3 => loc.sukoonDuration3,
      5 => loc.sukoonDuration5,
      10 => loc.sukoonDuration10,
      15 => loc.sukoonDuration15,
      _ => loc.sukoonDurationOption(minutes),
    };
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(sukoonControllerProvider);
    final notifier = ref.read(sukoonControllerProvider.notifier);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _disarmDailyProgramGateSafely();
          notifier.reset();
        }
      },
      child: Scaffold(
        key: sukoonScreenKey,
        backgroundColor: colorScheme.surface,
        appBar: state.isRunning || state.isPaused || state.isComplete
            ? null
            : AppBar(
                title: Text(loc.sukoonTitle),
                backgroundColor: colorScheme.surface,
              ),
        body: SafeArea(
          child: state.isComplete
              ? _CompleteView(
                  loc: loc,
                  minutes: state.selectedDuration,
                  noteController: _noteController,
                  onSave: () => _finish(_noteController.text),
                  onSkip: () => _finish(null),
                )
              : state.isRunning || state.isPaused
                  ? _RunningView(
                      loc: loc,
                      state: state,
                      countdown: _formatCountdown(state.remainingSeconds),
                      onPause: notifier.pause,
                      onResume: notifier.resume,
                      onReset: notifier.reset,
                      onContinueAfterInterrupt: () {
                        notifier.dismissInterruptPrompt();
                        notifier.resume();
                      },
                      onRestartAfterInterrupt: () {
                        notifier.dismissInterruptPrompt();
                        notifier.reset();
                        notifier.start();
                      },
                    )
                  : _SetupView(
                      loc: loc,
                      selectedDuration: state.selectedDuration,
                      durationLabelBuilder: _durationChipLabel,
                      onSelectDuration: notifier.selectDuration,
                      onStart: notifier.start,
                    ),
        ),
      ),
    );
  }
}

class _SetupView extends StatelessWidget {
  const _SetupView({
    required this.loc,
    required this.selectedDuration,
    required this.durationLabelBuilder,
    required this.onSelectDuration,
    required this.onStart,
  });

  final AppLocalizations loc;
  final int selectedDuration;
  final String Function(AppLocalizations loc, int minutes) durationLabelBuilder;
  final ValueChanged<int> onSelectDuration;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Text(
            loc.sukoonIntro,
            style: TextStyle(
              color: colorScheme.onSurface,
              height: 1.55,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          loc.sukoonDurationLabel,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final minutes in SukoonController.allowedDurations)
              ChoiceChip(
                label: Text(durationLabelBuilder(loc, minutes)),
                selected: selectedDuration == minutes,
                onSelected: (_) => onSelectDuration(minutes),
                selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: selectedDuration == minutes
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: selectedDuration == minutes
                      ? colorScheme.primary
                      : colorScheme.outline,
                ),
              ),
          ],
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          key: sukoonStartButtonKey,
          onPressed: onStart,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(
            loc.sukoonStart,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class _RunningView extends StatelessWidget {
  const _RunningView({
    required this.loc,
    required this.state,
    required this.countdown,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onContinueAfterInterrupt,
    required this.onRestartAfterInterrupt,
  });

  final AppLocalizations loc;
  final SukoonControllerState state;
  final String countdown;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final VoidCallback onContinueAfterInterrupt;
  final VoidCallback onRestartAfterInterrupt;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (state.showInterruptPrompt) ...[
            GlassCard(
              child: Column(
                children: [
                  Text(
                    loc.sukoonInterruptedMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onRestartAfterInterrupt,
                          child: Text(loc.sukoonRestart),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onContinueAfterInterrupt,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                          child: Text(loc.sukoonContinue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          const Spacer(),
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(240, 240),
                  painter: _SukoonRingPainter(
                    progress: state.progress,
                    trackColor: colorScheme.surfaceContainerHighest,
                    progressColor: colorScheme.primary,
                  ),
                ),
                Text(
                  countdown,
                  key: sukoonCountdownKey,
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _BreathingDot(color: colorScheme.primary),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: state.isPaused ? loc.sukoonContinue : loc.sukoonPause,
                onPressed: state.isPaused ? onResume : onPause,
                icon: Icon(
                  state.isPaused ? Icons.play_arrow : Icons.pause,
                  color: colorScheme.onSurface,
                  size: 32,
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                tooltip: loc.sukoonReset,
                onPressed: onReset,
                icon: Icon(
                  Icons.refresh,
                  color: colorScheme.onSurfaceVariant,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _BreathingDot extends StatefulWidget {
  const _BreathingDot({required this.color});

  final Color color;

  @override
  State<_BreathingDot> createState() => _BreathingDotState();
}

class _BreathingDotState extends State<_BreathingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.15, end: 0.45).animate(_controller),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CompleteView extends StatelessWidget {
  const _CompleteView({
    required this.loc,
    required this.minutes,
    required this.noteController,
    required this.onSave,
    required this.onSkip,
  });

  final AppLocalizations loc;
  final int minutes;
  final TextEditingController noteController;
  final VoidCallback onSave;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 24),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.sukoonCompleteTitle(minutes),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                loc.sukoonWanderHint,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 3,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: loc.sukoonWanderHint,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(loc.sukoonSave),
              ),
              TextButton(
                onPressed: onSkip,
                child: Text(
                  loc.sukoonSkip,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SukoonRingPainter extends CustomPainter {
  _SukoonRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const stroke = 6.0;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2,
      2 * 3.1415926535 * progress.clamp(0, 1),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_SukoonRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
