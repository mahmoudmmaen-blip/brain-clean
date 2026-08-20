import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import '../gamification/domain/xp_source.dart';
import 'application/games_scores_provider.dart';
import 'domain/n_back_logic.dart';
import 'domain/n_back_session.dart';

/// Dual N-back — 3×3 grid, fixed 2-back, Match / Next responses.
class NBackGameScreen extends ConsumerStatefulWidget {
  const NBackGameScreen({super.key});

  @override
  ConsumerState<NBackGameScreen> createState() => _NBackGameScreenState();
}

class _NBackGameScreenState extends ConsumerState<NBackGameScreen> {
  static const _gridSize = 9;
  static const _pauseAfterResponseMs = 350;

  final _random = Random();
  late NBackSession _session;

  bool _showIntro = true;
  bool _bonusApplied = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _session = NBackSession(nLevel: 2);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _showIntro = false;
      _bonusApplied = false;
      _session = NBackSession(nLevel: 2);
    });
    _presentNextStimulus();
  }

  void _presentNextStimulus() {
    if (_session.finished || !mounted) return;
    final cell = _random.nextInt(_gridSize);
    setState(() {
      _session.presentStimulus(cell);
    });
  }

  void _afterResponse() {
    _timer?.cancel();
    if (_session.finished) {
      setState(() {});
      _finishGame();
      return;
    }
    setState(() {});
    _timer = Timer(
      const Duration(milliseconds: _pauseAfterResponseMs),
      _presentNextStimulus,
    );
  }

  void _onMatch() {
    if (!_session.canRespond) return;
    _session.respondMatch();
    _afterResponse();
  }

  void _onNext() {
    if (!_session.canRespond) return;
    _session.respondNext();
    _afterResponse();
  }

  void _finishGame() {
    if (_bonusApplied) return;
    _bonusApplied = true;
    _timer?.cancel();
    final maxN = _session.nLevel;
    final bonus = nBackBcsBonus(maxN);
    ref.read(bcScoreProvider.notifier).applyBonus(
          bonus,
          xpSource: XpSource.game,
          xpRefId: 'n_back:${DateTime.now().millisecondsSinceEpoch}',
        );
    ref.read(gamesBestScoresControllerProvider.notifier).updateNBackBest(maxN);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_showIntro) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(loc.gameNBackTitle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.gameNBackIntroDetail,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _startGame,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(loc.gameStart),
              ),
            ],
          ),
        ),
      );
    }

    final playing = !_session.finished;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(loc.gameNBackTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              playing
                  ? loc.gameNBackLevel(
                      _session.nLevel,
                      _session.stimulusIndex,
                      _session.stimuliPerRound,
                    )
                  : loc.gameNBackSessionResult(
                      _session.correctCount,
                      _session.incorrectCount,
                    ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (playing)
              Text(
                loc.gameNBackStats(
                  _session.correctCount,
                  _session.incorrectCount,
                ),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _gridSize,
                itemBuilder: (context, index) {
                  final lit = _session.activeCell == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: lit ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: lit ? AppColors.primary : AppColors.border,
                      ),
                      boxShadow: lit
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            if (playing) ...[
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _session.canRespond ? _onMatch : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(loc.gameNBackMatch),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _session.canRespond ? _onNext : null,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Text(loc.gameNBackNext),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                loc.gameNBackBonus(
                  nBackBcsBonus(_session.nLevel).toStringAsFixed(0),
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
