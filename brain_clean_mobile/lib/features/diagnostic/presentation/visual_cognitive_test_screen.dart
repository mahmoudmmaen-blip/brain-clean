import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'bc_score_provider.dart';
import 'visual_cognitive_scorer.dart';

const visualCognitiveGridKey = Key('visual_cognitive_grid');

/// 5-round odd-color-out visual attention test.
class VisualCognitiveTestScreen extends ConsumerStatefulWidget {
  const VisualCognitiveTestScreen({super.key});

  @override
  ConsumerState<VisualCognitiveTestScreen> createState() =>
      _VisualCognitiveTestScreenState();
}

class _VisualCognitiveTestScreenState
    extends ConsumerState<VisualCognitiveTestScreen> {
  static const _bg = Color(0xFF0D1117);
  static const _palette = [
    Color(0xFF1D9E75),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
  ];

  final _random = Random();
  int _round = 1;
  int _score = 0;
  int _targetIndex = 0;
  Color _baseColor = _palette.first;
  Color _targetColor = _palette.first;
  DateTime? _roundStartedAt;
  Timer? _roundTimer;
  bool _showResults = false;
  bool _roundResolved = false;

  @override
  void initState() {
    super.initState();
    _startRound();
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
    ref.read(bcScoreProvider.notifier).applyCognitiveBonus(bonus);
    context.pop();
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      final color = VisualCognitiveScorer.resultColor(_score);
      return Scaffold(
        backgroundColor: _bg,
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
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$_score / 15',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF8B949E),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _finishAndPop,
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('العودة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: Text(
          'الجولة $_round / 5',
          style: const TextStyle(color: Color(0xFFE6EDF3)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8B949E)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'اضغط على المربع مختلف اللون',
              style: TextStyle(color: Color(0xFF8B949E), fontSize: 16),
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
              'النقاط: $_score',
              style: const TextStyle(
                color: Color(0xFFE6EDF3),
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
