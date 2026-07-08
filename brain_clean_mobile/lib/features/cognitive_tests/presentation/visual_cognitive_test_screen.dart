import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';
import '../application/cognitive_test_results_provider.dart';
import '../domain/cognitive_test_scorer.dart';

const cognitiveVisualGridKey = Key('cognitive_visual_grid');

enum _VisualPhase { intro, playing, finished }

/// Odd-one-out visual attention test (8 rounds, increasing difficulty).
class VisualCognitiveTestScreen extends ConsumerStatefulWidget {
  const VisualCognitiveTestScreen({super.key});

  @override
  ConsumerState<VisualCognitiveTestScreen> createState() =>
      _VisualCognitiveTestScreenState();
}

class _VisualCognitiveTestScreenState
    extends ConsumerState<VisualCognitiveTestScreen> {
  static const _rounds = CognitiveTestScorer.visualDefaultRounds;

  List<Color> _palette(ColorScheme cs) => [
        cs.primary,
        cs.error,
        Color.lerp(cs.primary, cs.error, 0.5)!,
        Color.lerp(cs.primary, cs.onSurface, 0.35)!,
        cs.onSurfaceVariant,
      ];

  final _random = Random();
  _VisualPhase _phase = _VisualPhase.intro;
  int _round = 1;
  int _totalPoints = 0;
  int _targetIndex = 0;
  Color _baseColor = Colors.transparent;
  Color _oddColor = Colors.transparent;
  bool _useShapeOddity = false;
  DateTime? _roundStartedAt;
  Timer? _roundTimer;
  bool _roundResolved = false;
  String? _feedbackKey;

  @override
  void dispose() {
    _roundTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _round = 1;
    _totalPoints = 0;
    setState(() => _phase = _VisualPhase.playing);
    _startRound();
  }

  Color _adjustColor(Color base, {required bool subtle}) {
    final factor = subtle ? 18.0 : 45.0;
    return Color.fromARGB(
      255,
      (base.r * 255 + factor).round().clamp(0, 255),
      (base.g * 255 + factor).round().clamp(0, 255),
      (base.b * 255 + factor).round().clamp(0, 255),
    );
  }

  void _startRound() {
    _roundResolved = false;
    _feedbackKey = null;
    final palette = _palette(Theme.of(context).colorScheme);
    _baseColor = palette[_random.nextInt(palette.length)];
    _targetIndex = _random.nextInt(9);
    _useShapeOddity = _round >= 7;
    final subtle = _round >= 4 && _round < 7;
    _oddColor = _adjustColor(_baseColor, subtle: subtle);
    _roundStartedAt = DateTime.now();
    _roundTimer?.cancel();
    final timeoutMs = _round <= 3 ? 3500 : (_round <= 6 ? 3000 : 2500);
    _roundTimer = Timer(Duration(milliseconds: timeoutMs), () {
      if (!mounted || _roundResolved) return;
      _resolveRound(correct: false, timedOut: true);
    });
    setState(() {});
  }

  void _resolveRound({required bool correct, bool timedOut = false}) {
    if (_roundResolved || _phase != _VisualPhase.playing) return;
    _roundResolved = true;
    _roundTimer?.cancel();

    final elapsed = DateTime.now()
            .difference(_roundStartedAt ?? DateTime.now())
            .inMilliseconds /
        1000.0;

    final points = CognitiveTestScorer.visualRoundPoints(
      correct: correct,
      tapTimeSeconds: elapsed,
      timedOut: timedOut,
    );
    _totalPoints += points;

    final loc = AppLocalizations.of(context)!;
    setState(() {
      _feedbackKey = timedOut
          ? loc.cognitiveVisualTimeout
          : correct
              ? loc.cognitiveVisualCorrect
              : loc.cognitiveVisualWrong;
    });

    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_round >= _rounds) {
        setState(() => _phase = _VisualPhase.finished);
        return;
      }
      setState(() {
        _round++;
        _feedbackKey = null;
      });
      _startRound();
    });
  }

  void _onCellTap(int index) {
    if (_roundResolved || _phase != _VisualPhase.playing) return;
    _resolveRound(correct: index == _targetIndex);
  }

  Future<void> _saveAndPop() async {
    final result = CognitiveTestScorer.buildVisualResult(
      totalPoints: _totalPoints,
      roundsPlayed: _rounds,
    );
    await ref.read(cognitiveTestResultsProvider.notifier).recordVisual(result);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.cognitiveVisualTestTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _phase == _VisualPhase.intro
                    ? loc.cognitiveVisualInstructions
                    : _phase == _VisualPhase.finished
                        ? loc.cognitiveVisualResultTitle
                        : loc.cognitiveVisualFindOdd,
                textAlign: TextAlign.center,
                style: AppDesignConstants.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              if (_phase == _VisualPhase.playing) ...[
                const SizedBox(height: 8),
                Text(
                  loc.cognitiveVisualRound(_round, _rounds),
                  textAlign: TextAlign.center,
                  style: AppDesignConstants.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                if (_feedbackKey != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _feedbackKey!,
                      textAlign: TextAlign.center,
                      style: AppDesignConstants.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: switch (_phase) {
                    _VisualPhase.intro => Icon(
                        Icons.grid_view_rounded,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    _VisualPhase.finished => _VisualResultPanel(
                        totalPoints: _totalPoints,
                        score: CognitiveTestScorer.normalizeVisualScore(
                          _totalPoints,
                        ),
                        onDone: _saveAndPop,
                      ),
                    _VisualPhase.playing => _buildGrid(),
                  },
                ),
              ),
              if (_phase == _VisualPhase.intro)
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
    final dividerColor = Theme.of(context).dividerColor;
    return GridView.builder(
      key: cognitiveVisualGridKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final isOdd = index == _targetIndex;
        final fill = isOdd ? _oddColor : _baseColor;
        final isCircle = !isOdd || !_useShapeOddity;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onCellTap(index),
            borderRadius: BorderRadius.circular(isCircle ? 999 : 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: fill,
                shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isCircle ? null : BorderRadius.circular(8),
                border: Border.all(color: dividerColor),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VisualResultPanel extends StatelessWidget {
  const _VisualResultPanel({
    required this.totalPoints,
    required this.score,
    required this.onDone,
  });

  final int totalPoints;
  final double score;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    const maxPts =
        CognitiveTestScorer.visualDefaultRounds *
        CognitiveTestScorer.visualMaxPointsPerRound;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          loc.cognitiveVisualResultScore(totalPoints, maxPts, score.round()),
          textAlign: TextAlign.center,
          style: AppDesignConstants.cairo(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: cs.primary,
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
