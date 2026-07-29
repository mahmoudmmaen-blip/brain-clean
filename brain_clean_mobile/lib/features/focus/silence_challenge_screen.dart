import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'ambient_sound_player.dart';
import 'application/silence_challenge_daily_program_gate.dart';
import '../../core/application/app_preferences_provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/l10n/app_localizations.dart';
import '../daily_program/application/daily_program_provider.dart';
import '../daily_program/domain/daily_step.dart';
import '../daily_program/domain/daily_step_status.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import '../gamification/data/xp_ledger_constants.dart';
import '../gamification/domain/xp_source.dart';
import '../pro/application/subscription_service_provider.dart';

const silenceCountdownKey = Key('silence_countdown');
const silenceLevelLabelKey = Key('silence_level_label');
const silenceDurationSelectorKey = Key('silence_duration_selector');
const silenceStartButtonKey = Key('silence_start_button');
const silenceSessionIconKey = Key('silence_session_icon');

/// Full-screen silence challenge — no touch or backgrounding until timer ends.
class SilenceChallengeScreen extends ConsumerStatefulWidget {
  const SilenceChallengeScreen({
    super.key,
    required this.streakDays,
  });

  final int streakDays;

  static const durationOptionsMinutes = <int>[5, 10, 15, 20, 30, 45, 60];
  static const freeDurationOptionsMinutes = <int>[5, 10, 15, 20];
  static const proOnlyDurationOptionsMinutes = <int>[30, 45, 60];
  static const defaultDurationMinutes = 10;

  static int computeLevel(int streakDays) =>
      ((streakDays / 7) + 1).ceil();

  /// Legacy level→minutes helper (kept for callers/tests). UI default is 10.
  static int targetMinutesForLevel(int level) =>
      10 + ((level - 1) * 2);

  @override
  ConsumerState<SilenceChallengeScreen> createState() =>
      _SilenceChallengeScreenState();
}

