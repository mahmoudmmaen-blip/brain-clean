import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/bhi_pillar_json_keys.dart';
import '../../domain/diagnostic_session.dart';
import '../../domain/pillar_bound_evaluation.dart';
import 'bc_score_colors.dart';
import 'bc_score_penalty_equation.dart';

/// Four-pillar BC_score breakdown — bound to [PillarBoundEvaluation] snapshot.
class BcScoreBreakdown extends StatelessWidget {
  const BcScoreBreakdown({
    super.key,
    required this.evaluation,
    required this.displayBcScore,
    this.pillarMatrixBcScore,
    this.recoveryPenaltyDeduction = 0,
  });

  /// Reads frozen pillars and bound score from [session] snapshot only.
  factory BcScoreBreakdown.fromSession({
    Key? key,
    required DiagnosticSession session,
  }) =>
      BcScoreBreakdown(
        key: key,
        evaluation: session.pillarEvaluation,
        displayBcScore: session.bcScore,
        pillarMatrixBcScore: session.pillarMatrixBcScore,
        recoveryPenaltyDeduction: session.recoveryPenaltyDeduction,
      );

  final PillarBoundEvaluation evaluation;
  final double displayBcScore;
  final double? pillarMatrixBcScore;
  final double recoveryPenaltyDeduction;

  double get _baseBhiScore =>
      pillarMatrixBcScore ?? evaluation.recomputedBcScore;

  bool get _hasPenalty => recoveryPenaltyDeduction > 0;

  static Map<String, String> _pillarLabels(AppLocalizations loc) => {
        BhiPillarJsonKeys.pillarRowBrainPerformance:
            loc.bcScorePillarBrainPerformance,
        BhiPillarJsonKeys.pillarRowDigitalDiscipline:
            loc.bcScorePillarDigitalDiscipline,
        BhiPillarJsonKeys.pillarRowHealthyHabits: loc.bcScorePillarHealthyHabits,
        BhiPillarJsonKeys.pillarRowConsistency: loc.bcScorePillarConsistency,
      };

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final labels = _pillarLabels(loc);
    final textDirection = Directionality.of(context);

    return Card(
      elevation: context.isLightTheme ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        side: BorderSide(color: context.borderMuted),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.bcScoreBreakdownTitle,
              textAlign: TextAlign.center,
              style: AppDesignConstants.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.textMuted,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            for (final row in evaluation.pillarRows)
              _PillarRow(
                label:
                    '${labels[row.key]!} (${(row.weight * 100).round()}%)',
                pillarScore: row.score,
                weight: row.weight,
                textDirection: textDirection,
              ),
            if (_hasPenalty) ...[
              const SizedBox(height: 12),
              BcScorePenaltyEquation(
                baseBhiScore: _baseBhiScore,
                penaltyDeduction: recoveryPenaltyDeduction,
                finalBcScore: displayBcScore,
              ),
            ],
            Divider(height: 20, color: context.borderMuted),
            _SummaryRow(
              label: _hasPenalty ? loc.finalBcScoreLabel : loc.bcScoreLabel,
              value: '${displayBcScore.round()}%',
              color: BcScoreColors.forScore(displayBcScore),
              textDirection: textDirection,
            ),
          ],
        ),
      ),
    );
  }
}

class _PillarRow extends StatelessWidget {
  const _PillarRow({
    required this.label,
    required this.pillarScore,
    required this.weight,
    required this.textDirection,
  });

  final String label;
  final double pillarScore;
  final double weight;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    final contribution = pillarScore * weight;
    final gold = context.diagnosticAccentGold;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: textDirection,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  textDirection: textDirection,
                  softWrap: true,
                  style: AppDesignConstants.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.textMuted,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${pillarScore.round()}% → +${contribution.toStringAsFixed(1)}',
                textDirection: textDirection,
                style: AppDesignConstants.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: gold,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              key: ValueKey<int>(pillarScore.round()),
              value: pillarScore / 100,
              minHeight: 4,
              backgroundColor: context.diagnosticProgressTrack,
              color: gold.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    required this.textDirection,
  });

  final String label;
  final String value;
  final Color color;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        textDirection: textDirection,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              textDirection: textDirection,
              softWrap: true,
              style: AppDesignConstants.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.textMuted,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            textDirection: textDirection,
            style: AppDesignConstants.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
