import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import '../gamification/domain/xp_source.dart';
import 'application/games_scores_provider.dart';
import 'domain/digit_span_session.dart';
import 'domain/game_scoring.dart';
import 'widgets/numeric_keypad.dart';

/// Digit span — timed digit reveal then calculator keypad recall.
class NumberMemoryGameScreen extends ConsumerStatefulWidget {
  const NumberMemoryGameScreen({super.key});

  @override
  ConsumerState<NumberMemoryGameScreen> createState() =>
      _NumberMemoryGameScreenState();
}

class _NumberMemoryGameScreenState extends ConsumerState<NumberMemoryGameScreen> {
  static const _digitShowMs = 850;
  static const _digitGapMs = 300;
  static const _feedbackMs = 900;

  late DigitSpanSession _session;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _session = DigitSpanSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() => _session.begin());
    _scheduleRevealTick(initial: true);
  }

  void _scheduleRevealTick({bool initial = false}) {
    _timer?.cancel();
    final delay = initial
        ? const Duration(milliseconds: 400)
        : const Duration(milliseconds: _digitGapMs);
    _timer = Timer(delay, () {
      if (!mounted || _session.phase != DigitSpanPhase.showing) return;
      final done = _session.advanceReveal();
      setState(() {});
      if (done) return;
      _timer = Timer(
        const Duration(milliseconds: _digitShowMs),
        _scheduleRevealTick,
      );
    });
  }

  void _submit() {
    if (_session.phase != DigitSpanPhase.input) return;
    _session.submit();
    setState(() {});
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: _feedbackMs), () {
      if (!mounted) return;
      if (_session.phase == DigitSpanPhase.finished) {
        _finish();
        setState(() {});
        return;
      }
      _session.continueAfterFeedback();
      setState(() {});
      if (_session.phase == DigitSpanPhase.showing) {
        _scheduleRevealTick(initial: true);
      }
    });
  }

  void _finish() {
    final bonus = numberMemoryBcsBonus(_session.maxDigitsReached);
    ref.read(bcScoreProvider.notifier).applyBonus(
          bonus,
          xpSource: XpSource.game,
          xpRefId: 'number_memory:${DateTime.now().millisecondsSinceEpoch}',
        );
    ref
        .read(gamesBestScoresControllerProvider.notifier)
        .updateNumberMemoryBest(_session.maxDigitsReached);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final phase = _session.phase;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(loc.gameNumberMemoryTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (phase == DigitSpanPhase.intro) ...[
              Text(
                loc.gameDigitSpanIntro,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _start,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(loc.gameStart),
              ),
            ] else if (phase == DigitSpanPhase.finished) ...[
              Text(
                loc.gameNumberMemoryResult(_session.maxDigitsReached),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.gameDigitSpanLengthLabel(_session.maxDigitsReached),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ] else ...[
              Text(
                phase == DigitSpanPhase.showing
                    ? loc.gameDigitSpanWatch
                    : phase == DigitSpanPhase.input
                        ? loc.gameEnterSequence
                        : _session.lastAttemptCorrect == true
                            ? loc.gameDigitSpanCorrect
                            : loc.gameDigitSpanWrong,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.gameDigitSpanLevel(_session.length),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 32),
              if (phase == DigitSpanPhase.showing)
                Text(
                  _session.currentRevealedDigit ?? '•',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                )
              else if (phase == DigitSpanPhase.input) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    _session.input.isEmpty ? '—' : _session.input,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                NumericKeypad(
                  clearLabel: loc.gameDigitSpanClear,
                  backspaceLabel: loc.gameDigitSpanDelete,
                  onDigit: (d) => setState(() => _session.appendDigit(d)),
                  onBackspace: () => setState(() => _session.backspace()),
                  onClear: () => setState(() => _session.clearInput()),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _session.input.length == _session.digitCount
                      ? _submit
                      : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(loc.gameSubmitRound),
                ),
              ] else
                Icon(
                  _session.lastAttemptCorrect == true
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 72,
                  color: _session.lastAttemptCorrect == true
                      ? AppColors.primary
                      : AppColors.goldText,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