class _SilenceChallengeScreenState extends ConsumerState<SilenceChallengeScreen>
    with WidgetsBindingObserver {
  late final int _level;

  int _targetMinutes = SilenceChallengeScreen.defaultDurationMinutes;
  late int _totalSeconds;
  late int _remainingSeconds;

  StreamSubscription<int>? _ticker;
  bool _running = false;
  bool _failed = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _level = SilenceChallengeScreen.computeLevel(widget.streakDays);
    _totalSeconds = _targetMinutes * 60;
    _remainingSeconds = _totalSeconds;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Stillness session is silent by default — never autoplay ambient audio.
      ref.read(ambientSoundControllerProvider.notifier).stop();
    });
  }

  void _selectDuration(int minutes, {required bool isPro}) {
    if (_running || _failed || _completed) return;
    if (!SilenceChallengeScreen.durationOptionsMinutes.contains(minutes)) {
      return;
    }
    final isProOnly =
        SilenceChallengeScreen.proOnlyDurationOptionsMinutes.contains(minutes);
    if (isProOnly && !isPro) {
      context.push(AppRoutes.proPaywall);
      return;
    }
    setState(() {
      _targetMinutes = minutes;
      _totalSeconds = minutes * 60;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _beginChallenge() {
    if (_running || _failed || _completed) return;
    setState(() => _running = true);
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Stream.periodic(const Duration(seconds: 1), (t) => t + 1).listen(
      (_) {
        if (!mounted || _failed || _completed) return;
        if (_remainingSeconds <= 1) {
          _onSuccess();
          return;
        }
        setState(() => _remainingSeconds--);
      },
    );
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_running || _failed || _completed) return;
    if (state == AppLifecycleState.paused) {
      _onFail();
    }
  }

  void _onFail() {
    if (!_running || _failed || _completed) return;
    _failed = true;
    _stopTicker();
    _showFailDialog();
  }

  Future<void> _onSuccess() async {
    if (_failed || _completed) return;
    _completed = true;
    _stopTicker();
    setState(() => _remainingSeconds = 0);
    await _showSuccessDialog();
  }

  Future<void> _completeDailySukoonIfOpenedFromDailyProgram(
    bool fromDailyProgram,
  ) async {
    if (!fromDailyProgram) return;
    try {
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

  Future<void> _leaveAfterSession({required bool success}) async {
    final fromDailyProgram =
        ref.read(silenceChallengeDailyProgramGateProvider.notifier).consume();

    if (success) {
      ref.read(bcScoreProvider.notifier).applyBonus(
            20,
            xpSource: XpSource.focusSession,
            xpRefId:
                'silence_${XpLedgerConstants.utcDayKey(DateTime.now().toUtc())}',
          );
      await ref.read(appPreferencesProvider.notifier).incrementSilenceWin();
      await _completeDailySukoonIfOpenedFromDailyProgram(fromDailyProgram);
    }

    if (!mounted) return;
    if (fromDailyProgram) {
      context.go(AppRoutes.dailyProgram);
    } else {
      context.pop();
    }
  }

  Future<void> _showFailDialog() async {
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          loc.silenceChallengeFailedTitle,
          style: TextStyle(color: cs.onSurface),
        ),
        content: Text(
          loc.silenceChallengeFailedBody,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (ctx.mounted) Navigator.of(ctx).pop();
              await _leaveAfterSession(success: false);
            },
            child: Text(loc.commonOk),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          loc.silenceChallengeSuccessTitle,
          style: TextStyle(color: cs.onSurface),
        ),
        content: Text(
          loc.silenceChallengeSuccessBody,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (ctx.mounted) Navigator.of(ctx).pop();
              await _leaveAfterSession(success: true);
            },
            child: Text(loc.commonGreat),
          ),
        ],
      ),
    );
  }

  String get _countdownText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    if (_totalSeconds <= 0) return 0;
    return 1 - (_remainingSeconds / _totalSeconds);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTicker();
    super.dispose();
  }

  /// Clears the Daily Program sukoon gate after the current frame/build.
  void _disarmDailyProgramGateSafely() {
    final gate = ref.read(silenceChallengeDailyProgramGateProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gate.disarm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;
    final canEditDuration = !_running && !_failed && !_completed;
    final isPro = ref.watch(isProUserProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _disarmDailyProgramGateSafely();
        }
      },
      child: GestureDetector(
        onTap: _running ? _onFail : null,
        onPanStart: _running ? (_) => _onFail() : null,
        onLongPress: _running ? _onFail : null,
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      '🔕',
                      key: silenceSessionIconKey,
                      style: TextStyle(fontSize: 36),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.silenceChallengeTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.silenceChallengeSubtitle(_targetMinutes),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.silenceChallengeDurationLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    key: silenceDurationSelectorKey,
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final minutes
                          in SilenceChallengeScreen.durationOptionsMinutes)
                        ChoiceChip(
                          label: Text(
                            SilenceChallengeScreen
                                        .proOnlyDurationOptionsMinutes
                                        .contains(minutes) &&
                                    !isPro
                                ? '${loc.silenceChallengeDurationOption(minutes)} ★'
                                : loc.silenceChallengeDurationOption(minutes),
                          ),
                          selected: _targetMinutes == minutes,
                          onSelected: canEditDuration
                              ? (_) =>
                                  _selectDuration(minutes, isPro: isPro)
                              : null,
                          selectedColor: cs.primary.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: _targetMinutes == minutes
                                ? cs.primary
                                : cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: _targetMinutes == minutes
                                ? cs.primary
                                : dividerColor,
                          ),
                        ),
                    ],
                  ),
                  if (!isPro) ...[
                    const SizedBox(height: 8),
                    Text(
                      loc.silenceDurationProLocked,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(220, 220),
                          painter: _SilenceRingPainter(
                            progress: _progress,
                            trackColor: dividerColor,
                            progressColor: cs.primary,
                          ),
                        ),
                        Text(
                          _countdownText,
                          key: silenceCountdownKey,
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (canEditDuration) ...[
                    ElevatedButton(
                      key: silenceStartButtonKey,
                      onPressed: _beginChallenge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(loc.gameStart),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    loc.silenceChallengeLevel(_level, _targetMinutes),
                    key: silenceLevelLabelKey,
                    style: TextStyle(
                      fontSize: 16,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SilenceRingPainter extends CustomPainter {
  _SilenceRingPainter({
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
    final radius = size.width / 2 - 6;
    const stroke = 4.0;

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
  bool shouldRepaint(_SilenceRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
