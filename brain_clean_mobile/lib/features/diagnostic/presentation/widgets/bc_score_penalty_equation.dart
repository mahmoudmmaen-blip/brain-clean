import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import 'bc_score_colors.dart';

/// RTL-safe accountability strip: Base BHI − penalty = final BC_score.
class BcScorePenaltyEquation extends StatelessWidget {
  const BcScorePenaltyEquation({
    super.key,
    required this.baseBhiScore,
    required this.penaltyDeduction,
    required this.finalBcScore,
  });

  final double baseBhiScore;
  final double penaltyDeduction;
  final double finalBcScore;

  @override
  Widget build(BuildContext context) {
    if (penaltyDeduction <= 0) return const SizedBox.shrink();

    final loc = AppLocalizations.of(context)!;
    final severity = Theme.of(context).colorScheme.error;
    final baseColor = context.diagnosticAccentGold;
    final finalColor = BcScoreColors.forScore(finalBcScore);
    final muted = context.textMuted;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: severity.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard - 4),
        border: Border.all(color: severity.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.bcScorePenaltyEquationTitle,
            textAlign: TextAlign.center,
            style: AppDesignConstants.cairo(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: severity.withValues(alpha: 0.9),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          _EquationRow(
            label: loc.bcScoreBaseBhiLabel,
            value: '${baseBhiScore.round()}%',
            valueColor: baseColor,
            muted: muted,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Icon(Icons.remove, size: 14, color: severity),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    loc.bcScoreRecoveryPenaltyAdjustment(
                      penaltyDeduction.round(),
                    ),
                    textAlign: TextAlign.center,
                    style: AppDesignConstants.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: severity,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 12, color: severity.withValues(alpha: 0.25)),
          _EquationRow(
            label: loc.bcScoreFinalBcScoreLabel,
            value: '${finalBcScore.round()}%',
            valueColor: finalColor,
            muted: muted,
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _EquationRow extends StatelessWidget {
  const _EquationRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.muted,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final Color muted;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppDesignConstants.cairo(
              fontSize: emphasize ? 12 : 11,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              color: muted,
              height: 1.35,
            ),
          ),
        ),
        Text(
          value,
          style: AppDesignConstants.cairo(
            fontSize: emphasize ? 16 : 14,
            fontWeight: FontWeight.w800,
            color: valueColor,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
