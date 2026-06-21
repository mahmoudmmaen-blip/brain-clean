import '../../../core/constants/bc_score_constants.dart';
import 'bc_score_result.dart';
import 'diagnostic_metrics.dart';

/// Pure domain engine — no Flutter / Riverpod dependencies.
abstract final class BcScoreEngine {
  static BcScoreResult calculate(DiagnosticMetrics metrics) {
    final positiveArm =
        (metrics.sleepQuality + metrics.sustainedAttention) *
        BcScoreConstants.positiveWeight;
    final negativeArm =
        (metrics.fragmentation +
                metrics.dopamineSeeking +
                metrics.taskSwitching +
                metrics.burnout) *
        BcScoreConstants.negativeWeight;

    final rawScore = positiveArm - negativeArm;
    final normalized =
        ((rawScore - BcScoreConstants.minRaw) / BcScoreConstants.rawSpan) *
        100.0;
    final bcScore = normalized.clamp(0.0, 100.0);

    return BcScoreResult(
      bcScore: bcScore,
      rawScore: rawScore,
      positiveArm: positiveArm,
      negativeArm: negativeArm,
      calculatedAt: DateTime.now(),
    );
  }
}
