import 'package:freezed_annotation/freezed_annotation.dart';

part 'bc_score_result.freezed.dart';

/// Output of the real-time BC_score calculation engine.
@freezed
class BcScoreResult with _$BcScoreResult {
  const factory BcScoreResult({
    /// Normalized Brain Clarity / Focus score \[0, 100\].
    required double bcScore,
    required double rawScore,
    /// (S1 + A2) × 1.5
    required double positiveArm,
    /// (F3 + D4 + T5 + B6) × 0.8
    required double negativeArm,
    required DateTime calculatedAt,
  }) = _BcScoreResult;

  const BcScoreResult._();

  int get bcScoreRounded => bcScore.round();
}
