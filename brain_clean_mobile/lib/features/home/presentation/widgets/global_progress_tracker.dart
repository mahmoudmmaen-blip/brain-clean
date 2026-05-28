import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../diagnostic/presentation/widgets/bc_score_colors.dart';

/// Premium dual-ring tracker: live BC_score + 30-day challenge completion.
class GlobalProgressTracker extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scoreColor = hasSession
        ? BcScoreColors.forScore(bcScore)
        : context.textMuted;
    final challengePct = (challengeProgress.clamp(0, 1) * 100).round();

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
                tween: Tween(begin: 0, end: bcScore.clamp(0, 100) / 100),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: value,
                        strokeWidth: 10,
                        backgroundColor: context.surfaceMuted,
                        color: scoreColor,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hasSession ? '${bcScore.round()}%' : '—',
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
                      end: challengeProgress.clamp(0, 1),
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
