// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get dashboardTitle => 'لوحة Brain Clean';

  @override
  String get dashboardEmptyDiagnosticPrompt =>
      'أكمل التشخيص لعرض نقاط BC_score.';

  @override
  String get dashboardRetakeDiagnostic => 'إعادة التشخيص';

  @override
  String get dashboardOpenDetoxCheckIn => 'تسجيل بروتوكول الديتوكس (7 أيام)';

  @override
  String get dashboardOpenDetoxCheckInSubtitle =>
      'سجّل عاداتك اليومية وارفع نقاطك المباشرة';

  @override
  String dashboardCommittedAt(String date) {
    return 'تم التثبيت $date';
  }

  @override
  String get diagnosticTitle => 'اختبار التشخيص (6 نقاط)';

  @override
  String get diagnosticLiveSubtitle => 'مباشر · يتغير مع كل تعديل';

  @override
  String get diagnosticInstructions =>
      'قيّم كل بُعد من 1 (منخفض) إلى 10 (مرتفع).';

  @override
  String get diagnosticStart => 'ابدأ Brain Clean';

  @override
  String get diagnosticSleepQuality => 'جودة النوم';

  @override
  String get diagnosticSustainedAttention => 'الانتباه المستمر';

  @override
  String get diagnosticFragmentation => 'التشتت';

  @override
  String get diagnosticDopamineSeeking => 'البحث عن الدوبامين';

  @override
  String get diagnosticTaskSwitching => 'التنقل بين المهام';

  @override
  String get diagnosticBurnout => 'الإرهاق';

  @override
  String get bcScoreHeroLabel => 'نقاط صفاء الدماغ';

  @override
  String get bcScoreBreakdownTitle => 'تفصيل BHI · BC_score';

  @override
  String get bcScorePillarBrainPerformance => 'أداء الدماغ';

  @override
  String get bcScorePillarDigitalDiscipline => 'الانضباط الرقمي';

  @override
  String get bcScorePillarHealthyHabits => 'العادات الصحية';

  @override
  String get bcScorePillarConsistency => 'الاستمرارية';

  @override
  String get bcScoreLabel => 'BC_score';

  @override
  String get detoxTitle => 'بروتوكول الدوبامين (7 أيام)';

  @override
  String get detoxSubtitle => 'تسجيل يومي';

  @override
  String get detoxLiveBcScoreTitle => 'النقاط المباشرة';

  @override
  String get detoxLiveBcScoreSubtitle => 'تتغير فورًا عند تسجيل العادات';

  @override
  String get detoxBoredomTitle => 'مُصاحبة الملل';

  @override
  String get detoxBoredomSubtitle => 'جلست مع الملل بدون اللجوء للشاشة';

  @override
  String get detoxDelayedTitle => 'تأخير المكافأة';

  @override
  String detoxDelayedSubtitle(int max) {
    return 'الانتصارات اليوم (الحد الأقصى $max)';
  }

  @override
  String get detoxBodyTitle => 'تنشيط الجسد';

  @override
  String get detoxBodySubtitle => 'شمس الصباح + دش بارد';

  @override
  String detoxCount(int count) {
    return '$count';
  }

  @override
  String get detoxIncrement => 'زيادة';

  @override
  String get detoxDecrement => 'تقليل';

  @override
  String get detoxReset => 'إعادة ضبط اليوم';

  @override
  String get detoxRetry => 'إعادة المحاولة';

  @override
  String get detoxSyncing => 'جارٍ المزامنة…';

  @override
  String get detoxSyncError => 'تعذرت المزامنة. تم حفظ تسجيلك محليًا.';

  @override
  String get diagnosticBrainRotTitle => 'اختبار تعفن الدماغ';

  @override
  String get diagnosticBhiTitle => 'تقييم BHI (6 نقاط)';

  @override
  String get diagnosticYes => 'نعم';

  @override
  String get diagnosticNo => 'لا';

  @override
  String get diagnosticPreviousQuestion => 'السؤال السابق';

  @override
  String diagnosticBrainRotProgress(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String get diagnosticBrainRotScoreTitle => 'نتيجة تعفن الدماغ';

  @override
  String diagnosticBrainRotScoreOutOf(int max) {
    return 'من $max';
  }

  @override
  String diagnosticBrainRotBandRange(int min, int max) {
    return 'نطاق الشدة: $min–$max';
  }

  @override
  String get diagnosticBrainRotInterpretationTitle => 'التفسير السريري';

  @override
  String get diagnosticContinueToBhi => 'متابعة تقييم BHI';

  @override
  String get diagnosticReviewAnswers => 'مراجعة إجاباتي';

  @override
  String get diagnosticBrainRotIncomplete => 'أكمل الأسئلة العشرة أولاً.';

  @override
  String get diagnosticBrainRotScoring => 'جاري حساب نتيجة تعفن الدماغ…';

  @override
  String get diagnosticSyncError => 'تعذر حفظ التشخيص. حاول مرة أخرى.';

  @override
  String get diagnosticBrainRotQ1 =>
      'أشعر أن ذاكرتي قصيرة المدى ضعفت (أنسى ما قيل لي مؤخراً).';

  @override
  String get diagnosticBrainRotQ2 =>
      'أواجه صعوبة في التركيز على مهمة واحدة لفترة كافية.';

  @override
  String get diagnosticBrainRotQ3 =>
      'يبدو لي أن تفكيري بطيء مقارنة بما كنت عليه من قبل.';

  @override
  String get diagnosticBrainRotQ4 =>
      'أصاب بحالة \"تشويش ذهني\" أو أجد صعوبة في تنظيم أفكاري.';

  @override
  String get diagnosticBrainRotQ5 =>
      'أشعر بتعب ذهني بعد فترات قصيرة من التفكير أو العمل الذهني.';

  @override
  String get diagnosticBrainRotQ6 =>
      'أجد صعوبة في العثور على الكلمات المناسبة عند التحدث أو الكتابة.';

  @override
  String get diagnosticBrainRotQ7 =>
      'أشعر بأنني \"مشتت\" أو أن أفكاري تقفز من فكرة لأخرى بسرعة.';

  @override
  String get diagnosticBrainRotQ8 =>
      'يصبح من الصعب علي اتخاذ قرارات بسيطة أو التخطيط لمهام.';

  @override
  String get diagnosticBrainRotQ9 =>
      'أجد نفسي أعمل ببطء أكثر من المعتاد، أو أحتاج إلى وقت أطول لإنجاز نفس المهام.';

  @override
  String get diagnosticBrainRotQ10 =>
      'هذه الأعراض تؤثر على حياتي اليومية (في العمل أو الدراسة أو العلاقات).';

  @override
  String dashboardBrainRotSummary(int score) {
    return 'تعفن الدماغ: $score/10';
  }

  @override
  String get dashboardOpenRecoveryGrid => 'شبكة التعافي (30 يوماً)';

  @override
  String get dashboardOpenRecoveryGridSubtitle =>
      'خمس عادات يومية · صندوق العقابات عند التقصير';

  @override
  String get recoveryGridTitle => 'التعافي — 30 يوماً';

  @override
  String get recoveryGridSubtitle =>
      'اختر يوماً لتسجيل العادات الخمس الإلزامية.';

  @override
  String recoveryDayTasksTitle(int day) {
    return 'عادات اليوم $day';
  }

  @override
  String recoveryProgressSummary(int completed, int total) {
    return '$completed من $total يوماً مكتمل في البروتوكول';
  }

  @override
  String recoveryDayTasksProgress(int done, int total) {
    return '$done من $total عادات مسجّلة اليوم';
  }

  @override
  String get recoveryTaskSleepTitle => 'نوم منظم';

  @override
  String get recoveryTaskSleepSubtitle =>
      'نافذة نوم ثابتة وروتين استرخاء قبل النوم';

  @override
  String get recoveryTaskNutritionTitle => 'تغذية مضادة للالتهاب';

  @override
  String get recoveryTaskNutritionSubtitle =>
      'وجبات داعمة للدماغ دون محفزات التهاب';

  @override
  String get recoveryTaskMovementTitle => '20 دقيقة حركة';

  @override
  String get recoveryTaskMovementSubtitle =>
      'مشي أو تمدد أو نشاط خفيف لمدة 20 دقيقة على الأقل';

  @override
  String get recoveryTaskDistractionTitle => 'بروتوكول إدارة التشتت';

  @override
  String get recoveryTaskDistractionSubtitle =>
      'إكمال روتين حماية التركيز اليومي';

  @override
  String get recoveryTaskMentalTitle => 'دعم ذهني';

  @override
  String get recoveryTaskMentalSubtitle =>
      'تدوين أو تنفس موجّه أو جلسة دعم للتعافي';

  @override
  String get recoveryDayComplete => 'اكتملت العادات الخمس لهذا اليوم.';

  @override
  String get recoveryMissedHabitsTitle => 'تسجيل غير مكتمل';

  @override
  String get recoveryMissedHabitsSubtitle =>
      'فاتتك بعض العادات. افتح صندوق العقابات لتسجيل المساءلة.';

  @override
  String get recoveryOpenPenaltyBox => 'صندوق العقابات';

  @override
  String get recoveryDayEmptyHint => 'ضع علامة على كل عادة عند إنجازها اليوم.';

  @override
  String recoveryPenaltyCount(int count) {
    return 'عقوبات مسجّلة: $count';
  }

  @override
  String get recoveryPenaltyBoxTitle => 'صندوق العقابات';

  @override
  String recoveryPenaltyBoxMessage(int deduction) {
    return 'التأكيد يسجّل خصم −$deduction نقطة BC_score لمساءلة العادات الفائتة اليوم.';
  }

  @override
  String get recoveryPenaltyConfirm => 'تأكيد العقوبة';

  @override
  String get recoveryPenaltyCancel => 'إلغاء';

  @override
  String get recoveryPenaltyApplied => 'تم تسجيل العقوبة لهذا اليوم.';

  @override
  String get recoveryStorageLoadError =>
      'تعذّر تحميل تقدمك في التعافي من التخزين المحلي.';

  @override
  String get recoveryStorageSaveError =>
      'تعذّر حفظ آخر تحديث. تغييراتك ما زالت على الشاشة — حاول مرة أخرى.';

  @override
  String get recoveryStorageReset => 'بدء بروتوكول جديد';
}
