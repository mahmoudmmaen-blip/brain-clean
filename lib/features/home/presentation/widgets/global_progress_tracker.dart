import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/glow_progress.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/v2_shell_visual.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../diagnostic/domain/pillar_bound_evaluation.dart';
import '../../../diagnostic/presentation/widgets/bc_score_colors.dart';

const globalProgressTrackerKey = Key('global_progress_tracker');

/// Premium dual-ring tracker: live BC_score + 30-day challenge completion.
class GlobalProgressTracker extends StatefulWidget {
  const GlobalProgressTracker({
    super.key,
    required this.bcScore,
    required this.challengeProgress,
    this.hasSession = true,
  });

  final double bcScore;
  final double challengeProgress;
  final bool hasSession;

  @override
  State<GlobalProgressTracker> createState() => _GlobalProgressTrackerState();
}

class _GlobalProgressTrackerState extends State<GlobalProgressTracker>
    with SingleTickerProviderStateMixin {
  AnimationController? _glowController;

  static double clampBcsProgress(double bcScore) {
    final raw = bcScore / 100;
    const eps = PillarBoundEvaluation.coherenceEpsilon;
    if (raw <= eps) return 0.0;
    if (raw >= 1.0 - eps) return 1.0;
    return raw.clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _syncGlowController();
  }

  @override
  void didUpdateWidget(GlobalProgressTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncGlowController();
  }

  void _syncGlowController() {
    final shouldGlow = widget.hasSession && widget.bcScore > 80;
    if (shouldGlow && _glowController == null) {
      _glowController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..repeat(reverse: true);
    } else if (!shouldGlow && _glowController != null) {
      _glowController!.dispose();
      _glowController = null;
    }
  }

  @override
  void dispose() {
    _glowController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final clampedBcs = widget.bcScore.clamp(0.0, 100.0);
    final scoreColor = widget.hasSession
        ? BcScoreColors.forScore(clampedBcs)
        : context.textMuted;
    final challengePct =
        (widget.challengeProgress.clamp(0, 1) * 100).round();
    final targetProgress = clampBcsProgress(clampedBcs);
    final showGlow = widget.hasSession && clampedBcs > 80;

    return DecoratedBox(
      key: globalProgressTrackerKey,
      decoration: V2ShellVisual.heroCardDecoration(Theme.of(context)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        child: Row(
          children: [
            SizedBox(
              width: 124,
              height: 124,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: targetProgress),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  Widget ring = GlowProgressRing(
                    progress: value,
                    size: 124,
                    strokeWidth: 11,
                    color: scoreColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.hasSession
                                ? '${clampedBcs.round()}%'
                                : '—',
                            style: AppDesignConstants.cairo(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: scoreColor,
                              height: 1.05,
                              letterSpacing: -1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.bcScoreHeroLabel,
                          style: AppDesignConstants.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.6,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );

                  if (showGlow && _glowController != null) {
                    ring = AnimatedBuilder(
                      animation: _glowController!,
                      builder: (context, child) {
                        final glow = 0.22 + 0.2 * _glowController!.value;
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: scoreColor.withValues(alpha: glow),
                                blurRadius: 20 + 10 * _glowController!.value,
                                spreadRadius: 1.5 * _glowController!.value,
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                      child: ring,
                    );
                  }

                  return ring;
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loc.homeChallengeProgressTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: widget.challengeProgress.clamp(0.0, 1.0),
                    ),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return GlowProgressBar(
                        progress: value,
                        height: 10,
                        color: AppColors.primary,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    loc.homeChallengeProgressPercent(challengePct),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
