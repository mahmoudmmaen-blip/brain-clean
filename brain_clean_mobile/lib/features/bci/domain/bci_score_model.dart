/// نموذج بيانات مؤشر وضوح الدماغ BCI (0–100).
///
/// يجمع بين:
/// - [assessmentScore]: نتيجة التشخيص الأسبوعي (BHI + تعفن الدماغ) — وزن 60%.
/// - [adherenceScore]: متوسط [RecoveryDayRecord.dailyBcsScore] لآخر 7 أيام — وزن 40%.
class BciScoreModel {
  const BciScoreModel({
    required this.assessmentScore,
    required this.adherenceScore,
    required this.totalScore,
    required this.bhiComponentScore,
    required this.brainRotClarityScore,
    required this.adherenceDaysSampled,
    required this.hasCommittedAssessment,
    required this.calculatedAt,
  });

  /// درجة التقييم التشخيصي (0–100) — تُوزَّن بنسبة 60% في [totalScore].
  final double assessmentScore;

  /// درجة الالتزام اليومي (0–100) — تُوزَّن بنسبة 40% في [totalScore].
  final double adherenceScore;

  /// النتيجة النهائية BCI = (assessment × 0.60) + (adherence × 0.40).
  final double totalScore;

  /// مكوّن BHI الخام قبل الدمج (0–100).
  final double bhiComponentScore;

  /// مكوّن تعفن الدماغ بعد العكس — 0 أعراض = 100 وضوح (0–100).
  final double brainRotClarityScore;

  /// عدد أيام البروتوكول التي دخلت في حساب [adherenceScore].
  final int adherenceDaysSampled;

  /// `false` عندما لا يوجد تشخيص محفوظ بعد — يُظهر واجهة المستخدم دعوة للتقييم.
  final bool hasCommittedAssessment;

  final DateTime calculatedAt;

  int get totalScoreRounded => totalScore.round();

  int get assessmentScoreRounded => assessmentScore.round();

  int get adherenceScoreRounded => adherenceScore.round();

  /// نسبة التقدم للشريط الدائري (0.0–1.0).
  double get progressRatio => (totalScore / 100.0).clamp(0.0, 1.0);

  /// حالة فارغة قبل إتمام أي تشخيص.
  static BciScoreModel empty({DateTime? at}) => BciScoreModel(
        assessmentScore: 0,
        adherenceScore: 0,
        totalScore: 0,
        bhiComponentScore: 0,
        brainRotClarityScore: 0,
        adherenceDaysSampled: 0,
        hasCommittedAssessment: false,
        calculatedAt: at ?? DateTime.now(),
      );
}
