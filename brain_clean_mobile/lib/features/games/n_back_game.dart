import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import '../gamification/domain/xp_source.dart';
import 'application/games_scores_provider.dart';
import 'domain/n_back_logic.dart';

/// Visual N-back working-memory training game.
class NBackGameScreen extends ConsumerStatefulWidget {
  const NBackGameScreen({super.key});

  @override
  ConsumerState<NBackGameScreen> createState() => _NBackGameScreenState();
}

class _NBackGameScreenState extends ConsumerState<NBackGameScreen> {
  static const _stimuliPerRound = 20;
  static const _gridSize = 9;
  final _random = Random();

  bool _showIntro = true;
  bool _playing = false;
  bool _finished = false;
  int _nLevel = 1;
  int _maxN = 1;
  int _stimulusIndex = 0;
  int _correctStreak = 0;
  int _correctTotal = 0;
  int? _activeCell;
  final List<int?> _history = [];

  Timer? _stimulusTimer;

  @override
  void dispose() {
    _stimulusTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _showIntro = false;
      _playing = true;
      _finished = false;
      _nLevel = 1;
      _maxN = 1;
      _stimulusIndex = 0;
      _correctStreak = 0;
      _correctTotal = 0;
      _history.clear();
      _activeCell = null;
    });
    _scheduleNextStimulus();
  }

  void _scheduleNextStimulus() {
    _stimulusTimer?.cancel();
    _stimulusTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted || !_playing) return;
      final cell = _random.nextInt(_gridSize);
      setState(() {
        _activeCell = cell;
        _history.add(cell);
        if (_history.length > _nLevel + 1) {
          _history.removeAt(0);
        }
        _stimulusIndex++;
      });
      if (_stimulusIndex >= _stimuliPerRound) {
        _finishGame();
        return;
      }
      _scheduleNextStimulus();
    });
  }

  void _onMatchTap() {
    if (!_playing || _activeCell == null) return;
    if (_history.length <= _nLevel) return;
    final nBackIndex = _history.length - 1 - _nLevel;
    final match = _history[nBackIndex] == _activeCell;
    if (match) {
      _correctTotal++;
      _correctStreak++;
      if (_correctStreak >= 10) {
        _nLevel = nBackLevelAfterCorrect(
          currentN: _nLevel,
          correctStreak: _correctStreak,
        );
        if (_nLevel > _maxN) _maxN = _nLevel;
        _correctStreak = 0;
      }
    } else {
      _correctStreak = 0;
    }
    setState(() {});
  }

  void _finishGame() {
    _stimulusTimer?.cancel();
    final bonus = nBackBcsBonus(_maxN);
    ref.read(bcScoreProvider.notifier).applyBonus(
          bonus,
          xpSource: XpSource.game,
          xpRefId: 'n_back:${DateTime.now().millisecondsSinceEpoch}',
        );
    ref.read(gamesBestScoresControllerProvider.notifier).updateNBackBest(_maxN);
    setState(() {
      _playing = false;
      _finished = true;
      _activeCell = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;

    if (_showIntro) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.gameNBackTitle)),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.gameNBackIntro,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _startGame,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(loc.gameStart),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(loc.gameNBackTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              _finished
                  ? loc.gameNBackResult(_maxN)
                  : loc.gameNBackLevel(_nLevel, _stimulusIndex, _stimuliPerRound),
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: _gridSize,
                itemBuilder: (context, index) {
                  final lit = _activeCell == index;
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: lit ? colorScheme.primary : dividerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            if (_playing)
              FilledButton(
                onPressed: _onMatchTap,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(loc.gameNBackMatch),
              ),
            if (_finished)
              Text(
                loc.gameNBackBonus(nBackBcsBonus(_maxN).toStringAsFixed(0)),
                style: TextStyle(color: colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }
}
