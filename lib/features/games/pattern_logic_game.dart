import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import '../gamification/domain/xp_source.dart';
import 'application/games_scores_provider.dart';
import 'domain/game_scoring.dart';

class _PatternQuestion {
  const _PatternQuestion({
    required this.sequence,
    required this.missingIndex,
    required this.options,
    required this.correctIndex,
  });

  final List<String> sequence;
  final int missingIndex;
  final List<String> options;
  final int correctIndex;
}

/// Pattern logic — timed fluid-intelligence sequences (5 questions).
class PatternLogicGameScreen extends ConsumerStatefulWidget {
  const PatternLogicGameScreen({super.key});

  @override
  ConsumerState<PatternLogicGameScreen> createState() =>
      _PatternLogicGameScreenState();
}

class _PatternLogicGameScreenState
    extends ConsumerState<PatternLogicGameScreen> {
  static const _totalQuestions = 5;
  static const _secondsPerQuestion = 30;

  final _random = Random();
  late final List<_PatternQuestion> _questions;

  int _index = 0;
  int? _selected;
  int _correctCount = 0;
  bool _finished = false;
  int _secondsLeft = _secondsPerQuestion;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _questions = List.generate(_totalQuestions, (_) => _buildQuestion());
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _PatternQuestion _buildQuestion() {
    final useNumbers = _random.nextBool();
    if (useNumbers) {
      final start = _random.nextInt(5) + 1;
      final step = _random.nextInt(3) + 1;
      final seq = List.generate(5, (i) => '${start + i * step}');
      final missing = _random.nextInt(5);
      final answer = seq[missing];
      final options = <String>{answer};
      while (options.length < 4) {
        options.add('${start + _random.nextInt(20)}');
      }
      final shuffled = options.toList()..shuffle(_random);
      return _PatternQuestion(
        sequence: seq,
        missingIndex: missing,
        options: shuffled,
        correctIndex: shuffled.indexOf(answer),
      );
    }

    const shapes = ['○', '□', '△', '◇', '★'];
    final patternLen = 4;
    final base = List.generate(
      patternLen,
      (_) => shapes[_random.nextInt(shapes.length)],
    );
    final next = shapes[_random.nextInt(shapes.length)];
    final seq = [...base, next];
    final missing = _random.nextInt(seq.length);
    final answer = seq[missing];
    final options = <String>{answer};
    while (options.length < 4) {
      options.add(shapes[_random.nextInt(shapes.length)]);
    }
    final shuffled = options.toList()..shuffle(_random);
    return _PatternQuestion(
      sequence: seq,
      missingIndex: missing,
      options: shuffled,
      correctIndex: shuffled.indexOf(answer),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _finished) return;
      if (_secondsLeft <= 1) {
        _submitAnswer(forceWrong: true);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  void _submitAnswer({bool forceWrong = false}) {
    if (_finished) return;
    _timer?.cancel();
    final q = _questions[_index];
    final ok = !forceWrong && _selected == q.correctIndex;
    if (ok) _correctCount++;

    if (_index >= _totalQuestions - 1) {
      _finishGame();
      return;
    }
    setState(() {
      _index++;
      _selected = null;
    });
    _startTimer();
  }

  void _finishGame() {
    _timer?.cancel();
    final score = ((_correctCount / _totalQuestions) * 100).round();
    final bonus = patternMatchBcsBonus(score.toDouble());
    ref.read(bcScoreProvider.notifier).applyBonus(
          bonus,
          xpSource: XpSource.game,
          xpRefId: 'pattern_logic:${DateTime.now().millisecondsSinceEpoch}',
        );
    ref.read(gamesBestScoresControllerProvider.notifier).updatePatternBest(score);
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_finished) {
      final score = ((_correctCount / _totalQuestions) * 100).round();
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(loc.v2ExercisesPatternLogicTitle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                loc.gamePatternLogicResult(_correctCount, _totalQuestions),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                loc.gameFinalScore(score),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final q = _questions[_index];
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(loc.v2ExercisesPatternLogicTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.gamePatternLogicProgress(_index + 1, _totalQuestions),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  loc.gamePatternLogicTimeLeft(_secondsLeft),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: _secondsLeft <= 10
                        ? AppColors.danger
                        : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              loc.v2ExercisesPatternLogicSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < q.sequence.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == q.missingIndex
                          ? AppColors.primaryDim
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: i == q.missingIndex
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      i == q.missingIndex ? '?' : q.sequence[i],
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),
            ...List.generate(q.options.length, (i) {
              final selected = _selected == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  onPressed: () => setState(() => _selected = i),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor:
                        selected ? AppColors.primaryDim : Colors.transparent,
                    side: BorderSide(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    q.options[i],
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              );
            }),
            const Spacer(),
            FilledButton(
              onPressed: _selected == null ? null : () => _submitAnswer(),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(loc.gameSubmitRound),
            ),
          ],
        ),
      ),
    );
  }
}
