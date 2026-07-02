import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../gamification/data/xp_ledger_constants.dart';
import 'bc_score_provider.dart';
import 'visual_cognitive_scorer.dart';

const visualCognitiveGridKey = Key('visual_cognitive_grid');

List<Color> _gamePalette(ColorScheme cs) => [
      cs.primary,
      cs.error,
      Color.lerp(cs.primary, cs.error, 0.5)!,
      Color.lerp(cs.primary, cs.onSurface, 0.35)!,
      cs.onSurfaceVariant,
    ];

/// 5-round odd-color-out visual attention test.
class VisualCognitiveTestScreen extends ConsumerStatefulWidget {
  const VisualCognitiveTestScreen({super.key});

  @override
  ConsumerState<VisualCognitiveTestScreen> createState() =>
      _VisualCognitiveTestScreenState();
}

class _VisualCognitiveTestScreenState
    extends ConsumerState<VisualCognitiveTestScreen> {
  final _random = Random();
  int _round = 1;
  int _score = 0;
  int _targetIndex = 0;
  late List<Color> _palette;
  Color _baseColor = Colors.transparent;
  Color _targetColor = Colors.transparent;
  DateTime? _roundStartedAt;
  Timer? _roundTimer;
  bool _showResults = false;
  bool _roundResolved = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _palette = _gamePalette(Theme.of(context).colorScheme);
      _startRound();
    }
  }

  Color _brighter(Color base) {
    final r = base.r * 255.0;
    final g = base.g * 255.0;
    final b = base.b * 255.0;
    return Color.fromARGB(
      255,
      (r + 40).round().clamp(0, 255),
      (g + 40).round().clamp(0, 255),
      (b + 40).round().clamp(0, 255),
    );
  }

  void _startRound() {
    _roundResolved = false;
    _baseColor = _palette[_random.nextInt(_palette.length)];
    _targetIndex = _random.nextInt(9);
    _targetColor = _brighter(_baseColor);
    _roundStartedAt = DateTime.now();
    _roundTimer?.cancel();
    _roundTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || _roundResolved) return;
      _resolveRound(correct: false, timedOut: true);
    });
    setState(() {});
  }

  void _resolveRound({required bool correct, bool timedOut = false}) {
    if (_roundResolved) return;
    _roundResolved = true;
    _roundTimer?.cancel();

    if (timedOut) {
      _score += VisualCognitiveScorer.scoreTimeout();
    } else if (correct) {
      final elapsed = DateTime.now()
              .difference(_roundStartedAt ?? DateTime.now())
              .inMilliseconds /
          1000.0;
      _score += VisualCognitiveScorer.scoreCorrectTap(
        tapTimeSeconds: elapsed,
      );
    } else {
      _score += VisualCognitiveScorer.scoreWrongTap();
    }

    if (_round >= 5) {
      setState(() => _showResults = true);
      return;
    }

    setState(() => _round++);
    _startRound();
  }

  void _onSquareTap(int index) {
    if (_roundResolved || _showResults) return;
    _resolveRound(correct: index == _targetIndex);
  }

  void _finishAndPop() {
    final bonus = VisualCognitiveScorer.cognitiveBonus(_score);
    ref.read(bcScoreProvider.notifier).applyCognitiveBonus(
          bonus,
          xpRefId:
              'visual_cognitive_${XpLedgerConstants.utcDayKey(DateTime.now().toUtc())}',
        );
    context.pop();
  }

  Color _resultColor(ColorScheme cs) {
    if (_score >= 12) return cs.primary;
    if (_score >= 8) return cs.primary;
    if (_score >= 4) return cs.onSurfaceVariant;
    return cs.error;
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (_showResults) {
      final resultColor = _resultColor(colorScheme);
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  VisualCognitiveScorer.resultMessage(_score),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$_score / 15',
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _finishAndPop,
                  style: FilledButton.styleFrom(
                    backgroundColor: resultColor,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(loc.visualCognitiveBack),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.visualCognitiveRound(_round),
          style: TextStyle(color: colorScheme.onSurface),
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              loc.visualCognitiveInstruction,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                key: visualCognitiveGridKey,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  final color =
                      index == _targetIndex ? _targetColor : _baseColor;
                  return GestureDetector(
                    onTap: () => _onSquareTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ),
            Text(
              loc.visualCognitiveScore(_score),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
