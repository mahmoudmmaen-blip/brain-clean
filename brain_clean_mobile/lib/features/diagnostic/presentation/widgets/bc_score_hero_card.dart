import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import 'bc_score_colors.dart';

/// Large BC_score display card used on diagnostic and dashboard screens.
class BcScoreHeroCard extends StatelessWidget {
  const BcScoreHeroCard({
    super.key,
    required this.score,
    this.subtitle,
    this.fontSize = 56,
  });

  final double score;
  final String? subtitle;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Text(
              loc.bcScoreHeroLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${score.round()}%',
              style: TextStyle(
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
