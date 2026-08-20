import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import '../gamification/domain/xp_source.dart';
import 'application/games_scores_provider.dart';
import 'domain/game_scoring.dart';
import 'domain/stroop_session.dart';

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

/// Stroop test — tap ink color, not the word. Ten rounds with score summary.
class ColorWordGameScreen extends ConsumerStatefulWidget {
  const ColorWordGameScreen({super.key});

  @override
  ConsumerState<ColorWordGameScreen> createState() =>
      _ColorWordGameScreenState();
}

class _ColorWordGameScreenState extends ConsumerState<ColorWordGameScreen> {
  late StroopSession _session;

  @override
  void initState() {
    super.initState();
    _session = StroopSession();
    _session.startRound();
  }

  void _pickInk(int index) {
    if (_session.finished) return;
    _session.answer(index);
    if (_session.finished) {
      _finish();
    }
    setState(() {});
  }

  void _finish() {
    final score = _session.scorePercent;
    final bonus = colorWordBcsBonus(
      correct: _session.correct,
      totalRounds: _session.totalRounds,
    );
    ref.read(bcScoreProvider.notifier).applyBonus(
          bonus,
          xpSource: XpSource.game,
          xpRefId: 'color_word:${DateTime.now().millisecondsSinceEpoch}',
        );
    ref
        .read(gamesBestScoresControllerProvider.notifier)
        .updateColorWordBest(score);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final wordIdx = _session.wordIndex ?? 0;
    final inkIdx = _session.inkIndex ?? 0;
    final word = _inks[wordIdx];
    final ink = _inks[inkIdx];
    final displayWord = isAr ? word.nameAr : word.nameEn;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(loc.gameColorWordTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              _session.finished
                  ? loc.gameStroopResult(
                      _session.correct,
                      _session.totalRounds,
                    )
                  : loc.gameRoundLabel(
                      _session.round + 1,
                      _session.totalRounds,
                    ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (!_session.finished) ...[
              const SizedBox(height: 8),
              Text(
                loc.gameStroopStats(_session.correct, _session.incorrect),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 48),
            if (!_session.finished)
              Semantics(
                label: loc.gameColorWordPrompt,
                child: Text(
                  displayWord,
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    color: ink.color,
                    letterSpacing: 1,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (!_session.finished)
              Text(
                loc.gameColorWordPrompt,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            const Spacer(),
            if (!_session.finished)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(_inks.length, (index) {
                  final c = _inks[index];
                  final label = isAr ? c.nameAr : c.nameEn;
                  return Semantics(
                    button: true,
                    label: label,
                    child: Material(
                      color: c.color,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _pickInk(index),
                        child: SizedBox(
                          width: 132,
                          height: 52,
                          child: Center(
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              )
            else ...[
              Text(
                loc.gameFinalScore(_session.scorePercent),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.gameStroopStats(_session.correct, _session.incorrect),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
