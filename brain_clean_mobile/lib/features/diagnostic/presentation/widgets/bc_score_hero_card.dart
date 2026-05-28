import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/diagnostic_session.dart';
import 'bc_score_colors.dart';

/// Large BC_score card — score always from session pillar evaluation.
class BcScoreHeroCard extends StatelessWidget {
  const BcScoreHeroCard({
    super.key,
    required this.score,
    this.subtitle,
    this.fontSize = 56,
  });

  /// Binds hero display to [session.pillarEvaluation.bcScore].
  factory BcScoreHeroCard.fromSession({
    Key? key,
    required DiagnosticSession session,
    String? subtitle,
    double fontSize = 56,
  }) =>
      BcScoreHeroCard(
        key: key,
        score: session.pillarEvaluation.bcScore,
        subtitle: subtitle,
        fontSize: fontSize,
      );

  final double score;
  final String? subtitle;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      elevation: context.isLightTheme ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        side: BorderSide(color: context.borderMuted),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Text(
              loc.bcScoreHeroLabel,
              style: AppDesignConstants.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: context.textMuted,
                height: 1.2,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${score.round()}%',
              style: AppDesignConstants.cairo(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: BcScoreColors.forScore(score),
                height: 1,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: context.arabicLabelStyle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
