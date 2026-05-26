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
  String get detoxSyncing => 'جارٍ المزامنة…';

  @override
  String get detoxSyncError => 'تعذرت المزامنة. تم حفظ تسجيلك محليًا.';
}
