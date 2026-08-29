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

/// Dual N-back — 3×3 grid, adaptive N, Match / Next responses.
class NBackGameScreen extends ConsumerStatefulWidget {
  const NBackGameScreen({super.key});

  @override
  ConsumerState<NBackGameScreen> createState() => _NBackGameScreenState();
}

class _NBackGameScreenState extends ConsumerState<NBackGameScreen> {
  static const _gridSize = 9;
  static const _stimulusIntervalMs = 2000;
  static const _pauseAfterResponseMs = 400;
  static const _sessionMinutes = 8;

  final _random = Random();
  late NBackSession _session;

  bool _showIntro = true;
  bool _bonusApplied = false;
  Timer? _stimulusTimer;
  Timer? _sessionTimer;
  int _sessionSecondsLeft = _sessionMinutes * 60;

  @override
  void initState() {
    super.initState();
    _session = NBackSession(nLevel: 1, stimuliPerRound: 999);
  }

  @override
  void dispose() {
    _stimulusTimer?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _showIntro = false;
      _bonusApplied = false;
      _sessionSecondsLeft = _sessionMinutes * 60;
      _session = NBackSession(nLevel: 1, stimuliPerRound: 999);
    });
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _session.finished) return;
      if (_sessionSecondsLeft <= 1) {
        _endSession();
        return;
      }
      setState(() => _sessionSecondsLeft -= 1);
    });
    _presentNextStimulus();
  }

  void _endSession() {
    _stimulusTimer?.cancel();
    _sessionTimer?.cancel();
    if (!_session.finished) {
      _session.forceFinish();
      setState(() {});
    }
    _finishGame();
  }

  void _presentNextStimulus() {
    if (_session.finished || !mounted) return;
    final cell = _random.nextInt(_gridSize);
    setState(() {
      _session.presentStimulus(cell);
    });
    _stimulusTimer?.cancel();
    _stimulusTimer = Timer(
      const Duration(milliseconds: _stimulusIntervalMs),
      () {
        if (!mounted || _session.finished) return;
        if (_session.canRespond) {
          _session.respondNext();
          _afterResponse();
        }
      },
    );
  }

  void _afterResponse() {
    _stimulusTimer?.cancel();
    if (_session.finished || _sessionSecondsLeft <= 0) {
      _endSession();
      return;
    }
    setState(() {});
    _stimulusTimer = Timer(
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
    _stimulusTimer?.cancel();
    _sessionTimer?.cancel();
    final maxN = _session.nLevel;
    final bonus = nBackBcsBonus(maxN);
    ref.read(bcScoreProvider.notifier).applyBonus(
          bonus,
          xpSource: XpSource.game,
          xpRefId: 'n_back:${DateTime.now().millisecondsSinceEpoch}',
        );
    ref.read(gamesBestScoresControllerProvider.notifier).updateNBackBest(maxN);
    if (mounted) setState(() {});
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
          title: Text(loc.v2ExercisesNBackTitle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryDim,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  loc.v2ExercisesScienceBadgeNBack,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.v2ExercisesNBackSubtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
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
        title: Text(loc.v2ExercisesNBackTitle),
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
            const SizedBox(height: 4),
            if (playing)
              Text(
                loc.gameNBackSessionTimeLeft(_sessionSecondsLeft ~/ 60),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
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
                loc.gameNBackResult(_session.nLevel),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
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
