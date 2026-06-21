/// أوزان محرك BCI (Brain Clarity Index) — المرحلة الثالثة.
abstract final class BciScoreConstants {
  /// وزن التقييم التشخيصي (BHI + تعفن الدماغ) في النتيجة النهائية.
  static const double assessmentWeight = 0.60;

  /// وزن الالتزام اليومي (متوسط BCS لآخر 7 أيام) في النتيجة النهائية.
  static const double adherenceWeight = 0.40;

  /// عدد أيام بروتوكول التعافي المستخدمة لحساب الالتزام.
  static const int adherenceWindowDays = 7;

  /// حصة BHI داخل [assessmentScore] (يجب أن يكون المجموع = 1.0).
  static const double bhiComponentWeight = 0.50;

  /// حصة اختبار تعفن الدماغ داخل [assessmentScore].
  static const double brainRotComponentWeight = 0.50;
}
