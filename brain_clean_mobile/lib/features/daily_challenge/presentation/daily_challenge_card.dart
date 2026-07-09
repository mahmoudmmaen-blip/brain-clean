import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../games/application/games_scores_provider.dart';
import '../application/daily_challenge_provider.dart';
import '../domain/daily_challenge.dart';
import '../domain/daily_challenge_game_keys.dart';
import '../domain/daily_challenge_service.dart';

int _bestScoreForGame(GamesBestScores scores, String gameKey) {
  return switch (gameKey) {
    DailyChallengeGameKeys.nBack => scores.nBack,
    DailyChallengeGameKeys.speedSort => scores.speedSort,
    DailyChallengeGameKeys.colorWord => scores.colorWord,
    DailyChallengeGameKeys.numberMemory => scores.numberMemory,
    DailyChallengeGameKeys.patternMatch => scores.patternMatch,
    _ => 0,
  };
}

String _gameTitle(AppLocalizations loc, String gameKey) {
  return switch (gameKey) {
    DailyChallengeGameKeys.nBack => loc.dailyChallengeGameNBack,
    DailyChallengeGameKeys.speedSort => loc.dailyChallengeGameSpeedSort,
    DailyChallengeGameKeys.colorWord => loc.dailyChallengeGameColorWord,
    DailyChallengeGameKeys.numberMemory => loc.dailyChallengeGameNumberMemory,
    DailyChallengeGameKeys.patternMatch => loc.dailyChallengeGamePatternMatch,
    DailyChallengeGameKeys.crossword => loc.dailyChallengeGameCrossword,
    _ => loc.dailyChallengeTitle,
  };
}

String _gameSubtitle(AppLocalizations loc, String gameKey) {
  return switch (gameKey) {
    DailyChallengeGameKeys.nBack => loc.dailyChallengeSubtitleNBack,
    DailyChallengeGameKeys.speedSort => loc.dailyChallengeSubtitleSpeedSort,
    DailyChallengeGameKeys.colorWord => loc.dailyChallengeSubtitleColorWord,
    DailyChallengeGameKeys.numberMemory =>
      loc.dailyChallengeSubtitleNumberMemory,
    DailyChallengeGameKeys.patternMatch =>
      loc.dailyChallengeSubtitlePatternMatch,
    DailyChallengeGameKeys.crossword => loc.dailyChallengeSubtitleCrossword,
    _ => '',
  };
}

class DailyChallengeCard extends ConsumerWidget {
  const DailyChallengeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(dailyChallengeControllerProvider);

    return challengeAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (challenge) => _DailyChallengeCardBody(challenge: challenge),
    );
  }
}

class _DailyChallengeCardBody extends ConsumerStatefulWidget {
  const _DailyChallengeCardBody({required this.challenge});

  final DailyChallenge challenge;

  @override
  ConsumerState<_DailyChallengeCardBody> createState() =>
      _DailyChallengeCardBodyState();
}

class _DailyChallengeCardBodyState
    extends ConsumerState<_DailyChallengeCardBody> {
  bool _busy = false;

  Future<void> _startChallenge() async {
    if (_busy) return;
    setState(() => _busy = true);

    final gameKey = widget.challenge.gameKey;
    final route = DailyChallengeService.getGameRoute(gameKey);
    final beforeScore = _bestScoreForGame(
      ref.read(gamesBestScoresControllerProvider),
      gameKey,
    );

    try {
      await context.push(route);
      if (!mounted) return;

      final afterScore = _bestScoreForGame(
        ref.read(gamesBestScoresControllerProvider),
        gameKey,
      );
      final scoredToday = afterScore > beforeScore;
      final isCrossword = gameKey == DailyChallengeGameKeys.crossword;

      if (!widget.challenge.isCompleted && (scoredToday || isCrossword)) {
        await ref.read(dailyChallengeControllerProvider.notifier).markCompleted();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    final challenge = widget.challenge;
    final gameKey = challenge.gameKey;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(color: colorScheme.primary, width: 3),
        ),
      ),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  loc.dailyChallengeIcon,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  loc.dailyChallengeTitle,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (challenge.isCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      loc.dailyChallengeCompleted,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _gameTitle(loc, gameKey),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _gameSubtitle(loc, gameKey),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _busy ? null : _startChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _busy
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      challenge.isCompleted
                          ? loc.dailyChallengeReplay
                          : loc.dailyChallengeStart,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
