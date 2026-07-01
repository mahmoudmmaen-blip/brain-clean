import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';
import '../application/cognitive_test_results_provider.dart';
import '../domain/cognitive_test_scorer.dart';

const memoryMiniGridKey = Key('memory_mini_grid');

enum _MemoryPhase { intro, showing, input, finished }

/// Simon-style sequence recall on a 3×3 grid.
class MemoryMiniGameScreen extends ConsumerStatefulWidget {
  const MemoryMiniGameScreen({super.key});

  @override
  ConsumerState<MemoryMiniGameScreen> createState() =>
      _MemoryMiniGameScreenState();
}

class _MemoryMiniGameScreenState extends ConsumerState<MemoryMiniGameScreen> {
  static const _gridSize = 9;
  static const _cellColors = [
    Color(0xFF1D9E75),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
  ];

  final _random = Random();
  _MemoryPhase _phase = _MemoryPhase.intro;
  int _sequenceLength = CognitiveTestScorer.memoryMinSpan;
  int _longestSuccessful = 0;
  List<int> _sequence = [];
  List<int> _userInput = [];
  int _showIndex = -1;
  int? _lastTapped;
  bool? _lastRoundCorrect;
  Timer? _showTimer;

  @override
  void dispose() {
    _showTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _sequenceLength = CognitiveTestScorer.memoryMinSpan;
    _longestSuccessful = 0;
    _beginRound();
  }

  void _beginRound() {
    _sequence = List.generate(
      _sequenceLength,
      (_) => _random.nextInt(_gridSize),
    );
    _userInput = [];
    _showIndex = -1;
    _lastTapped = null;
    _lastRoundCorrect = null;
    setState(() => _phase = _MemoryPhase.showing);
    _playSequence(0);
  }

  void _playSequence(int index) {
    if (!mounted) return;
    if (index >= _sequence.length) {
      setState(() {
        _showIndex = -1;
        _phase = _MemoryPhase.input;
      });
      return;
    }
    setState(() => _showIndex = _sequence[index]);
    _showTimer?.cancel();
    _showTimer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() => _showIndex = -1);
      _showTimer = Timer(const Duration(milliseconds: 250), () {
        _playSequence(index + 1);
      });
    });
  }

  void _onCellTap(int index) {
    if (_phase != _MemoryPhase.input) return;
    setState(() => _lastTapped = index);
    _userInput.add(index);

    final step = _userInput.length - 1;
    if (_userInput[step] != _sequence[step]) {
      _endGame(success: false);
      return;
    }

    if (_userInput.length == _sequence.length) {
      _longestSuccessful = _sequenceLength;
      if (_sequenceLength >= CognitiveTestScorer.memoryMaxSpan) {
        _endGame(success: true);
        return;
      }
      setState(() {
        _lastRoundCorrect = true;
        _sequenceLength++;
      });
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (mounted && _phase == _MemoryPhase.input) _beginRound();
      });
    }
  }

  void _endGame({required bool success}) {
    _showTimer?.cancel();
    if (success) {
      _longestSuccessful = _sequenceLength;
    }
    setState(() {
      _lastRoundCorrect = success;
      _phase = _MemoryPhase.finished;
    });
  }

  Future<void> _saveAndPop() async {
    final result = CognitiveTestScorer.buildMemoryResult(
      longestSuccessfulSpan: _longestSuccessful,
    );
    await ref.read(cognitiveTestResultsProvider.notifier).recordMemory(result);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: Text(loc.cognitiveMemoryGameTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _phase == _MemoryPhase.intro
                    ? loc.cognitiveMemoryInstructions
                    : _phase == _MemoryPhase.showing
                        ? loc.cognitiveMemoryWatch
                        : _phase == _MemoryPhase.input
                            ? loc.cognitiveMemoryYourTurn
                            : loc.cognitiveMemoryResultTitle,
                textAlign: TextAlign.center,
                style: AppDesignConstants.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE6EDF3),
                ),
              ),
              if (_phase != _MemoryPhase.intro && _phase != _MemoryPhase.finished)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    loc.cognitiveMemoryRound(_sequenceLength),
                    textAlign: TextAlign.center,
                    style: AppDesignConstants.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8B949E),
                    ),
                  ),
                ),
              if (_lastRoundCorrect == false && _phase == _MemoryPhase.finished)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    loc.cognitiveMemoryWrong,
                    textAlign: TextAlign.center,
                    style: AppDesignConstants.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: _phase == _MemoryPhase.intro
                      ? Icon(
                          Icons.grid_on_rounded,
                          size: 80,
                          color: Theme.of(context).colorScheme.secondary,
                        )
                      : _phase == _MemoryPhase.finished
                          ? _ResultPanel(
                              span: _longestSuccessful,
                              score: CognitiveTestScorer.normalizeMemoryScore(
                                _longestSuccessful,
                              ),
                              onDone: _saveAndPop,
                            )
                          : _buildGrid(),
                ),
              ),
              if (_phase == _MemoryPhase.intro)
                FilledButton(
                  onPressed: _startGame,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(loc.cognitiveStartButton),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      key: memoryMiniGridKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _gridSize,
      itemBuilder: (context, index) {
        final highlighted = _showIndex == index ||
            (_phase == _MemoryPhase.input && _lastTapped == index);
        final color = _cellColors[index % _cellColors.length];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: highlighted ? color : color.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: highlighted ? Colors.white : const Color(0xFF30363D),
              width: highlighted ? 2 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _phase == _MemoryPhase.input ? () => _onCellTap(index) : null,
            ),
          ),
        );
      },
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.span,
    required this.score,
    required this.onDone,
  });

  final int span;
  final double score;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          loc.cognitiveMemoryResultScore(span, score.round()),
          textAlign: TextAlign.center,
          style: AppDesignConstants.cairo(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D9E75),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onDone,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(loc.cognitiveDoneButton),
        ),
      ],
    );
  }
}
