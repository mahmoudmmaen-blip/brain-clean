import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../diagnostic/domain/pillar_bound_evaluation.dart';
import '../../../diagnostic/presentation/widgets/bc_score_colors.dart';

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
    final scoreColor = widget.hasSession
        ? BcScoreColors.forScore(widget.bcScore)
        : context.textMuted;
    final challengePct =
        (widget.challengeProgress.clamp(0, 1) * 100).round();
    final targetProgress = clampBcsProgress(widget.bcScore);
    final showGlow = widget.hasSession && widget.bcScore > 80;

    return Card(
      elevation: context.isLightTheme ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        side: BorderSide(color: context.borderMuted),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: targetProgress),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  Widget ring = CircularProgressIndicator(
                    value: value,
                    strokeWidth: 10,
                    backgroundColor: context.surfaceMuted,
                    color: scoreColor,
                  );

                  if (showGlow && _glowController != null) {
                    ring = AnimatedBuilder(
                      animation: _glowController!,
                      builder: (context, child) {
                        final glow = 0.35 + 0.25 * _glowController!.value;
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: scoreColor.withValues(alpha: glow),
                                blurRadius: 18 + 8 * _glowController!.value,
                                spreadRadius: 2 * _glowController!.value,
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                      child: ring,
                    );
                  }

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      ring,
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.hasSession
                                ? '${widget.bcScore.round()}%'
                                : '—',
                            style: AppDesignConstants.cairo(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: scoreColor,
                            ),
                          ),
                          Text(
                            loc.bcScoreHeroLabel,
                            style: AppDesignConstants.cairo(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: context.textMuted,
                              letterSpacing: 0.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  );
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
                        ),
                  ),
                  const SizedBox(height: 12),
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: widget.challengeProgress.clamp(0, 1),
                    ),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 10,
                          backgroundColor: context.surfaceMuted,
                          color: AppTheme.success,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.homeChallengeProgressPercent(challengePct),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w700,
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
