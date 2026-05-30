import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import 'application/games_scores_provider.dart';
import 'domain/speed_sort_logic.dart';

class _FallingItem {
  _FallingItem({
    required this.value,
    required this.isEven,
    required this.y,
  });

  final int value;
  final bool isEven;
  double y;
}

/// Speed sort — swipe even/odd into buckets for 30 seconds.
class SpeedSortGameScreen extends ConsumerStatefulWidget {
  const SpeedSortGameScreen({super.key});

  @override
  ConsumerState<SpeedSortGameScreen> createState() =>
      _SpeedSortGameScreenState();
}

class _SpeedSortGameScreenState extends ConsumerState<SpeedSortGameScreen> {
  static const _durationSeconds = 30;
  final _random = Random();
  final List<_FallingItem> _items = [];

  bool _running = false;
  bool _finished = false;
  int _secondsLeft = _durationSeconds;
  int _correct = 0;
  int _wrong = 0;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  Timer? _fallTimer;

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _fallTimer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _finished = false;
      _secondsLeft = _durationSeconds;
      _correct = 0;
      _wrong = 0;
      _items.clear();
    });
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _endGame();
        return;
      }
      setState(() => _secondsLeft--);
    });
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      _spawnItem();
    });
    _fallTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      setState(() {
        for (final item in _items) {
          item.y += 0.02;
        }
        _items.removeWhere((i) => i.y > 1.1);
      });
    });
  }

  void _spawnItem() {
    if (!_running) return;
    final value = _random.nextInt(20) + 1;
    setState(() {
      _items.add(
        _FallingItem(
          value: value,
          isEven: value.isEven,
          y: 0,
        ),
      );
    });
  }

  void _sort(bool evenBucket) {
    if (!_running || _items.isEmpty) return;
    final item = _items.removeAt(0);
    if (item.isEven == evenBucket) {
      _correct++;
    } else {
      _wrong++;
    }
    setState(() {});
  }

  void _endGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _fallTimer?.cancel();
    final bonus = speedSortBcsBonus(_correct);
    ref.read(bcScoreProvider.notifier).applyBonus(bonus);
    ref
        .read(gamesBestScoresControllerProvider.notifier)
        .updateSpeedSortBest(_correct);
    setState(() {
      _running = false;
      _finished = true;
      _items.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = ref.watch(localeProvider).languageCode == 'ar';

    if (!_running && !_finished) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1117),
          title: Text(loc.gameSpeedSortTitle),
        ),
        body: Center(
          child: FilledButton(
            onPressed: _start,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1D9E75),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            child: Text(loc.gameStart),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: Text(loc.gameSpeedSortTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _finished
                  ? loc.gameSpeedSortResult(_correct, _wrong)
                  : '${_secondsLeft}s — ${loc.gameSpeedSortCorrect(_correct)}',
              style: const TextStyle(color: Color(0xFFE6EDF3)),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                for (final item in _items)
                  Positioned(
                    left: MediaQuery.sizeOf(context).width / 2 - 24,
                    top: item.y * MediaQuery.sizeOf(context).height * 0.5,
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF30363D)),
                      ),
                      child: Text(
                        '${item.value}',
                        style: const TextStyle(
                          color: Color(0xFFE6EDF3),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _sort(true),
                  child: Container(
                    height: 72,
                    margin: const EdgeInsets.all(12),
                    color: const Color(0xFF3B82F6),
                    alignment: Alignment.center,
                    child: Text(
                      isAr ? 'زوجي' : loc.gameSpeedSortEven,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _sort(false),
                  child: Container(
                    height: 72,
                    margin: const EdgeInsets.all(12),
                    color: const Color(0xFF1D9E75),
                    alignment: Alignment.center,
                    child: Text(
                      isAr ? 'فردي' : loc.gameSpeedSortOdd,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
