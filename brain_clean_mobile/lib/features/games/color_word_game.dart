import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import '../gamification/domain/xp_source.dart';
import 'application/games_scores_provider.dart';
import 'domain/game_scoring.dart';

class _ColorInk {
  const _ColorInk(this.nameAr, this.nameEn, this.color);

  final String nameAr;
  final String nameEn;
  final Color color;
}

List<_ColorInk> _inks(ColorScheme cs) => [
      _ColorInk('أحمر', 'Red', cs.error),
      _ColorInk('أزرق', 'Blue', Color.lerp(cs.primary, cs.onSurface, 0.35)!),
      _ColorInk('أخضر', 'Green', cs.primary),
      _ColorInk(
        'أصفر',
        'Yellow',
        Color.lerp(cs.primary, cs.onSurface, 0.65)!,
      ),
    ];

/// Stroop-style color-word game — tap ink color, not the word.
class ColorWordGameScreen extends ConsumerStatefulWidget {
  const ColorWordGameScreen({super.key});

  @override
  ConsumerState<ColorWordGameScreen> createState() => _ColorWordGameScreenState();
}

class _ColorWordGameScreenState extends ConsumerState<ColorWordGameScreen> {
  static const _totalRounds = 10;
  static const _inkCount = 4;
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
    _wordIndex = _random.nextInt(_inkCount);
    _inkIndex = _random.nextInt(_inkCount);
    while (_inkIndex == _wordIndex) {
      _inkIndex = _random.nextInt(_inkCount);
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
    ref.read(bcScoreProvider.notifier).applyBonus(
          bonus,
          xpSource: XpSource.game,
          xpRefId: 'color_word:${DateTime.now().millisecondsSinceEpoch}',
        );
    ref.read(gamesBestScoresControllerProvider.notifier).updateColorWordBest(score);
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final colorScheme = Theme.of(context).colorScheme;
    final inks = _inks(colorScheme);
    final word = _wordIndex != null ? inks[_wordIndex!] : inks.first;
    final ink = _inkIndex != null ? inks[_inkIndex!] : inks.first;
    final displayWord = isAr ? word.nameAr : word.nameEn;

    return Scaffold(
      appBar: AppBar(
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
              style: TextStyle(color: colorScheme.onSurfaceVariant),
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
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            const Spacer(),
            if (!_finished)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(inks.length, (index) {
                  final c = inks[index];
                  final label = isAr ? c.nameAr : c.nameEn;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.color,
                      foregroundColor: colorScheme.onPrimary,
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
