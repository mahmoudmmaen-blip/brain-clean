import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/diagnostic_model.dart';
import 'bhi_shimmer_cta_button.dart';
import 'brain_rot_animated_score_ring.dart';
import 'brain_rot_score_ring_colors.dart';

/// Brain Rot results — animated score ring, frosted severity card, shimmer CTA.
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
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final ringColor = BrainRotScoreRingColors.forScore(interpretation.score);
    final range = interpretation.band.scoreRange;
    final clinicalText = interpretation.interpretationAr;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Text(
                  loc.diagnosticBrainRotScoreTitle,
                  style: context.arabicLabelStyle,
                ),
                const SizedBox(height: 20),
                BrainRotAnimatedScoreRing(
                  score: interpretation.score,
                  maxScore: BrainRotTest.questionCount,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.diagnosticBrainRotScoreOutOf(BrainRotTest.questionCount),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.textSubtle,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _FrostedSeverityCard(
          label: interpretation.interpretationAr,
          bandRangeLabel: loc.diagnosticBrainRotBandRange(range.$1, range.$2),
          accentColor: ringColor,
          alignStart: isRtl,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: context.isLightTheme ? 1 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
            side: BorderSide(
              color: context.isLightTheme
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
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
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
        BhiShimmerCtaButton(
          label: loc.diagnosticContinueToBhi,
          onPressed: onContinue,
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

class _FrostedSeverityCard extends StatelessWidget {
  const _FrostedSeverityCard({
    required this.label,
    required this.bandRangeLabel,
    required this.accentColor,
    required this.alignStart,
  });

  final String label;
  final String bandRangeLabel;
  final Color accentColor;
  final bool alignStart;

  static const _frostedFill = Color(0xFF161B22);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _frostedFill.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            alignStart ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: alignStart ? TextAlign.right : TextAlign.left,
            style: AppDesignConstants.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: accentColor,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bandRangeLabel,
            textAlign: alignStart ? TextAlign.right : TextAlign.left,
            style: AppDesignConstants.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: accentColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
