import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import 'application/games_scores_provider.dart';
import 'domain/game_scoring.dart';

/// Pattern memory game — recreate a flashed 3×3 grid.
class PatternMatchGameScreen extends ConsumerStatefulWidget {
  const PatternMatchGameScreen({super.key});

  @override
  ConsumerState<PatternMatchGameScreen> createState() =>
      _PatternMatchGameScreenState();
}

class _PatternMatchGameScreenState
    extends ConsumerState<PatternMatchGameScreen> {
  static const _rounds = 5;
  static const _size = 9;
  final _random = Random();

  int _round = 0;
  int _patternCells = 3;
  Set<int> _pattern = {};
  Set<int> _userSelection = {};
  bool _showPattern = true;
  bool _finished = false;
  int _totalCorrect = 0;
  int _totalCells = 0;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    _patternCells = 3 + _round;
    _pattern = _generatePattern(_patternCells);
    _userSelection = {};
    _showPattern = true;
    _finished = false;
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showPattern = false);
    });
  }

  Set<int> _generatePattern(int count) {
    final cells = <int>{};
    while (cells.length < count && cells.length < _size) {
      cells.add(_random.nextInt(_size));
    }
    return cells;
  }

  void _toggleCell(int index) {
    if (_showPattern || _finished) return;
    setState(() {
      if (_userSelection.contains(index)) {
        _userSelection.remove(index);
      } else {
        _userSelection.add(index);
      }
    });
  }

  void _submitRound() {
    final correct = _pattern.intersection(_userSelection).length;
    _totalCorrect += correct;
    _totalCells += _pattern.length;

    if (_round >= _rounds - 1) {
      _finishGame();
      return;
    }
    setState(() => _round++);
    _startRound();
  }

  void _finishGame() {
    final score = patternMatchScore(
      correctCells: _totalCorrect,
      totalCells: _totalCells,
    ).round();
    final bonus = patternMatchBcsBonus(score.toDouble());
    ref.read(bcScoreProvider.notifier).applyBonus(bonus);
    ref.read(gamesBestScoresControllerProvider.notifier).updatePatternBest(score);
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final score = patternMatchScore(
      correctCells: _totalCorrect,
      totalCells: _totalCells > 0 ? _totalCells : 1,
    ).round();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: Text(loc.gamePatternMatchTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _finished
                  ? loc.gameFinalScore(score)
                  : loc.gameRoundLabel(_round + 1, _rounds),
              style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 18),
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _size,
                itemBuilder: (context, index) {
                  final active = _showPattern
                      ? _pattern.contains(index)
                      : _userSelection.contains(index);
                  return GestureDetector(
                    onTap: () => _toggleCell(index),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF1D9E75)
                            : const Color(0xFF30363D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            if (!_finished && !_showPattern)
              FilledButton(
                onPressed: _submitRound,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1D9E75),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(loc.gameSubmitRound),
              ),
          ],
        ),
      ),
    );
  }
}
