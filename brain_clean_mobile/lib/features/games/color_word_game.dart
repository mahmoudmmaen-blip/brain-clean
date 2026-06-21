import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import 'application/games_scores_provider.dart';
import 'domain/game_scoring.dart';

class _ColorInk {
  const _ColorInk(this.nameAr, this.nameEn, this.color);

  final String nameAr;
  final String nameEn;
  final Color color;
}

const _inks = [
  _ColorInk('أحمر', 'Red', Color(0xFFEF4444)),
  _ColorInk('أزرق', 'Blue', Color(0xFF3B82F6)),
  _ColorInk('أخضر', 'Green', Color(0xFF22C55E)),
  _ColorInk('أصفر', 'Yellow', Color(0xFFEAB308)),
];

/// Stroop-style color-word game — tap ink color, not the word.
class ColorWordGameScreen extends ConsumerStatefulWidget {
  const ColorWordGameScreen({super.key});

  @override
  ConsumerState<ColorWordGameScreen> createState() => _ColorWordGameScreenState();
}

class _ColorWordGameScreenState extends ConsumerState<ColorWordGameScreen> {
  static const _totalRounds = 10;
  final _random = Random();

  int _round = 0;
  int _correct = 0;
  int? _wordIndex;
  int? _inkIndex;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  void _nextRound() {
    _wordIndex = _random.nextInt(_inks.length);
    _inkIndex = _random.nextInt(_inks.length);
    while (_inkIndex == _wordIndex) {
      _inkIndex = _random.nextInt(_inks.length);
    }
  }

  void _pickInk(int index) {
    if (_finished || _inkIndex == null) return;
    if (index == _inkIndex) _correct++;
    if (_round >= _totalRounds - 1) {
      _finish();
      return;
    }
    setState(() {
      _round++;
      _nextRound();
    });
  }

  void _finish() {
    final score = ((_correct / _totalRounds) * 100).round();
    final bonus = colorWordBcsBonus(correct: _correct, totalRounds: _totalRounds);
    ref.read(bcScoreProvider.notifier).applyBonus(bonus);
    ref.read(gamesBestScoresControllerProvider.notifier).updateColorWordBest(score);
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final word = _wordIndex != null ? _inks[_wordIndex!] : _inks.first;
    final ink = _inkIndex != null ? _inks[_inkIndex!] : _inks.first;
    final displayWord = isAr ? word.nameAr : word.nameEn;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: Text(loc.gameColorWordTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              _finished
                  ? loc.gameFinalScore(((_correct / _totalRounds) * 100).round())
                  : loc.gameRoundLabel(_round + 1, _totalRounds),
              style: const TextStyle(color: Color(0xFF8B949E)),
            ),
            const SizedBox(height: 48),
            if (!_finished)
              Text(
                displayWord,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: ink.color,
                ),
              ),
            const SizedBox(height: 16),
            if (!_finished)
              Text(
                loc.gameColorWordPrompt,
                style: const TextStyle(color: Color(0xFF8B949E)),
              ),
            const Spacer(),
            if (!_finished)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(_inks.length, (index) {
                  final c = _inks[index];
                  final label = isAr ? c.nameAr : c.nameEn;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.color,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 48),
                    ),
                    onPressed: () => _pickInk(index),
                    child: Text(label),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}
