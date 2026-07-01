import '../../../core/constants/bci_score_constants.dart';
import '../../diagnostic/domain/diagnostic_model.dart';
import '../../diagnostic/domain/diagnostic_session.dart';
import 'bci_adherence_snapshot.dart';
import 'bci_score_model.dart';

/// محرك domain خالص — يدمج التقييم الأسبوعي (60%) مع الالتزام اليومي (40%).
abstract final class BciScoreEngine {
  BciScoreEngine._();

  /// يحسب [BciScoreModel] من جلسة التشخيص المحفوظة ولقطة الالتزام.
  static BciScoreModel calculate({
    DiagnosticSession? session,
    BciAdherenceSnapshot adherence = BciAdherenceSnapshot.empty,
    DateTime? calculatedAt,
  }) {
    final now = calculatedAt ?? DateTime.now();
    final adherenceScore = adherence.adherenceScore;

    if (session == null || !session.isCommitted) {
      return BciScoreModel(
        assessmentScore: 0,
        adherenceScore: adherenceScore,
        totalScore: adherenceScore * BciScoreConstants.adherenceWeight,
        bhiComponentScore: 0,
        brainRotClarityScore: 0,
        adherenceDaysSampled: adherence.daysSampled,
        hasCommittedAssessment: false,
        calculatedAt: now,
      );
    }

    final bhiScore = session.bcScore.clamp(0.0, 100.0);
    final brainRotClarity = _brainRotToClarity(session.brainRotScore);
    final assessmentScore = _computeAssessmentScore(
      bhiScore: bhiScore,
      brainRotClarity: brainRotClarity,
    );

    final totalScore = (assessmentScore * BciScoreConstants.assessmentWeight) +
        (adherenceScore * BciScoreConstants.adherenceWeight);

    return BciScoreModel(
      assessmentScore: assessmentScore,
      adherenceScore: adherenceScore,
      totalScore: totalScore.clamp(0.0, 100.0),
      bhiComponentScore: bhiScore,
      brainRotClarityScore: brainRotClarity,
      adherenceDaysSampled: adherence.daysSampled,
      hasCommittedAssessment: true,
      calculatedAt: now,
    );
  }

  /// نتيجة التشخيص الأسبوعي = BHI (50%) + وضوح تعفن الدماغ (50%).
  static double _computeAssessmentScore({
    required double bhiScore,
    required double brainRotClarity,
  }) {
    final blended = (bhiScore * BciScoreConstants.bhiComponentWeight) +
        (brainRotClarity * BciScoreConstants.brainRotComponentWeight);
    return blended.clamp(0.0, 100.0);
  }

  /// يحوّل درجة الأعراض (0–10، أعلى = أسوأ) إلى وضوح (0–100، أعلى = أفضل).
  static double _brainRotToClarity(int? brainRotScore) {
    if (brainRotScore == null) return 0;
    final clamped = brainRotScore.clamp(0, BrainRotTest.questionCount);
    return ((BrainRotTest.questionCount - clamped) /
            BrainRotTest.questionCount) *
        100.0;
  }
}
