import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/diagnostic_model.dart';
import 'brain_rot_colors.dart';

/// Brain Rot results — optimized for brand green light/dark themes.
class BrainRotScoreDashboard extends StatelessWidget {
  const BrainRotScoreDashboard({
    super.key,
    required this.interpretation,
    required this.onContinue,
    this.onReviewAnswers,
  });

  final BrainRotInterpretation interpretation;
  final VoidCallback onContinue;
  final VoidCallback? onReviewAnswers;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = context.isLightTheme;
    final bandColor = BrainRotColors.forBand(interpretation.band);
    final range = interpretation.band.scoreRange;
    final clinicalText = interpretation.interpretationAr;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          elevation: isLight ? 2 : 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppDesignConstants.radiusCard),
              border: Border.all(
                color: bandColor.withValues(alpha: isLight ? 0.45 : 0.55),
                width: isLight ? 1.5 : 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bandColor.withValues(alpha: isLight ? 0.1 : 0.2),
                  theme.cardTheme.color ?? theme.colorScheme.surface,
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Column(
              children: [
                Icon(Icons.psychology_alt_outlined, color: bandColor, size: 40),
                const SizedBox(height: 12),
                Text(
                  loc.diagnosticBrainRotScoreTitle,
                  style: context.arabicLabelStyle,
                ),
                const SizedBox(height: 12),
                Text(
                  '${interpretation.score}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: bandColor,
                    height: 1,
                  ),
                ),
                Text(
                  loc.diagnosticBrainRotScoreOutOf(BrainRotTest.questionCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.textSubtle,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: bandColor.withValues(alpha: isLight ? 0.12 : 0.18),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: bandColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    loc.diagnosticBrainRotBandRange(range.$1, range.$2),
                    style: AppDesignConstants.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: bandColor,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: isLight ? 1 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
            side: BorderSide(
              color: isLight
                  ? AppDesignConstants.lightBorder
                  : AppDesignConstants.darkBorder,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.diagnosticBrainRotInterpretationTitle,
                  style: AppDesignConstants.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.brandPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  clinicalText,
                  style: context.arabicBodyStyle.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(
              AppDesignConstants.minTouchTarget + 4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppDesignConstants.radiusButton,
              ),
            ),
          ),
          onPressed: onContinue,
          child: Text(loc.diagnosticContinueToBhi),
        ),
        if (onReviewAnswers != null) ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: onReviewAnswers,
            child: Text(loc.diagnosticReviewAnswers),
          ),
        ],
      ],
    );
  }
}
