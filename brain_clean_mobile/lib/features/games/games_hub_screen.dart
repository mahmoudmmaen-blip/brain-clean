import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/presentation/language_toggle_button.dart';
import 'application/games_scores_provider.dart';
import 'color_word_game.dart';
import 'crossword/crossword_screen.dart';
import 'n_back_game.dart';
import 'number_memory_game.dart';
import 'pattern_match_game.dart';
import 'speed_sort_game.dart';

const gamesHubScreenKey = Key('games_hub_screen');

/// Hub for pro-gated neuroplasticity mini-games.
class GamesHubScreen extends ConsumerWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final best = ref.watch(gamesBestScoresControllerProvider);

    return Scaffold(
      key: gamesHubScreenKey,
      appBar: AppBar(
        title: Text(loc.gamesHubTitle),
        actions: const [LanguageToggleButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GameCard(
            title: loc.gamePatternMatchTitle,
            subtitle: loc.gamePatternMatchDesc,
            bestLabel: loc.gamesBestScore(best.patternMatch),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PatternMatchGameScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _GameCard(
            title: loc.gameNumberMemoryTitle,
            subtitle: loc.gameNumberMemoryDesc,
            bestLabel: loc.gamesBestDigits(best.numberMemory),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NumberMemoryGameScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _GameCard(
            title: loc.gameColorWordTitle,
            subtitle: loc.gameColorWordDesc,
            bestLabel: loc.gamesBestScore(best.colorWord),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ColorWordGameScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _GameCard(
            title: loc.gameNBackTitle,
            subtitle: loc.gameNBackDesc,
            bestLabel: loc.gamesBestNLevel(best.nBack),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NBackGameScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _GameCard(
            title: loc.gameSpeedSortTitle,
            subtitle: loc.gameSpeedSortDesc,
            bestLabel: loc.gamesBestScore(best.speedSort),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SpeedSortGameScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _GameCard(
            title: loc.crosswordTitle,
            subtitle: loc.crosswordDesc,
            bestLabel: loc.crosswordPlayNow,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CrosswordScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.bestLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String bestLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              bestLabel,
              style: TextStyle(color: colorScheme.primary),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}
