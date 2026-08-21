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
  String get accountabilityAdjustment => 'بند المساءلة السريرية';

  @override
  String get bhiScoreLabel => 'مؤشر BHI الأساسي';

  @override
  String get finalBcScoreLabel => 'BC_score بعد المساءلة';

  @override
  String accountabilityDeduction(int deduction) {
    return 'خصم مساءلة التعافي (−$deduction)';
  }

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
      'خمس عادات يومية · غرفة المسؤولية عند التقصير';

  @override
  String get splashTitle => 'Brain Clean';

  @override
  String get splashHydrationRetry => 'جارٍ استعادة تقدمك…';

  @override
  String get homeTitle => 'الرئيسية — Brain Clean';

  @override
  String get homeEmptyDiagnosticPrompt =>
      'أكمل التشخيص لتفعيل متتبع BC_score المباشر.';

  @override
  String get homeChallengeProgressTitle => 'تحدي التعافي — 30 يوماً';

  @override
  String homeChallengeProgressPercent(int percent) {
    return '$percent% مكتمل';
  }

  @override
  String get homeOpenDiagnostic => 'التشخيص السريري';

  @override
  String get homeOpenDiagnosticSubtitle => 'استبيان تعفن الدماغ + مقاييس BHI';

  @override
  String get homeOpenCognitiveHub => 'التقييمات المعرفية';

  @override
  String get homeOpenCognitiveHubSubtitle => 'اختبار بصري وألعاب ذاكرة قصيرة';

  @override
  String get homeOpenFullDashboard => 'لوحة التحكم الكاملة';

  @override
  String get cognitiveHubTitle => 'التقييمات المعرفية';

  @override
  String get cognitiveHubSubtitle =>
      'وحدات تفاعلية تُحسّن عمود الأداء الدماغي في BHI.';

  @override
  String get cognitiveVisualTestTitle => 'اختبار الإدراك البصري';

  @override
  String get cognitiveVisualTestSubtitle =>
      'اعثر على الشكل أو اللون المختلف ضمن شبكة زمنية';

  @override
  String get cognitiveMemoryGameTitle => 'ألعاب الذاكرة';

  @override
  String get cognitiveMemoryGameSubtitle =>
      'استرجع تسلسلات ألوان متزايدة على شبكة 3×3';

  @override
  String get cognitiveStartButton => 'ابدأ الاختبار';

  @override
  String get cognitiveDoneButton => 'حفظ وإغلاق';

  @override
  String get cognitiveMemoryInstructions =>
      'راقب الخلايا المضيئة ثم اضغطها بنفس الترتيب. يزداد الطول كل جولة.';

  @override
  String get cognitiveMemoryWatch => 'راقب التسلسل…';

  @override
  String get cognitiveMemoryYourTurn => 'دورك — اضغط الخلايا بالترتيب';

  @override
  String cognitiveMemoryRound(int length) {
    return 'طول التسلسل: $length';
  }

  @override
  String get cognitiveMemoryWrong => 'خطأ — انتهى الاختبار.';

  @override
  String get cognitiveMemoryResultTitle => 'اكتمل اختبار الذاكرة';

  @override
  String cognitiveMemoryResultScore(int span, int score) {
    return 'أطول تسلسل: $span · النتيجة: $score%';
  }

  @override
  String get cognitiveVisualInstructions =>
      'اضغط الخلية التي تبدو مختلفة. لديك ثوانٍ محدودة في كل جولة.';

  @override
  String get cognitiveVisualFindOdd => 'اعثر على المختلف';

  @override
  String cognitiveVisualRound(int current, int total) {
    return 'الجولة $current من $total';
  }

  @override
  String get cognitiveVisualCorrect => 'صحيح!';

  @override
  String get cognitiveVisualWrong => 'خطأ';

  @override
  String get cognitiveVisualTimeout => 'بطيء جداً';

  @override
  String get cognitiveVisualResultTitle => 'اكتمل اختبار الانتباه البصري';

  @override
  String cognitiveVisualResultScore(int points, int maxPoints, int score) {
    return '$points / $maxPoints نقطة · النتيجة: $score%';
  }

  @override
  String get cognitivePlaceholderBody =>
      'هذه الوحدة مُهيّأة لمحرك تقييم BHI الموحّد. أكمل التشغيل التجريبي للتحقق من المسار.';

  @override
  String get cognitivePlaceholderComplete => 'تسجيل نتيجة تجريبية';

  @override
  String cognitivePlaceholderRecorded(int score) {
    return 'تم تسجيل نتيجة تجريبية: $score%';
  }

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
  String get recoveryTaskDistractionTitle => 'بروتوكول التشتت المؤقت';

  @override
  String get recoveryTaskDistractionSubtitle =>
      'إكمال روتين حماية التركيز اليومي';

  @override
  String get recoveryTaskMentalTitle => 'دعم ذهني';

  @override
  String get recoveryTaskMentalSubtitle => 'تدوين أو جلسة دعم موجّهة للتعافي';

  @override
  String get recoveryDayComplete => 'اكتملت العادات الخمس لهذا اليوم.';

  @override
  String get recoveryMissedHabitsTitle => 'تسجيل غير مكتمل';

  @override
  String get recoveryMissedHabitsSubtitle =>
      'فاتتك بعض العادات. افتح غرفة المسؤولية لتسجيل المساءلة.';

  @override
  String get recoveryOpenPenaltyBox => 'غرفة المسؤولية';

  @override
  String get recoveryDayEmptyHint => 'ضع علامة على كل عادة عند إنجازها اليوم.';

  @override
  String recoveryPenaltyCount(int count) {
    return 'سجلات مساءلة: $count';
  }

  @override
  String get recoveryPenaltyBoxTitle => 'غرفة المسؤولية';

  @override
  String recoveryPenaltyBoxMessage(int deduction) {
    return 'التأكيد يسجّل خصم −$deduction نقطة BC_score لمساءلة العادات الفائتة اليوم.';
  }

  @override
  String get recoveryPenaltyConfirm => 'تأكيد المساءلة';

  @override
  String get recoveryPenaltyCancel => 'إلغاء';

  @override
  String get recoveryPenaltyApplied => 'تم تسجيل المساءلة لهذا اليوم.';

  @override
  String get recoveryStorageLoadError =>
      'تعذّر تحميل تقدمك في التعافي من التخزين المحلي.';

  @override
  String get recoveryStorageSaveError =>
      'تعذّر حفظ آخر تحديث. تغييراتك ما زالت على الشاشة — حاول مرة أخرى.';

  @override
  String get recoveryStorageReset => 'بدء بروتوكول جديد';

  @override
  String get recoveryStorageMigratedNotice =>
      'تم ترقية تقدمك المحفوظ إلى التنسيق الأحدث.';

  @override
  String get recoveryStorageRecoveredNotice =>
      'تم إعادة ضبط البيانات المحلية لأنها لم تُقرأ بشكل صحيح. بدأ بروتوكول جديد.';

  @override
  String get homeFocusJourneyTitle => 'رحلة التركيز';

  @override
  String get homeStreakDays => 'أيام';

  @override
  String get homeStreakHours => 'ساعات';

  @override
  String get homeStreakMinutes => 'دقائق';

  @override
  String get homeStreakSeconds => 'ثوانٍ';

  @override
  String get homeDistractionButton => 'التشتت المؤقت';

  @override
  String get homeDistractionConfirmTitle => 'تأكيد التشتت المؤقت';

  @override
  String get homeDistractionConfirmMessage =>
      'هل أنت متأكد؟ سيتم خصم 12 ساعة من رحلة التركيز.';

  @override
  String get homeDistractionConfirm => 'تأكيد';

  @override
  String get homeDistractionCancel => 'إلغاء';

  @override
  String get homeOpenAccountability => 'غرفة المساءلة الرقمية';

  @override
  String get accountabilityRoomTitle => 'غرفة المساءلة الرقمية';

  @override
  String get accountabilityPenaltyRecorded => 'تم تسجيل المساءلة ✓';

  @override
  String get accountabilityCatPhysical => 'جسدية';

  @override
  String get accountabilityCatNutritional => 'غذائية';

  @override
  String get accountabilityCatAltruistic => 'إيثارية';

  @override
  String get accountabilityCatMental => 'ذهنية';

  @override
  String get accountabilityPenPhysical1 => 'تخطي جلسة الحركة';

  @override
  String get accountabilityPenPhysical2 => 'إهمال نظافة النوم';

  @override
  String get accountabilityPenPhysical3 => 'عودة للخمول';

  @override
  String get accountabilityPenPhysical4 => 'تفويت مشي التعافي';

  @override
  String get accountabilityPenPhysical5 => 'تخطي تفعيل الجسم';

  @override
  String get accountabilityPenNutritional1 => 'وجبة ملتهبة';

  @override
  String get accountabilityPenNutritional2 => 'تخطي وجبة دعم الدماغ';

  @override
  String get accountabilityPenNutritional3 => 'إفراط في السكر';

  @override
  String get accountabilityPenNutritional4 => 'إهمال الترطيب';

  @override
  String get accountabilityPenNutritional5 => 'أكل متأخر ليلاً';

  @override
  String get accountabilityPenAltruistic1 => 'تفويت عمل لطيف';

  @override
  String get accountabilityPenAltruistic2 => 'انطواء اجتماعي';

  @override
  String get accountabilityPenAltruistic3 => 'تجاهل طلب دعم';

  @override
  String get accountabilityPenAltruistic4 => 'تركيز ذاتي مفرط';

  @override
  String get accountabilityPenAltruistic5 => 'تخطي متابعة المجتمع';

  @override
  String get accountabilityPenMental1 => 'تخطي كتلة التعافي الذهني';

  @override
  String get accountabilityPenMental2 => 'تجنب التدوين';

  @override
  String get accountabilityPenMental3 => 'حلقة أفكار سلبية';

  @override
  String get accountabilityPenMental4 => 'تفويت فحص ذهني';

  @override
  String get accountabilityPenMental5 => 'إدمان شاشة متصاعد';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonOk => 'حسناً';

  @override
  String get commonGreat => 'رائع';

  @override
  String get commonBack => 'رجوع';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingPage1Title => 'مرحباً بك في Brain Clean';

  @override
  String get onboardingPage1Body => 'استعد وعيك الرقمي في 21 يوماً';

  @override
  String get onboardingPage2Title => 'تتبع تركيزك يومياً';

  @override
  String get onboardingPage2Body => 'معادلات علمية حقيقية لقياس صحة دماغك';

  @override
  String get onboardingPage3Title => 'ابدأ رحلتك الآن';

  @override
  String get onboardingPage3Body => 'أجب على 10 أسئلة لتحديد مستوى تعفن دماغك';

  @override
  String get onboardingStartQuiz => 'ابدأ التقييم';

  @override
  String get proPaywallTitle => 'Brain Clean Pro';

  @override
  String get proPaywallSubtitle => 'افتح كامل قدرات عقلك';

  @override
  String get proFeatureAdvancedBcs => 'محرك Brain Clarity Score المتقدم';

  @override
  String get proFeatureSevenDayChart => 'مخطط التقدم 7 أيام';

  @override
  String get proFeatureEmotionWheel => 'دائرة الأحاسيس والتأثير على التعافي';

  @override
  String get proFeatureFocusChallenges => 'تحديات التركيز المتقدمة';

  @override
  String get proFeatureCloudSync => 'مزامنة سحابية آمنة';

  @override
  String get proFeatureColorThemes => '4 ثيمات ألوان حصرية لـ Pro';

  @override
  String get proWelcomeSnack => 'مرحباً بك في Pro! 🎉';

  @override
  String get proPriceMonthly => '19 ريال سعودي / شهرياً';

  @override
  String get proPriceHint => 'أقل من وجبة واحدة';

  @override
  String get proSubscribeNow => 'اشترك الآن';

  @override
  String get proRestorePurchase => 'استعادة الاشتراك';

  @override
  String get proBadgeLabel => 'Pro';

  @override
  String get proPlanMonthly => 'شهري';

  @override
  String get proPlanAnnual => 'سنوي';

  @override
  String get proPlanLifetime => 'مدى الحياة';

  @override
  String get proBestValueBadge => 'الأفضل قيمة';

  @override
  String get proAlreadyProTitle => 'أنت بالفعل مشترك في Pro';

  @override
  String get proAlreadyProBody => 'تمتع بوصول غير محدود لجميع ميزات Pro.';

  @override
  String get proRestoreSuccess => 'تمت استعادة المشتريات بنجاح';

  @override
  String get proRestoreNone => 'لم يتم العثور على مشتريات سابقة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAccountSection => 'الحساب';

  @override
  String get settingsProActive => 'Brain Clean Pro ✓';

  @override
  String get settingsUpgradeToPro => 'ترقية إلى Pro';

  @override
  String get settingsAppearanceSection => 'المظهر';

  @override
  String get colorThemeMidnightName => 'منتصف الليل';

  @override
  String get colorThemeAuroraName => 'الشفق';

  @override
  String get colorThemePineName => 'الصنوبر';

  @override
  String get colorThemeSolarName => 'شمسي';

  @override
  String get colorThemeSlateName => 'إردوازي';

  @override
  String get colorThemeDaylightName => 'ضوء النهار';

  @override
  String get settingsNotificationsSection => 'الإشعارات';

  @override
  String get settingsEmotionNotifications => 'تنبيهات الأحاسيس السلبية';

  @override
  String get settingsDailyFocusReminder => 'تذكير يومي بالتركيز';

  @override
  String get settingsDataSection => 'البيانات';

  @override
  String get settingsResetData => 'إعادة تعيين البيانات';

  @override
  String get settingsResetDataConfirmTitle => 'إعادة تعيين البيانات';

  @override
  String get settingsResetDataConfirmBody =>
      'سيتم حذف جميع بياناتك المحلية. هل أنت متأكد؟';

  @override
  String get settingsExportData => 'تصدير بياناتي';

  @override
  String get settingsComingSoon => 'قريباً...';

  @override
  String get settingsLinkUnavailable => 'تعذّر فتح هذا الرابط على هذا الجهاز.';

  @override
  String get settingsAboutSection => 'حول التطبيق';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsContactUs => 'تواصل معنا';

  @override
  String get emotionWheelTitle => 'عجلة المشاعر';

  @override
  String get emotionImpactDialogTitle => 'تأثير هذا الشعور على تعافيك';

  @override
  String emotionImpactNegative(String emotion, String pct) {
    return 'الشعور بـ $emotion سيقلل نسبة تعافيك بمقدار $pct%\nهل تريد تسجيله؟';
  }

  @override
  String emotionImpactPositive(String emotion, String pct) {
    return 'الشعور بـ $emotion سيحسّن نسبة تعافيك بمقدار $pct%\nهل تريد تسجيله؟';
  }

  @override
  String get emotionIgnore => 'لا، تجاهل';

  @override
  String get emotionConfirmLog => 'نعم، سجّل';

  @override
  String get emotionGateNegative => 'أشعر بشيء سلبي';

  @override
  String get emotionGateNeutral => 'أشعر بشيء محايد';

  @override
  String get emotionGatePositive => 'أشعر بشيء إيجابي';

  @override
  String get silenceChallengeTitle => 'تحدي الصمت';

  @override
  String silenceChallengeSubtitle(int minutes) {
    return 'لا تلمس الشاشة لمدة $minutes دقيقة';
  }

  @override
  String silenceChallengeLevel(int level, int minutes) {
    return 'المستوى $level — $minutes دقيقة مطلوبة';
  }

  @override
  String get silenceChallengeFailedTitle => 'فشل التحدي';

  @override
  String get silenceChallengeFailedBody => 'لمست الشاشة أو خرجت من التطبيق.';

  @override
  String get silenceChallengeSuccessTitle => 'أحسنت! 🎉';

  @override
  String get silenceChallengeSuccessBody => 'اجتزت تحدي الصمت بنجاح.';

  @override
  String get singleTaskPauseTitle => 'إيقاف مؤقت';

  @override
  String get singleTaskPauseBody =>
      'هل تريد إيقاف المهمة الحالية؟ لن تحصل على مكافأة.';

  @override
  String get singleTaskModeTitle => 'وضع المهمة الواحدة';

  @override
  String get singleTaskFocusRewardSnack => 'أحسنت! +10 نقاط تركيز';

  @override
  String get singleTaskHint => 'اكتب مهمتك الآن...';

  @override
  String get singleTaskStartFocus => 'ابدأ التركيز';

  @override
  String get singleTaskFocusing => 'جارٍ التركيز...';

  @override
  String get singleTaskCompleted => 'أنهيت المهمة ✓';

  @override
  String get singleTaskPauseButton => 'إيقاف مؤقت';

  @override
  String get delayedGratTitle => 'تأخير الإشباع';

  @override
  String get delayedGratSubtitle => 'اصمد 20 دقيقة قبل فتح السوشيال ميديا';

  @override
  String get delayedGratQuoteUnder5 => 'الصبر مفتاح الفرج';

  @override
  String get delayedGratQuoteUnder10 => 'دماغك يشكرك الآن';

  @override
  String get delayedGratQuoteUnder15 => 'أنت أقوى من خوارزمية';

  @override
  String get delayedGratQuoteDefault => 'لحظات وتنتهي، استمر';

  @override
  String get delayedGratGiveUpTitle => 'الاستسلام';

  @override
  String get delayedGratGiveUpBody =>
      'هل تريد الاستسلام؟ لن تحصل على المكافأة.';

  @override
  String get delayedGratGiveUpButton => 'استسلام';

  @override
  String get delayedGratVictoryTitle => 'انتصرت على نفسك! 🏆';

  @override
  String get delayedGratVictoryBody => '+25 نقطة أضيفت لتركيزك.';

  @override
  String get chartSevenDayTitle => 'تقدمك خلال 7 أيام';

  @override
  String get chartDaySat => 'السبت';

  @override
  String get chartDaySun => 'الأحد';

  @override
  String get chartDayMon => 'الاثنين';

  @override
  String get chartDayTue => 'الثلاثاء';

  @override
  String get chartDayWed => 'الأربعاء';

  @override
  String get chartDayThu => 'الخميس';

  @override
  String get chartDayFri => 'الجمعة';

  @override
  String get proGatedChartTitle => 'مخطط التقدم 7 أيام';

  @override
  String get proGatedChartSubtitle => 'متاح في Brain Clean Pro';

  @override
  String get visualCognitiveBack => 'العودة';

  @override
  String visualCognitiveRound(int round) {
    return 'الجولة $round / 5';
  }

  @override
  String get visualCognitiveInstruction => 'اضغط على المربع مختلف اللون';

  @override
  String visualCognitiveScore(int score) {
    return 'النقاط: $score';
  }

  @override
  String get diagnosticCognitiveTestButton => 'اختبر تركيزك 🎯';

  @override
  String get homeQuickEmotion => 'كيف تشعر؟ 💭';

  @override
  String get homeQuickSilence => 'تحدي الصمت 🔇';

  @override
  String get homeQuickSingleTask => 'مهمة واحدة 🎯';

  @override
  String get homeQuickDelayedGrat => 'تأخير الإشباع ⏳';

  @override
  String get homeQuickCognitiveTest => 'اختبر تركيزك 🧪';

  @override
  String get homeAccountabilityBox => 'صندوق المساءلة';

  @override
  String get homeDistractionConfirmAction => 'تأكيد التشتت المؤقت';

  @override
  String get splashSubtitle => 'أعد ضبط دماغك';

  @override
  String get profileDefaultName => 'مستخدم Brain Clean';

  @override
  String get profileProBadge => 'Pro ⭐';

  @override
  String get profileStatFocusDays => 'يوم تركيز';

  @override
  String get profileStatBcs => 'BCS';

  @override
  String get profileStatEmotions => 'إحساس';

  @override
  String get profileRecentEmotions => 'أحاسيسك الأخيرة';

  @override
  String get profileNoEmotionsYet => 'لم تسجل أي أحاسيس بعد';

  @override
  String get profileAchievements => 'إنجازاتك';

  @override
  String get profileBadgeStreak7 => 'رحلة تركيز لمدة 7 أيام';

  @override
  String get profileBadgeCleanBrain => 'دماغ نظيف';

  @override
  String get profileBadgeSilenceHero => 'بطل الصمت';

  @override
  String get profileBadgeSingleTask => 'مهمة واحدة';

  @override
  String get profileBadgeEmotionAwake => 'صاحي المشاعر';

  @override
  String get profileBadgeProMember => 'Pro Member';

  @override
  String get accountabilityModalCatPhysical => 'اللياقة البدنية';

  @override
  String get accountabilityModalCatNutritional => 'التغذية الصحية';

  @override
  String get accountabilityModalCatAltruistic => 'أعمال اجتماعية';

  @override
  String get accountabilityModalCatMental => 'التحدي الذهني';

  @override
  String get accountabilityModalPenPhysical1 => 'تمرين 30 دقيقة';

  @override
  String get accountabilityModalPenPhysical2 => 'تمارين قوة';

  @override
  String get accountabilityModalPenPhysical3 => 'مشي 5000 خطوة';

  @override
  String get accountabilityModalPenPhysical4 => 'تمدد صباحي';

  @override
  String get accountabilityModalPenPhysical5 => 'نشاط خارجي';

  @override
  String get accountabilityModalPenNutritional1 => 'تجنب السكر';

  @override
  String get accountabilityModalPenNutritional2 => 'وجبة متوازنة';

  @override
  String get accountabilityModalPenNutritional3 => 'شرب 2 لتر ماء';

  @override
  String get accountabilityModalPenNutritional4 => 'تقليل الكافيين';

  @override
  String get accountabilityModalPenNutritional5 => 'وجبة بروtein';

  @override
  String get accountabilityModalPenAltruistic1 => 'مساعدة جار';

  @override
  String get accountabilityModalPenAltruistic2 => 'تبرع صغير';

  @override
  String get accountabilityModalPenAltruistic3 => 'رسالة شكر';

  @override
  String get accountabilityModalPenAltruistic4 => 'خدمة مجتمعية';

  @override
  String get accountabilityModalPenAltruistic5 => 'دعم صديق';

  @override
  String get accountabilityModalPenMental1 => 'قراءة 20 دقيقة';

  @override
  String get accountabilityModalPenMental2 => 'حل لغز';

  @override
  String get accountabilityModalPenMental3 => 'تعلم كلمة جديدة';

  @override
  String get accountabilityModalPenMental4 => 'تأمل موجّه';

  @override
  String get accountabilityModalPenMental5 => 'كتابة يوميات';

  @override
  String get asyncErrorRetry => 'حدث خطأ، حاول مجدداً';

  @override
  String get chartEmptyState => 'لا توجد بيانات بعد، ابدأ رحلتك اليوم';

  @override
  String get homeStreakMotivation => 'ابدأ رحلة التركيز الآن 🚀';

  @override
  String get dailyQuoteSource => 'علم الأعصاب';

  @override
  String get focusJourneyFreezeTitle => 'تجميد رحلة التركيز ❄️';

  @override
  String get streakFreezeConfirm =>
      'هل تريد تجميد رحلة التركيز؟ متاح مرة أسبوعياً';

  @override
  String get shareProgressLabel => 'شارك تقدمك';

  @override
  String levelPointsToNext(int points) {
    return '$points نقطة للمستوى التالي';
  }

  @override
  String get weeklyReportTitle => 'تقرير الأسبوع';

  @override
  String get weeklyReportStreakDays => 'أيام رحلة التركيز هذا الأسبوع';

  @override
  String get weeklyReportAvgBcs => 'متوسط BCS';

  @override
  String get weeklyReportBestEmotion => 'أبرز إحساس';

  @override
  String get weeklyReportChallenges => 'التحديات المكتملة';

  @override
  String get pomodoroTitle => 'بومودورو';

  @override
  String get pomodoroPhaseFocus => 'وقت التركيز 🎯';

  @override
  String get pomodoroPhaseShortBreak => 'استراحة قصيرة ☕';

  @override
  String get pomodoroPhaseLongBreak => 'استراحة طويلة 🌿';

  @override
  String get pomodoroReset => 'إعادة';

  @override
  String get pomodoroSkip => 'تخطي';

  @override
  String pomodoroSessionsToday(int count) {
    return 'جلسات اليوم: $count';
  }

  @override
  String get homeQuickPomodoro => 'بومودورو ⏱️';

  @override
  String get homeQuickGames => 'ألعاب 🎮';

  @override
  String get taskCategoryMental => '🧠 ذهني';

  @override
  String get taskCategoryPhysical => '💪 بدني';

  @override
  String get taskCategoryCreative => '🎨 إبداعي';

  @override
  String get taskCategoryEducational => '📚 تعليمي';

  @override
  String get taskCategoryHousehold => '🏠 منزلي';

  @override
  String singleTaskEstimatedBonus(String points) {
    return 'إنجاز هذه المهمة سيضيف +$points نقطة';
  }

  @override
  String singleTaskFocusRewardSnackBonus(String points) {
    return 'أحسنت! +$points نقاط تركيز';
  }

  @override
  String get singleTaskAbandonSnack =>
      'المهمة غير المكتملة تضعف التركيز قليلاً';

  @override
  String get gamesHubTitle => 'ألعاب الذاكرة 🎮';

  @override
  String get gamePatternMatchTitle => 'مطابقة الأنماط';

  @override
  String get gamePatternMatchDesc => 'احفظ النمط وأعد رسمه من الذاكرة';

  @override
  String get gameNumberMemoryTitle => 'ذاكرة الأرقام';

  @override
  String get gameNumberMemoryDesc => 'تذكر تسلسل أرقام متزايد';

  @override
  String get gameColorWordTitle => 'كلمة اللون';

  @override
  String get gameColorWordDesc => 'اضغط لون الحبر وليس الكلمة';

  @override
  String gamesBestScore(int score) {
    return 'أفضل نتيجة: $score';
  }

  @override
  String gamesBestDigits(int digits) {
    return 'أطول تسلسل: $digits';
  }

  @override
  String gameRoundLabel(int current, int total) {
    return 'الجولة $current / $total';
  }

  @override
  String gameFinalScore(int score) {
    return 'النتيجة: $score';
  }

  @override
  String get gameSubmitRound => 'تأكيد';

  @override
  String get gameEnterSequence => 'أدخل التسلسل الذي رأيته';

  @override
  String gameNumberMemoryResult(int digits) {
    return 'أطول تسلسل: $digits أرقام';
  }

  @override
  String get gameColorWordPrompt => 'اضغط لون الحبر';

  @override
  String gameStroopResult(int correct, int total) {
    return '$correct / $total صحيحة';
  }

  @override
  String gameStroopStats(int correct, int wrong) {
    return '$correct صحيحة · $wrong خاطئة';
  }

  @override
  String get gameDigitSpanIntro =>
      'تظهر الأرقام واحداً تلو الآخر. احفظ ترتيبها ثم أدخلها على لوحة المفاتيح.';

  @override
  String get gameDigitSpanWatch => 'راقب الأرقام';

  @override
  String get gameDigitSpanClear => 'مسح';

  @override
  String get gameDigitSpanDelete => 'حذف';

  @override
  String get gameDigitSpanCorrect => 'صحيح!';

  @override
  String get gameDigitSpanWrong => 'ليست مطابقة — جرب التسلسل التالي';

  @override
  String gameDigitSpanLevel(int digits) {
    return 'الطول: $digits أرقام';
  }

  @override
  String gameDigitSpanLengthLabel(int digits) {
    return 'أفضل مدى في هذه الجلسة: $digits';
  }

  @override
  String get focusedThinkingTitle => 'تحدي التفكير المركّز';

  @override
  String get focusedThinkingSubtitle => 'اختر موضوعاً واحداً فقط وفكر فيه بعمق';

  @override
  String get focusedThinkingDurationLabel => 'المدة';

  @override
  String get focusedThinkingStart => 'ابدأ التفكير';

  @override
  String get focusedThinkingGuideTitle => 'دليل التفكير';

  @override
  String focusedThinkingStillThinking(String topic) {
    return 'هل لا تزال تفكر في $topic؟';
  }

  @override
  String get focusedThinkingYes => 'نعم ✓';

  @override
  String get focusedThinkingNo => 'شردت ✗';

  @override
  String focusedThinkingFocusScore(int percent) {
    return '$percent% من الوقت كنت مركزاً';
  }

  @override
  String focusedThinkingDistractions(int count) {
    return 'التشتت المؤقت المسجّل: $count';
  }

  @override
  String focusedThinkingInsightsSaved(int count) {
    return 'أفكار محفوظة: $count';
  }

  @override
  String get focusedThinkingInsightsHint => 'سجّل أبرز أفكارك';

  @override
  String get focusedThinkingSaveInsight => 'حفظ الفكرة';

  @override
  String get homeQuickFocusedThinking => 'تفكير عميق 🧠';

  @override
  String get homeQuickCrossword => 'كلمات متقاطعة ✏️';

  @override
  String get crosswordTitle => 'كلمات متقاطعة';

  @override
  String get crosswordDesc => 'ألغاز عربية عن الدماغ والتركيز';

  @override
  String get crosswordPlayNow => 'العب الآن';

  @override
  String get crosswordTabAcross => 'أفقي ↔';

  @override
  String get crosswordTabDown => 'عمودي ↕';

  @override
  String get crosswordEnterLetter => 'أدخل الحرف';

  @override
  String get gameNBackTitle => 'N-Back 🧠';

  @override
  String get gameNBackDesc => 'الأقوى علمياً لتحسين الذاكرة العاملة';

  @override
  String get gameNBackIntro =>
      'هذه اللعبة تُعدّ الأقوى علمياً لتحسين الذاكرة العاملة';

  @override
  String gameNBackLevel(int n, int current, int total) {
    return 'N=$n — $current/$total';
  }

  @override
  String get gameNBackMatch => 'تطابق!';

  @override
  String get gameNBackNext => 'التالي';

  @override
  String get gameNBackIntroDetail =>
      'يضيء مربع في شبكة 3×3. اضغط تطابق إذا كان في نفس موضع خطوتين سابقتين؛ وإلا اضغط التالي.';

  @override
  String gameNBackStats(int correct, int wrong) {
    return '$correct صحيحة · $wrong خاطئة';
  }

  @override
  String gameNBackSessionResult(int correct, int wrong) {
    return 'انتهى — $correct صحيحة، $wrong خاطئة';
  }

  @override
  String gameNBackResult(int n) {
    return 'أعلى N: $n';
  }

  @override
  String gameNBackBonus(String points) {
    return '+$points نقطة BCS';
  }

  @override
  String gamesBestNLevel(int n) {
    return 'أفضل N: $n';
  }

  @override
  String get gameSpeedSortTitle => 'الترتيب السريع';

  @override
  String get gameSpeedSortDesc => 'صنّف الأرقام الساقطة زوجي/فردي';

  @override
  String get gameSpeedSortEven => 'زوجي';

  @override
  String get gameSpeedSortOdd => 'فردي';

  @override
  String gameSpeedSortCorrect(int count) {
    return 'صحيح: $count';
  }

  @override
  String gameSpeedSortResult(int correct, int wrong) {
    return 'انتهى! $correct صحيح، $wrong خطأ';
  }

  @override
  String get gameStart => 'ابدأ';

  @override
  String get bciCardTitle => 'مؤشر وضوح الدماغ';

  @override
  String get bciCardTitleEn => 'BRAIN CLARITY INDEX';

  @override
  String get bciCardSubtitle => 'محرك BCI · تحديث لحظي';

  @override
  String get bciCardAssessmentLabel => 'التقييم الأسبوعي';

  @override
  String get bciCardAdherenceLabel => 'الالتزام اليومي';

  @override
  String get bciCardWeightAssessment => '60%';

  @override
  String get bciCardWeightAdherence => '40%';

  @override
  String get bciCardStatusHigh => 'تركيز عالٍ';

  @override
  String get bciCardStatusStable => 'تركيز مستقر';

  @override
  String get bciCardStatusMild => 'ضباب خفيف';

  @override
  String get bciCardStatusWarning => 'تحذير — راجع عاداتك';

  @override
  String get bciCardNoAssessment => 'أكمل التقييم الأسبوعي لعرض BCI الكامل';

  @override
  String get bciCardLoading => 'جاري حساب BCI...';

  @override
  String get settingsSecuritySection => 'الأمان';

  @override
  String get settingsBiometricLock => 'قفل التطبيق بالبصمة';

  @override
  String get settingsBiometricLockSubtitle =>
      'يتطلب المصادقة عند فتح التطبيق (مع رمز الجهاز كبديل)';

  @override
  String get settingsBiometricUnavailable =>
      'المصادقة البيومترية غير متاحة على هذا الجهاز';

  @override
  String get biometricLockTitle => 'التطبيق مقفل';

  @override
  String get biometricLockSubtitle => 'استخدم بصمتك أو رمز الجهاز للمتابعة';

  @override
  String get biometricLockButton => 'فتح Brain Clean';

  @override
  String get securityCompromisedBanner =>
      'تحذير: الجهاز قد يكون معدّلاً. بياناتك محلية فقط — تم تعطيل المزامنة السحابية.';

  @override
  String get brainCheckTitle => 'فحص الدماغ';

  @override
  String get brainCheckIntroNonMedical => 'هذا فحص ذاتي، وليس تشخيصاً طبياً.';

  @override
  String get brainCheckStart => 'ابدأ فحص الدماغ';

  @override
  String get brainCheckContinue => 'متابعة';

  @override
  String get brainCheckStartOver => 'البدء من جديد';

  @override
  String get brainCheckEmptyState => 'ابدأ فحص الدماغ لبناء ملفك.';

  @override
  String brainCheckQuestionProgress(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String brainCheckSectionProgress(int current, int total) {
    return 'الجزء $current من $total';
  }

  @override
  String get brainCheckComplete => 'اكتمل الفحص';

  @override
  String get brainCheckResumeTitle => 'هل تريد متابعة فحص الدماغ؟';

  @override
  String get brainCheckSaveError =>
      'تعذّر حفظ إجاباتك. ما زالت موجودة على هذه الشاشة.';

  @override
  String get brainCheckLoading => 'جارٍ تحميل فحص الدماغ…';

  @override
  String get brainCheckExit => 'خروج من فحص الدماغ';

  @override
  String get brainCheckBack => 'رجوع';

  @override
  String get brainCheckSaving => 'جارٍ الحفظ…';

  @override
  String get brainCheckFinish => 'إنهاء الفحص';

  @override
  String get brainCheckSelectAnswerHint => 'اختر إجابة للمتابعة.';

  @override
  String get brainCheckAutosaveHint =>
      'تُحفظ إجاباتك على هذا الجهاز أثناء التقدّم.';

  @override
  String get brainCheckAnswerChoices => 'خيارات الإجابة';

  @override
  String get brainCheckAnswerSelected => 'محدد';

  @override
  String get brainCheckAnswerUnselected => 'غير محدد';

  @override
  String get brainCheckAnswerYes => 'نعم';

  @override
  String get brainCheckAnswerNo => 'لا';

  @override
  String get brainCheckLikert1 => 'أعارض بشدة';

  @override
  String get brainCheckLikert2 => 'أعارض';

  @override
  String get brainCheckLikert3 => 'محايد';

  @override
  String get brainCheckLikert4 => 'أوافق';

  @override
  String get brainCheckLikert5 => 'أوافق بشدة';

  @override
  String get brainCheckFrequency1 => 'أبداً';

  @override
  String get brainCheckFrequency2 => 'نادراً';

  @override
  String get brainCheckFrequency3 => 'أحياناً';

  @override
  String get brainCheckFrequency4 => 'غالباً';

  @override
  String get brainCheckFrequency5 => 'كثيراً جداً';

  @override
  String get brainCheckBreakTitle => 'استراحة قصيرة';

  @override
  String brainCheckBreakBody(String sectionTitle) {
    return 'التالي: $sectionTitle';
  }

  @override
  String get brainCheckCompletionBody =>
      'شكراً لإنهاء هذا التقرير الذاتي. فحصك جاهز للحفظ على هذا الجهاز.';

  @override
  String get brainCheckConfigError => 'أسئلة فحص الدماغ غير متاحة الآن.';

  @override
  String get brainCheckRestartTitle => 'البدء من جديد؟';

  @override
  String get brainCheckRestartBody =>
      'سيُمسح فحص الدماغ غير المكتمل على هذا الجهاز. تبقى خطوات التهيئة والملفات المكتملة السابقة دون مساس.';

  @override
  String get brainCheckRestartCancel => 'المتابعة';

  @override
  String get brainCheckRestartConfirm => 'البدء من جديد';

  @override
  String get brainCheckCompleteBoundaryTitle => 'تم حفظ فحص الدماغ';

  @override
  String get brainCheckCompleteBoundaryBody =>
      'تقريرك الذاتي محفوظ على هذا الجهاز. تابع لبناء لقطة ملف الدماغ.';

  @override
  String get brainCheckCompleteBoundaryContinue => 'ابنِ ملف الدماغ';

  @override
  String get brainProfileTitle => 'ملف الدماغ';

  @override
  String get brainProfileBuilding => 'جارٍ بناء ملف الدماغ…';

  @override
  String get brainProfileLoading => 'جارٍ تحميل ملف الدماغ';

  @override
  String get brainProfileMissing => 'لا يوجد ملف دماغ بعد';

  @override
  String get brainProfileEmptyHint => 'أكمل فحص الدماغ لإنشاء أول لقطة.';

  @override
  String get brainProfileUnavailable => 'حساب الملف غير متاح الآن.';

  @override
  String get brainProfileRetry => 'حاول مرة أخرى';

  @override
  String get brainProfileGoHome => 'العودة إلى الرئيسية';

  @override
  String get brainProfileOrientation => 'نظرة هادئة على لقطتك';

  @override
  String get brainProfileScoreHeading => 'تقدير درجة التعافي';

  @override
  String get brainProfileScorePendingLabel => 'التقدير قيد الانتظار';

  @override
  String get brainProfileScorePendingSemantics =>
      'تقدير درجة التعافي قيد الانتظار. ملخصات المجالات متاحة من إجاباتك.';

  @override
  String brainProfileScoreSemantics(String value) {
    return 'تقدير درجة التعافي: $value';
  }

  @override
  String get brainProfileConfidenceHeading => 'الثقة';

  @override
  String get brainProfileConfidenceProvisional => 'أولية';

  @override
  String get brainProfileConfidenceModerate => 'متوسطة';

  @override
  String get brainProfileConfidenceSolid => 'قوية';

  @override
  String get brainProfileBandHeading => 'النطاق الحالي';

  @override
  String get brainProfileBandMeaning =>
      'تسمية هادئة لتقدير التقرير الذاتي — وليست شدة سريرية.';

  @override
  String get brainProfileMeansHeading => 'ماذا يعني هذا';

  @override
  String get brainProfileMeansBody =>
      'هذه لقطة بداية مبلَّغ عنها ذاتياً. تُبرز المناطق الأقوى كما ظهرت وأولويات الدعم الحالية بناءً على إجابات فحص الدماغ.';

  @override
  String get brainProfileDoesNotMeanHeading => 'ماذا لا يعني هذا';

  @override
  String get brainProfileScoreUnavailableLabel => 'التقدير غير متاح';

  @override
  String get brainProfileScoreUnavailableSemantics =>
      'تقدير درجة التعافي غير متاح. لا يُعرض رقم.';

  @override
  String get brainProfileScoreUnavailableBody =>
      'تعذّر تقدير درجة التعافي من هذا الفحص. تبقى إجاباتك محفوظة. أكمل فحصاً صالحاً للمتابعة إلى برنامجك اليومي.';

  @override
  String get brainProfileContinueUnavailable =>
      'برنامجك اليومي تحتاج تقدير درجة تعافٍ صالح.';

  @override
  String get brainProfileMissingEvent => 'أكمل فحص الدماغ أولاً.';

  @override
  String get brainProfileBuildingHint =>
      'جارٍ تجهيز لقطة تقريرك الذاتي على هذا الجهاز…';

  @override
  String get brainProfileDomainEstimateHeading => 'التقدير الحالي';

  @override
  String get brainProfileDomainStrongerLabel => 'منطقة أقوى كما ظهرت';

  @override
  String get brainProfileDomainSupportLabel => 'أولوية دعم حالية';

  @override
  String get brainProfileDomainNeutralLabel => 'بناءً على إجاباتك الحالية';

  @override
  String get brainProfileDomainBasedOnAnswers =>
      'بناءً على موضوعات من إجابات فحص الدماغ الحالية — وليس درجات خام.';

  @override
  String get brainProfileDomainNonMedical =>
      'ليس تشخيصاً طبياً. وليس كشفاً عن تلف دماغي. وليس درجة ذكاء.';

  @override
  String get brainProfileDomainPlanPreviewHint =>
      'قد تركّز خطوة لطيفة من برنامجك اليومي هنا لاحقاً — وذلك بعد المتابعة.';

  @override
  String get brainProfileDomainsHeading => 'ملخص المجالات';

  @override
  String get brainProfileDomainNoData => 'لا إجابات في هذا المجال بعد';

  @override
  String brainProfileDomainMean(String value) {
    return 'المتوسط المبلّغ عنه: $value';
  }

  @override
  String get brainProfileDomainClose => 'إغلاق';

  @override
  String get brainProfileExplainHeading => 'ماذا يعني هذا';

  @override
  String get brainProfileContinue => 'المتابعة إلى برنامجك اليومي';

  @override
  String get brainProfileReadyTitle => 'ملف الدماغ جاهز';

  @override
  String get brainProfileReadyBody =>
      'برنامجك اليومي هي الخطوة الهادئة التالية عند المتابعة من ملفك.';

  @override
  String get brainProfileHistoricalBadge => 'لقطة سابقة';

  @override
  String get recoveryPlanTitle => 'برنامجك اليومي';

  @override
  String get recoveryPlanBuilding => 'جارٍ بناء برنامجك اليومي…';

  @override
  String get recoveryPlanLoading => 'جارٍ تحميل برنامجك اليومي';

  @override
  String get recoveryPlanReady => 'برنامجك اليومي جاهزة';

  @override
  String get recoveryPlanStarterReady => 'خطة بداية هادئة جاهزة';

  @override
  String get recoveryPlanMissing => 'لا توجد خطة تعافٍ بعد';

  @override
  String get recoveryPlanMissingProfile => 'أكمل فحص الدماغ وملف الدماغ أولاً.';

  @override
  String get recoveryPlanScoreUnavailable =>
      'الخطة الكاملة تحتاج تقدير درجة تعافٍ صالح. قد تبقى خطة البداية متاحة.';

  @override
  String get recoveryPlanUnsupportedVersion =>
      'نموذج الخطة هذا غير مدعوم في هذا الإصدار.';

  @override
  String get recoveryPlanGenerationError =>
      'تعذّر بناء خطتك الآن. حاول مرة أخرى.';

  @override
  String get recoveryPlanRetry => 'حاول مرة أخرى';

  @override
  String get recoveryPlanGoHome => 'العودة إلى الرئيسية';

  @override
  String get recoveryPlanBuildCta => 'ابنِ برنامجك اليومي';

  @override
  String get recoveryPlanMainFocus => 'التركيز الرئيسي';

  @override
  String get recoveryPlanPrioritiesHeading => 'دعم الأولوية';

  @override
  String get recoveryPlanNoPriorities => 'لا مجالات أولوية في خطة البداية هذه';

  @override
  String get recoveryPlanStrongerHeading => 'ما يساعدك بالفعل';

  @override
  String get recoveryPlanConfidenceHeading => 'الثقة';

  @override
  String get recoveryPlanTimeHeading => 'الوقت اليومي';

  @override
  String recoveryPlanTimeRange(String min, String max) {
    return 'حوالي $min–$max دقيقة';
  }

  @override
  String get recoveryPlanIntensityLabel => 'الشدة';

  @override
  String get recoveryPlanMinimumPath => 'المسار الأدنى';

  @override
  String get recoveryPlanStandardPath => 'المسار القياسي';

  @override
  String get recoveryPlanBecauseHeading => 'لماذا هذه الخطة اليوم';

  @override
  String get recoveryPlanTodayPreview => 'معاينة اليوم';

  @override
  String get recoveryPlanContinueToday => 'المتابعة إلى اليوم';

  @override
  String get recoveryPlanSkipHint => 'تخطي خطوة لا يُحسب أبداً ضدك.';

  @override
  String get recoveryPlanOptionalTag => 'اختياري';

  @override
  String get recoveryPlanNoSteps => 'لا خطوات مدرجة';

  @override
  String get recoveryPlanStarterBadge => 'خطة بداية';

  @override
  String get recoveryPlanTodayReadyTitle => 'اليوم جاهز للبدء';

  @override
  String get recoveryPlanTodayReadyBody =>
      'مشغّل الجلسة اليومية يأتي في خطوة لاحقة. برنامجك اليومي محفوظة على هذا الجهاز.';

  @override
  String get recoveryPlanCalmOrientation => 'برنامجك اليومي الخاصة بك';

  @override
  String get recoveryPlanCalmOrientationBody =>
      'هذه الخطة تقدير عملي مبني على ملف الدماغ الحالي. ليست تشخيصاً ولا علاجاً. يمكنك تعديلها لاحقاً.';

  @override
  String get recoveryPlanFitsProfile => 'تتوافق مع أولويات تقدير ملفك الحالي.';

  @override
  String get recoveryPlanTodayFitHeading => 'كيف يتوافق اليوم';

  @override
  String get recoveryPlanOpenToday => 'افتح اليوم';

  @override
  String get recoveryPlanAboutDetails => 'لماذا هذه الخطة';

  @override
  String get recoveryPlanPathDetails => 'تفاصيل المسار';

  @override
  String recoveryPlanStepCount(int count) {
    return '$count خطوات';
  }

  @override
  String get v2TodayPreviewTitle => 'أول يوم لك';

  @override
  String get v2TodayPreviewLoading => 'جارٍ تحميل معاينة اليوم';

  @override
  String get v2TodayPreviewHeading => 'معاينة اليوم';

  @override
  String get v2TodayPreviewOrientation =>
      'يومك يبدأ بخطوة واضحة واحدة. إكمالها لاحقاً سيُسجّل يومك في الخطة.';

  @override
  String get v2TodayPreviewActHeading => 'الخطوة الأولى';

  @override
  String get v2TodayPreviewFallbackTitle => 'ممارسة اليوم';

  @override
  String get v2TodayPreviewBecauseHeading => 'لماذا هذه الخطوة اليوم';

  @override
  String get v2TodayPreviewCompletionMeaning =>
      'إنهاء هذه الخطوة لاحقاً يُحسب يوماً مكتملاً. التخطي مسموح دون أثر سلبي.';

  @override
  String get v2TodayPreviewContinueCta => 'المتابعة — خطوتك الأولى جاهزة';

  @override
  String get v2TodayPreviewMissingAct =>
      'خطوة اليوم غير متاحة بعد. أعد بناء برنامجك اليومي.';

  @override
  String get v2TodayReadyLoading => 'جارٍ تجهيز خطوتك الأولى';

  @override
  String get v2TodayReadyFirstStepTitle => 'خطوتك الأولى جاهزة';

  @override
  String get v2TodayReadyFirstStepBody =>
      'برنامجك اليومي محفوظة. افتح اليوم لبدء جلستك اليومية الأولى عندما تكون جاهزاً. يمكنك المغادرة والعودة دون فقدان التقدّم.';

  @override
  String get v2TodayReadyJourneySaved =>
      'اكتمل الإعداد لأول مرة على هذا الجهاز.';

  @override
  String get v2TodayReadyProgressSaved => 'تقدّمك محفوظ على هذا الجهاز.';

  @override
  String get v2TodayReadyPrimaryCta => 'افتح اليوم';

  @override
  String get v2TodayReadyReviewPreview => 'مراجعة معاينة اليوم';

  @override
  String get v2TodayReadyCorruptPlan =>
      'تعذّر قراءة هذه الخطة بأمان. أعد بناءها بهدوء عندما تكون جاهزاً.';

  @override
  String get v2TodayReadyPersistFailed =>
      'تعذّر حفظ التقدّم الآن. حاول مرة أخرى.';

  @override
  String get v2TodayHomeTitle => 'اليوم';

  @override
  String get v2TodayHomeLoading => 'جارٍ تحميل اليوم';

  @override
  String get v2TodayHomeOrientation => 'يومك';

  @override
  String get v2TodayHomeOrientationBody =>
      'فعل واحد واضح من برنامجك اليومي. بلا إضافات.';

  @override
  String get v2TodayHomeStandardPathHint =>
      'التزم بممارسة اليوم — خطوات صغيرة تعيد بناء التركيز.';

  @override
  String get v2TodayHomeStatusHeading => 'الحالة';

  @override
  String get v2TodayHomeStatusReady => 'جاهز متى شئت';

  @override
  String get v2TodayHomeStatusInProgress => 'الجلسة قيد التنفيذ';

  @override
  String get v2TodayHomeStatusReflect => 'قاربت الانتهاء — أكمل التسجيل';

  @override
  String get v2TodayHomeStatusDone => 'انتهى لليوم';

  @override
  String get v2TodayHomeStatusPartial => 'حُفظ التقدّم — تابع غداً';

  @override
  String get v2TodayHomeCtaStart => 'ابدأ برنامجك اليومي';

  @override
  String get v2TodayHomeCtaContinue => 'متابعة البرنامج';

  @override
  String get v2TodayHomeCtaViewCompleted => 'عرض الجلسة المكتملة';

  @override
  String get v2TodayHomeViewPlan => 'عرض برنامجك اليومي';

  @override
  String get homeGreetingMorning => 'صباح الخير';

  @override
  String get homeGreetingAfternoon => 'مساء الخير';

  @override
  String get homeGreetingEvening => 'مساء الخير';

  @override
  String homeGreetingName(String name) {
    return 'أهلاً، $name';
  }

  @override
  String get homeFocusLevelTag => 'نسبة التعافي';

  @override
  String homeFocusImprovement(int percent) {
    return 'تحسّن $percent% عن أول فحص';
  }

  @override
  String get homeFocusImprovementPending => 'أكمل فحص الدماغ لتتبّع التعافي';

  @override
  String get homeMetricStreakLabel => 'أيام متواصلة';

  @override
  String get homeMetricExercisesLabel => 'تمارين اليوم';

  @override
  String get homeSuggestedExerciseBadge => 'مقترح';

  @override
  String get homeProgramPathTitle => 'برنامجك اليومي';

  @override
  String homeProgramPathDay(int current, int total) {
    return 'يوم $current من $total';
  }

  @override
  String get homeTodaySessionHeading => 'برنامجك اليومي';

  @override
  String get homeDateTodayLabel => 'اليوم';

  @override
  String get homeDatePrevDay => 'اليوم السابق';

  @override
  String get homeDateNextDay => 'اليوم التالي';

  @override
  String get homeReturnToToday => 'العودة إلى اليوم';

  @override
  String get homePomodoroTitle => 'مؤقّت التركيز';

  @override
  String get homePomodoroStart => 'ابدأ';

  @override
  String get homePomodoroPause => 'إيقاف مؤقت';

  @override
  String get homePomodoroMinutesShort => '٢٥ دقيقة';

  @override
  String get homePomodoroMinutesLong => '٥٠ دقيقة';

  @override
  String get homePomodoroMinus5 => '−٥ دقائق';

  @override
  String get homePomodoroPlus5 => '+٥ دقائق';

  @override
  String get homeWeeklyTestTitle => 'الاختبار الأسبوعي';

  @override
  String get homeWeeklyTestLocked => 'يفتح كل 7 أيام';

  @override
  String homeWeeklyTestDaysLeft(int days) {
    return 'يفتح بعد $days أيام';
  }

  @override
  String get homeWeeklyTestReady => 'جاهز — ابدأ فحص هذا الأسبوع';

  @override
  String get homeWeeklyReportTitle => 'التقرير الأسبوعي';

  @override
  String get homeWeeklyReportLocked => 'مقفل حتى نافذة المراجعة التالية';

  @override
  String homeWeeklyReportDaysLeft(int days) {
    return 'متاح بعد $days أيام';
  }

  @override
  String get homeWeeklyReportReady => 'تقريرك الأسبوعي جاهز';

  @override
  String get homeBaselineTestTitle => 'فحص الأساس';

  @override
  String get homeBaselineTestPending => 'لم يُنجز بعد';

  @override
  String homeBaselineTestScore(int score) {
    return 'درجة الأساس $score';
  }

  @override
  String get homeSafaCardTitle => 'صفا';

  @override
  String get homeSafaCardBody => 'دعم هادئ لخطوتك اليوم';

  @override
  String get homeSafaCardCta => 'افتح صفا';

  @override
  String get homePastProgramHeading => 'برنامج هذا اليوم';

  @override
  String get homePastProgramEmpty => 'لا يوجد برنامج محفوظ لهذا اليوم بعد.';

  @override
  String get homeUpgradeToPro => 'ترقية للـ Pro';

  @override
  String get homeBrainCheckBadgeTitle => 'اكتمل ملفك الذهني — ابدأ الفحص';

  @override
  String get homeBrainCheckBadgeCta => 'ابدأ فحص الدماغ';

  @override
  String get homeBrainCheckScoreTitle => 'فحص الدماغ';

  @override
  String homeBrainCheckScoreValue(int score) {
    return 'النتيجة $score';
  }

  @override
  String get homeBrainCheckRedo => 'إعادة';

  @override
  String get homeDailyProgramEmptyTitle => 'ابنِ برنامجك اليومي';

  @override
  String get homeDailyProgramEmptyBody =>
      'ممارسة يومية قصيرة لتقليل وقت الشاشة وإعادة بناء التركيز — خطوة واضحة واحدة كل يوم.';

  @override
  String get homeDailyProgramEmptyCta => 'إعداد البرنامج';

  @override
  String get v2SessionPrepareTitle => 'تهيئة';

  @override
  String get v2SessionPreparePurpose => 'ممارسة موجهة قصيرة من خطتك.';

  @override
  String get v2SessionPrepareIncludes => 'تتضمن هذه الجلسة:';

  @override
  String get v2SessionPathHeading => 'اختر مسارك';

  @override
  String get v2SessionPathNoShame =>
      'المسار الأدنى مكتمل ومفيد. القياسي يضيف عمقاً اختيارياً.';

  @override
  String get v2SessionA11yHint => 'لكل خطوة بديل وصولية.';

  @override
  String get v2SessionStartCta => 'ابدأ';

  @override
  String get v2SessionClose => 'إغلاق';

  @override
  String get v2SessionActTitle => 'جلسة اليوم';

  @override
  String v2SessionProgress(String current, String total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get v2SessionOptionalLabel => 'اختياري';

  @override
  String get v2SessionRequiredLabel => 'مطلوب';

  @override
  String get v2SessionStartTimer => 'بدء مؤقت اختياري';

  @override
  String v2SessionTimerContext(String seconds) {
    return 'حوالي $seconds ثانية متبقية على المؤقت الاختياري';
  }

  @override
  String get v2SessionMarkDone => 'تعليم الخطوة منتهية';

  @override
  String get v2SessionSkipOptional => 'تخطّ الخطوة الاختيارية';

  @override
  String get v2SessionEndEarly => 'إنهاء والتسجيل';

  @override
  String get v2SessionReflectTitle => 'تسجيل سريع';

  @override
  String get v2SessionReflectPrompt => 'كيف شعرت بجلسة اليوم؟';

  @override
  String get v2SessionReflectManageable => 'ما مدى قابليتها للإدارة؟';

  @override
  String get v2SessionReflectHelped => 'هل ساعدتك على التمهّل أو التركيز؟';

  @override
  String get v2SessionReflectObstacle => 'أي عائق؟ (اختياري)';

  @override
  String get v2SessionChipEasy => 'قابلة للإدارة';

  @override
  String get v2SessionChipOk => 'جيدة';

  @override
  String get v2SessionChipHard => 'صعبة';

  @override
  String get v2SessionChipYes => 'نعم';

  @override
  String get v2SessionChipSomewhat => 'إلى حد ما';

  @override
  String get v2SessionChipNotYet => 'ليس بعد';

  @override
  String get v2SessionChipNone => 'لا شيء';

  @override
  String get v2SessionChipDistraction => 'التشتت المؤقت';

  @override
  String get v2SessionChipLowEnergy => 'طاقة منخفضة';

  @override
  String get v2SessionChipTime => 'وقت';

  @override
  String get v2SessionReflectSave => 'حفظ التسجيل';

  @override
  String get v2SessionReflectSkipChips => 'المتابعة دون اختيارات';

  @override
  String get v2SessionSaving => 'جارٍ الحفظ…';

  @override
  String get v2SessionLeaveSuccess => 'أحسنت — انتهيت لليوم';

  @override
  String get v2SessionLeavePartial => 'توقفت بلطف — لم يُفقد شيء';

  @override
  String v2SessionLeavePath(String path) {
    return 'المسار: $path';
  }

  @override
  String get v2SessionLeaveBody =>
      'الكفاءة الهادئة كافية. غادر التطبيق عندما تكون جاهزاً.';

  @override
  String get v2SessionLeaveNext => 'غداً سيعرض اليوم خطوة واضحة واحدة من جديد.';

  @override
  String get v2SessionLeaveCta => 'العودة إلى اليوم';

  @override
  String get v2ProgressEmptyTitle => 'لا تقدّم بعد';

  @override
  String get v2ProgressEmptyBody =>
      'أكمل جلسة اليوم لتبدأ سجلاً محلياً صادقاً. لا يُختلق شيء عندما يكون السجل فارغاً.';

  @override
  String get v2ProgressLoading => 'جارٍ تحميل التقدّم';

  @override
  String get v2ProgressPersistFailed =>
      'تعذّر حفظ التقدّم الآن. حاول مرة أخرى.';

  @override
  String get v2ProgressStatsSessions => 'الجلسات المكتملة';

  @override
  String get v2ProgressStatsMinimum => 'جلسات المسار الأدنى';

  @override
  String get v2ProgressStatsStandard => 'جلسات المسار القياسي';

  @override
  String get v2ProgressStatsRate => 'معدل الأيام المكتملة';

  @override
  String get v2ProgressStatsCurrentStreak => 'تتابع الأيام المكتملة الحالي';

  @override
  String get v2ProgressStatsLongestStreak => 'أطول تتابع أيام مكتملة';

  @override
  String get v2OnboardingLoading => 'جارٍ التحميل…';

  @override
  String get v2OnboardingContinue => 'متابعة';

  @override
  String get v2OnboardingBack => 'رجوع';

  @override
  String get v2OnboardingRetry => 'حاول مرة أخرى';

  @override
  String get v2OnboardingRestart => 'ابدأ التهيئة من جديد';

  @override
  String get v2OnboardingGoHome => 'العودة إلى الرئيسية';

  @override
  String v2OnboardingProgressLabel(String current, String total) {
    return 'الخطوة $current من $total';
  }

  @override
  String v2OnboardingProgressSemantics(String current, String total) {
    return 'خطوة التهيئة $current من $total';
  }

  @override
  String get v2OnboardingLanguageArabic => 'العربية';

  @override
  String get v2OnboardingLanguageEnglish => 'English';

  @override
  String get v2OnboardingWelcomeTitle => 'مرحباً بك في Brain Clean';

  @override
  String get v2OnboardingWelcomeBody =>
      'يساعدك Brain Clean على تقدير حالتك الحالية في التعافي، وبناء خطة تعافٍ مخصصة، وملاحظة التغيير مع الوقت — بهدوء ودون ادعاءات طبية.';

  @override
  String get v2OnboardingExpectationsTitle => 'ما الذي تتوقعه';

  @override
  String get v2OnboardingExpectationsBody =>
      'مسار قصير وصادق — ليس تشخيصاً وليس ضماناً.';

  @override
  String get v2OnboardingExpectation1 =>
      'جلسة يومية قصيرة عندما تكون جاهزاً — حوالي خمس دقائق.';

  @override
  String get v2OnboardingExpectation2 =>
      'فحص دماغ مبني على تقرير ذاتي، وليس تشخيصاً طبياً.';

  @override
  String get v2OnboardingExpectation3 =>
      'خطة عملية يمكن فهمها، مع تقدّم يمكن ملاحظته مع الوقت.';

  @override
  String get v2OnboardingExpectationsFootnote =>
      'النتائج غير مضمونة. قد يتقدّم التقدّم ويتراجع.';

  @override
  String get v2OnboardingConsentTitle => 'قبل المتابعة';

  @override
  String get v2OnboardingConsentBody =>
      'يرجى تأكيد فهمك لكيفية استخدام Brain Clean.';

  @override
  String get v2OnboardingConsentNonMedical =>
      'أفهم أن Brain Clean ليس تشخيصاً طبياً ولا تقييماً سريرياً ولا علاجاً.';

  @override
  String get v2OnboardingConsentTerms =>
      'أوافق على المتابعة وفق شروط استخدام التطبيق.';

  @override
  String get v2OnboardingConsentAnalytics =>
      'اختياري: السماح بإشارات استخدام مجهولة للمنتج (متوقفة افتراضياً).';

  @override
  String get v2OnboardingConsentHint => 'حدّد المربعات المطلوبة للمتابعة.';

  @override
  String get v2OnboardingPrivacyTitle => 'بياناتك على هذا الجهاز';

  @override
  String get v2OnboardingPrivacyBody =>
      'تُحسب إجابات فحص الدماغ الأساسية ودرجة التعافي وبرنامجك اليومي وتُخزَّن محلياً على هذا الجهاز. يمكنك إيقاف فحص الدماغ واستئنافه. تبقى الشروحات قابلة للمراجعة. الدرجة لا يولّدها ذكاء اصطناعي.';

  @override
  String get v2OnboardingPrivacyFootnote =>
      'قد تستخدم بعض ميزات المنتج الاختيارية الشبكة لاحقاً (مثل المزامنة أو الدعم أو الإعلانات عند تفعيلها). المتابعة تعمل دون اتصال.';

  @override
  String get v2OnboardingPrivacyPolicyLink => 'ملخص الخصوصية';

  @override
  String get v2OnboardingPrivacyCachedSummary =>
      'يبقي Brain Clean بيانات الفحص والخطة الأساسية محلية أولاً. ميزات السحابة أو الشبكة الاختيارية منفصلة وغير مطلوبة لإكمال هذه التهيئة. هذا ليس شهادة خصوصية طبية.';

  @override
  String get v2OnboardingRitualTitle => 'متى تناسبك جلسة قصيرة عادةً؟';

  @override
  String get v2OnboardingRitualBody =>
      'اختر نافذة لطيفة كتذكير. يمكنك تغيير ذلك لاحقاً.';

  @override
  String get v2OnboardingRitualMorning => 'صباحاً';

  @override
  String get v2OnboardingRitualAfternoon => 'ظهراً';

  @override
  String get v2OnboardingRitualEvening => 'مساءً';

  @override
  String get v2OnboardingRitualDecideLater => 'قرّر لاحقاً';

  @override
  String get v2OnboardingCheckIntroTitle => 'فحص الدماغ';

  @override
  String get v2OnboardingCheckIntroBody =>
      'فحص الدماغ تقرير ذاتي قصير. ليس تشخيصاً طبياً، ولا كشفاً عن تلف دماغي، ولا اختبار ذكاء. تبقى إجاباتك على هذا الجهاز وتساعد في بناء خطة عملية.';

  @override
  String get v2OnboardingCheckIntroMeta =>
      'فحص خفيف · بضع دقائق · قابل للاستئناف';

  @override
  String get v2OnboardingStartBrainCheck => 'ابدأ فحص الدماغ';

  @override
  String get v2OnboardingSkipBrainCheck => 'تخطَّ الآن';

  @override
  String get v2OnboardingCorruptTitle => 'لنبدأ من جديد بهدوء';

  @override
  String get v2OnboardingCorruptBody =>
      'تعذّر قراءة بيانات التهيئة بأمان. لم تُحذف إجابات فحص الدماغ. يمكنك بدء التهيئة مرة أخرى.';

  @override
  String get v2BrainCheckEntryTitle => 'فحص الدماغ';

  @override
  String get v2BrainCheckEntryLoading => 'جارٍ تجهيز فحص الدماغ…';

  @override
  String get v2BrainCheckEntryBody =>
      'تقرير ذاتي هادئ للمساعدة على تقدير حالتك الحالية في التعافي.';

  @override
  String get v2BrainCheckEntryNonMedical =>
      'ليس تشخيصاً طبياً. ليس علاجاً. ليس مقياساً للذكاء.';

  @override
  String get v2BrainCheckEntryDuration =>
      'فحص خفيف · قصير · يمكنك التوقّف في أي وقت';

  @override
  String get v2BrainCheckEntryStart => 'ابدأ فحص الدماغ';

  @override
  String get v2BrainCheckEntryResume => 'استئناف فحص الدماغ';

  @override
  String get v2BrainCheckEntryResumeHint =>
      'لديك فحص دماغ غير مكتمل على هذا الجهاز.';

  @override
  String get v2BrainCheckEntryStartOver => 'البدء من جديد';

  @override
  String get v2BrainCheckEntryAlreadyComplete =>
      'فحص الدماغ مكتمل بالفعل. البدء من جديد متاح في خطوات لاحقة — ولم تُمسَ الإجابات.';

  @override
  String get v2BrainCheckEntryError => 'تعذّر تجهيز فحص الدماغ الآن.';

  @override
  String get v2BrainCheckReadyTitle => 'فحص الدماغ جاهز';

  @override
  String get v2BrainCheckReadyBody =>
      'دخول فحص الدماغ جاهز. تابع عندما تريد فتح الاستبيان أو استئنافه.';

  @override
  String get v2WeeklyReviewTitle => 'المراجعة الأسبوعية';

  @override
  String get v2WeeklySummaryTitle => 'ملخص الأسبوع';

  @override
  String get v2WeeklyReviewLoading => 'جارٍ تحميل المراجعة الأسبوعية';

  @override
  String get v2WeeklyReviewExit => 'خروج';

  @override
  String get v2WeeklyReviewBack => 'رجوع';

  @override
  String get v2WeeklyReviewContinue => 'متابعة';

  @override
  String get v2WeeklyReviewComplete => 'إكمال المراجعة';

  @override
  String get v2WeeklyReviewRetry => 'حاول مرة أخرى';

  @override
  String get v2WeeklyReviewBackToday => 'العودة إلى اليوم';

  @override
  String get v2WeeklyReviewSaveFailed =>
      'تعذّر حفظ مراجعتك الآن. حاول مرة أخرى.';

  @override
  String get v2WeeklyReviewUnsupported =>
      'صيغة هذه المراجعة غير مدعومة في هذا الإصدار.';

  @override
  String get v2WeeklyReviewNotReadyGeneric =>
      'المراجعة الأسبوعية غير جاهزة بعد';

  @override
  String get v2WeeklyReviewNotReadyGenericBody =>
      'عُد بعد أسبوع مكتمل فيه جلسة واحدة منتهية على الأقل.';

  @override
  String get v2WeeklyReviewNotReadyZeroTitle => 'لا يوجد نشاط مكتمل كافٍ بعد';

  @override
  String get v2WeeklyReviewNotReadyZeroBody =>
      'أكمل جلسة اليوم مرة واحدة على الأقل في أسبوع منتهٍ لفتح المراجعة الأسبوعية.';

  @override
  String get v2WeeklyReviewNotReadyCurrentTitle => 'هذا الأسبوع ما زال جارياً';

  @override
  String get v2WeeklyReviewNotReadyCurrentBody =>
      'تُفتَح المراجعة الأسبوعية بعد انتهاء الأسبوع. تابع اليوم عندما تكون جاهزاً.';

  @override
  String get v2WeeklyReviewNotReadyMissingTitle => 'مصادر المراجعة غير جاهزة';

  @override
  String get v2WeeklyReviewNotReadyMissingBody =>
      'خطة أو ملف شخصي أو سجل تقدّم محلي مفقود. تابع عبر اليوم ثم عُد لاحقاً.';

  @override
  String v2WeeklyReviewPeriodLabel(String start, String end) {
    return 'الفترة $start – $end';
  }

  @override
  String v2WeeklyReviewProgress(String current, String total) {
    return 'السؤال $current من $total';
  }

  @override
  String v2WeeklyReviewProgressSemantics(String current, String total) {
    return 'سؤال المراجعة الأسبوعية $current من $total';
  }

  @override
  String get v2WeeklyReviewRequired => 'مطلوب';

  @override
  String get v2WeeklyReviewMultiSelectHint => 'اختياري. اختر حتى خيارين.';

  @override
  String get v2WeeklyReviewValidationHint =>
      'يرجى اختيار إجابة صالحة للمتابعة.';

  @override
  String get v2WeeklyReviewYes => 'نعم';

  @override
  String get v2WeeklyReviewNo => 'لا';

  @override
  String get v2WeeklyReviewQManageability =>
      'ما مدى قابلية الخطة للإدارة هذا الأسبوع؟';

  @override
  String get v2WeeklyReviewQPauseFocus =>
      'إلى أي مدى ساعدتك الجلسات على التمهّل أو التركيز؟';

  @override
  String get v2WeeklyReviewQObstacle => 'ما الذي أعاقك في أغلب الأحيان؟';

  @override
  String get v2WeeklyReviewQSupport => 'ما الذي ساعدك؟ (اختياري)';

  @override
  String get v2WeeklyReviewQAccessibility =>
      'هل استخدمت بديلاً للوصولية هذا الأسبوع؟ (اختياري)';

  @override
  String get v2WeeklyReviewOptTooLight => 'خفيف جداً';

  @override
  String get v2WeeklyReviewOptAboutRight => 'مناسب تقريباً';

  @override
  String get v2WeeklyReviewOptTooDemanding => 'متطلّب جداً';

  @override
  String get v2WeeklyReviewOptTime => 'الوقت';

  @override
  String get v2WeeklyReviewOptForgetfulness => 'النسيان';

  @override
  String get v2WeeklyReviewOptLowEnergy => 'طاقة منخفضة';

  @override
  String get v2WeeklyReviewOptInterruptions => 'مقاطعات';

  @override
  String get v2WeeklyReviewOptUnclearStep => 'خطوة غير واضحة';

  @override
  String get v2WeeklyReviewOptAccessEnv => 'الوصول أو البيئة';

  @override
  String get v2WeeklyReviewOptNoMajorObstacle => 'لا عائق كبير';

  @override
  String get v2WeeklyReviewOptShorterPath => 'مسار أقصر';

  @override
  String get v2WeeklyReviewOptClearerTiming => 'توقيت أوضح';

  @override
  String get v2WeeklyReviewOptQuieterEnv => 'بيئة أهدأ';

  @override
  String get v2WeeklyReviewOptA11yAlt => 'بديل وصولية';

  @override
  String get v2WeeklyReviewOptStrongerReminder => 'تذكير أقوى';

  @override
  String get v2WeeklyReviewOptSamePlan => 'الخطة الحالية مناسبة';

  @override
  String get v2WeeklySummaryOrientation => 'نمط هذا الأسبوع';

  @override
  String v2WeeklySummaryCompletedDays(String count) {
    return 'الأيام المكتملة: $count';
  }

  @override
  String v2WeeklySummaryPathMix(String label) {
    return 'مزيج المسارات: $label';
  }

  @override
  String get v2WeeklySummaryPathMostlyMinimum => 'غالباً الأدنى';

  @override
  String get v2WeeklySummaryPathMostlyStandard => 'غالباً القياسي';

  @override
  String get v2WeeklySummaryPathBalanced => 'متوازن';

  @override
  String get v2WeeklySummaryPathSingle => 'جلسة واحدة فقط';

  @override
  String get v2WeeklySummaryPatternHeading => 'الإيقاع';

  @override
  String get v2WeeklySummaryRhythmSteady => 'ثابت عبر عدة أيام';

  @override
  String get v2WeeklySummaryRhythmIntermittent => 'متقطّع عبر الأسبوع';

  @override
  String get v2WeeklySummaryRhythmLimited => 'سجل محدود';

  @override
  String get v2WeeklySummaryObstacleHeading => 'ما الذي أعاقك؟';

  @override
  String get v2WeeklySummarySupportHeading => 'ما الذي ساعدك؟';

  @override
  String get v2WeeklySummarySupportNone => 'لم يُذكر دعم';

  @override
  String get v2WeeklySummaryAttentionHeading => 'ما قد يستحق الانتباه';

  @override
  String get v2WeeklySummaryAttentionLoad => 'الحمل قد يستحق نظرة لاحقاً';

  @override
  String get v2WeeklySummaryAttentionSupport =>
      'المزيد من الدعم قد يستحق الانتباه لاحقاً';

  @override
  String get v2WeeklySummaryAttentionPause =>
      'التمهّل أو التركيز بدا منخفضاً هذا الأسبوع';

  @override
  String get v2WeeklySummaryAttentionObstacle => 'برز عائق هذا الأسبوع';

  @override
  String get v2WeeklySummaryAttentionMaintain =>
      'واصل الملاحظة مع الخطة الحالية';

  @override
  String get v2WeeklySummaryEvidenceLimited =>
      'دليل محدود — جلسة مكتملة واحدة فقط';

  @override
  String get v2WeeklySummaryEvidenceDeveloping =>
      'دليل مبكر — اعتبر هذا نظرة هادئة إلى الخلف';

  @override
  String get v2WeeklySummaryEvidenceSufficient => 'ملخص فقط — ليس ادّعاء سبب';

  @override
  String get v2WeeklySummaryPlanUnchanged => 'لم تتغير خطتك بعد';

  @override
  String get v2WeeklySummaryCtaToday => 'العودة إلى اليوم';

  @override
  String get v2WeeklySummaryCtaProgress => 'العودة إلى التقدّم';

  @override
  String get v2WeeklyFactsSection => 'آخر 7 أيام';

  @override
  String get v2WeeklyFactsTasks => 'المهام المكتملة';

  @override
  String v2WeeklyFactsTasksCaption(String count) {
    return '$count خطوات مطلوبة';
  }

  @override
  String get v2WeeklyFactsStreak => 'رحلة التركيز';

  @override
  String v2WeeklyFactsStreakCaption(String current, String best) {
    return '$current الآن · $best الأفضل';
  }

  @override
  String get v2WeeklyFactsAdherence => 'الالتزام بالخطة';

  @override
  String v2WeeklyFactsAdherenceCaption(String days) {
    return '$days من 7 أيام';
  }

  @override
  String get v2ProgressTitle => 'التقدّم';

  @override
  String get v2ProgressOrientation => 'تقدّمك';

  @override
  String get v2ProgressRetry => 'حاول مرة أخرى';

  @override
  String get v2ProgressBasedOnSessions => 'يعتمد التقدّم على الجلسات المكتملة';

  @override
  String get v2ProgressHeadlineEmpty => 'لا جلسات مكتملة بعد';

  @override
  String get v2ProgressHeadlineFirst => 'حُفظت أول جلسة مكتملة لك';

  @override
  String get v2ProgressHeadlineFew => 'بضعة أيام مكتملة مسجّلة';

  @override
  String get v2ProgressHeadlineRhythm => 'بدأت ملامح نمط بالظهور';

  @override
  String get v2ProgressHeadlineSteady => 'يظهر نمط أكثر ثباتاً';

  @override
  String get v2ProgressHeadlineLimited => 'الدليل ما زال محدوداً';

  @override
  String get v2ProgressHeadlineWeekly => 'يتوفر دليل أسبوعي للمراجعة';

  @override
  String get v2ProgressBetterHeading => 'ما هو مسجّل';

  @override
  String get v2ProgressWhyHeading => 'ما يظهر من النمط';

  @override
  String get v2ProgressComparedHeading => 'كيف يقارن مع الوقت';

  @override
  String v2ProgressCompletedDays(String count) {
    return 'الأيام المكتملة: $count';
  }

  @override
  String v2ProgressCompletedSessions(String count) {
    return 'الجلسات المكتملة: $count';
  }

  @override
  String v2ProgressMinimumPath(String count) {
    return 'المسار الأدنى: $count';
  }

  @override
  String v2ProgressStandardPath(String count) {
    return 'المسار القياسي: $count';
  }

  @override
  String v2ProgressCompletionRate(String percent) {
    return 'معدل الأيام المكتملة: $percent%';
  }

  @override
  String v2ProgressCurrentRhythm(int count) {
    return 'الإيقاع الحالي: $count يوم';
  }

  @override
  String v2ProgressLongestRhythm(int count) {
    return 'أطول إيقاع: $count يوم';
  }

  @override
  String v2ProgressFirstCompleted(String day) {
    return 'أول يوم مكتمل: $day';
  }

  @override
  String v2ProgressLastCompleted(String day) {
    return 'آخر يوم مكتمل: $day';
  }

  @override
  String get v2ProgressRecentActivity => 'النشاط الأخير';

  @override
  String get v2ProgressTimelineMinimum => 'المسار الأدنى';

  @override
  String get v2ProgressTimelineStandard => 'المسار القياسي';

  @override
  String get v2ProgressTimelineBothPaths => 'الأدنى والقياسي';

  @override
  String v2ProgressTimelineEntry(String day, String path) {
    return '$day · $path';
  }

  @override
  String get v2ProgressPathMostlyMinimum => 'غالباً المسار الأدنى';

  @override
  String get v2ProgressPathMostlyStandard => 'غالباً المسار القياسي';

  @override
  String get v2ProgressPathBalanced => 'مزيج متوازن من المسارات';

  @override
  String get v2ProgressPathSingle => 'جلسة واحدة فقط';

  @override
  String get v2ProgressEvidenceEmpty =>
      'أكمل فعل اليوم أولاً لتبدأ سجلاً صادقاً.';

  @override
  String get v2ProgressEvidenceLimited =>
      'الدليل ما زال محدوداً — فعل مكتمل واحد حتى الآن.';

  @override
  String get v2ProgressEvidenceDeveloping =>
      'بدأت ملامح نمط بالظهور. هذه ملاحظة وليست تشخيصاً.';

  @override
  String get v2ProgressEvidenceSufficient =>
      'نشاط مكتمل كافٍ لنظرة هادئة إلى الخلف. بلا ادّعاء سبب.';

  @override
  String get v2ProgressScoreHeading => 'لقطة درجة التعافي';

  @override
  String v2ProgressScoreValue(String value) {
    return 'التقدير: $value';
  }

  @override
  String get v2ProgressScoreUnavailable =>
      'تقدير الدرجة غير متاح بعد على هذا الجهاز';

  @override
  String v2ProgressScoreMeasured(String day) {
    return 'من فحص الدماغ بتاريخ $day';
  }

  @override
  String get v2ProgressScoreDisclaimer =>
      'إكمال الجلسة اليومية لا يغيّر هذه الدرجة فوراً. تأتي الدرجة من قياس فحص الدماغ، لا من عدّ الجلسات.';

  @override
  String get v2ProgressWeeklyReviewHeading => 'المراجعة الأسبوعية';

  @override
  String get v2ProgressWrNotEnough =>
      'لا يوجد نشاط مكتمل كافٍ بعد للمراجعة الأسبوعية.';

  @override
  String get v2ProgressWrCurrentWeek =>
      'هذا الأسبوع ما زال جارياً. تُفتَح المراجعة بعد انتهائه.';

  @override
  String v2ProgressWrAvailableInDays(int days) {
    return 'متاح بعد $days أيام';
  }

  @override
  String get v2ProgressWeeklyChartHeading => 'آخر 7 أيام';

  @override
  String get v2ProgressWrAvailable => 'المراجعة الأسبوعية متاحة';

  @override
  String get v2ProgressWrDraft => 'مسودة المراجعة الأسبوعية قيد الإعداد';

  @override
  String get v2ProgressWrCompleted => 'ملخص الأسبوع متاح';

  @override
  String get v2ProgressWrUnsupported =>
      'صيغة هذه المراجعة غير مدعومة في هذا الإصدار.';

  @override
  String get v2ProgressWrMissingRefs =>
      'مصادر المراجعة غير جاهزة بعد. تابع عبر اليوم ثم عُد لاحقاً.';

  @override
  String get v2ProgressWrError => 'تعذّر تجهيز المراجعة الأسبوعية الآن.';

  @override
  String get v2ProgressWrCtaStart => 'ابدأ المراجعة الأسبوعية';

  @override
  String get v2ProgressWrCtaContinue => 'متابعة المراجعة الأسبوعية';

  @override
  String get v2ProgressWrCtaSummary => 'عرض ملخص الأسبوع';

  @override
  String get v2ProgressWeeklyPreviewHeading => 'أحدث ملخص أسبوعي';

  @override
  String get v2ProgressCtaToday => 'أكمل فعل اليوم أولاً';

  @override
  String get v2ProgressCtaContinueToday => 'العودة إلى اليوم';

  @override
  String get v2ProgressReportsEntry => 'فتح التقارير';

  @override
  String get v2ProgressPillarsHeading => 'محاور الدماغ';

  @override
  String get v2ProgressPillarsEmpty =>
      'أكمل تشخيصاً سريعاً لتتبع التركيز والذاكرة وعادات الشاشة والنوم مع الوقت.';

  @override
  String get v2ProgressPillarsFirstDiagnostic => 'ابدأ أول تشخيص';

  @override
  String get v2ProgressLiveVsDayOne => 'الأداء الحي مقابل اليوم الأول';

  @override
  String v2ProgressOverallDelta(String delta) {
    return 'متوسط التغيّر: $delta';
  }

  @override
  String v2ProgressBaselineDate(String date) {
    return 'أول لقطة: $date';
  }

  @override
  String get v2ProgressChartDayOne => 'اليوم 1';

  @override
  String get v2ProgressChartToday => 'اليوم';

  @override
  String get v2ProgressWeeklyRediagnosis => 'إعادة التشخيص الأسبوعي';

  @override
  String get v2ProgressPatternDetails => 'تفاصيل النمط';

  @override
  String get v2ReportsTitle => 'التقارير';

  @override
  String get v2ReportsEvidenceOverview => 'نظرة عامة على الأدلة';

  @override
  String get v2ReportsWeeklyHistory => 'السجل الأسبوعي';

  @override
  String get v2ReportsWeeklyReport => 'تقرير الأسبوع';

  @override
  String get v2ReportsMeasurementHistory => 'سجل القياسات';

  @override
  String get v2ReportsEvidenceStillDeveloping =>
      'ما زالت أدلتك في مرحلة التكوّن';

  @override
  String get v2ReportsNotEnoughMeasurements =>
      'لا توجد قياسات كافية للمقارنة بعد';

  @override
  String get v2ReportsComparedWithEarlier => 'مقارنةً بفحصك السابق';

  @override
  String get v2ReportsSelfReportEstimate =>
      'هذا تقدير قائم على إجاباتك الذاتية';

  @override
  String get v2ReportsNoCauseFromHistory => 'لا يمكن تحديد السبب من هذا السجل';

  @override
  String get v2ReportsOrientation =>
      'تجمع التقارير أدلة محلية صادقة من الجلسات المكتملة وملخصات الأسابيع والقياسات الذاتية الصحيحة.';

  @override
  String get v2ReportsOrientationNot =>
      'التقارير ليست تشخيصاً، وليست نصيحة طبية، وليست مقارنة مع أشخاص آخرين.';

  @override
  String get v2ReportsLoading => 'جارٍ تحميل التقارير';

  @override
  String get v2ReportsRetry => 'إعادة المحاولة';

  @override
  String get v2ReportsPersistFailed =>
      'تعذّر تحميل التقارير الآن. حاول مرة أخرى.';

  @override
  String get v2ReportsUnsupported =>
      'صيغة هذا التقرير غير مدعومة في هذا الإصدار.';

  @override
  String get v2ReportsEmptyBody =>
      'أكمل جلسة اليوم لتبدأ سجلاً محلياً صادقاً. لا يُختلق شيء عندما يكون السجل فارغاً.';

  @override
  String get v2ReportsSnapshotMissing =>
      'لقطة التقدّم المحفوظة مفقودة. تُعرض الأعداد المعاد بناؤها من الجلسات المكتملة فقط.';

  @override
  String get v2ReportsDepthNoEvidence => 'لا توجد أدلة بعد';

  @override
  String get v2ReportsDepthEarly => 'أدلة مبكرة';

  @override
  String get v2ReportsDepthDeveloping => 'أدلة قيد التكوّن';

  @override
  String get v2ReportsDepthEstablished => 'سجل راسخ';

  @override
  String get v2ReportsDepthNoEvidenceExplain =>
      'لا توجد جلسات مكتملة مسجّلة بعد.';

  @override
  String get v2ReportsDepthDevelopingExplain =>
      'الأيام المكتملة وملخصات الأسابيع تبني سجلاً محلياً أوضح.';

  @override
  String get v2ReportsDepthEstablishedExplain =>
      'عدة ملخصات أسبوعية وقياسات تشكّل سجلاً محلياً أطول.';

  @override
  String get v2ReportsSessionSummaryHeading => 'النشاط المكتمل';

  @override
  String v2ReportsCompletedSessions(String count) {
    return 'الجلسات المكتملة: $count';
  }

  @override
  String v2ReportsCompletedDays(String count) {
    return 'الأيام المكتملة: $count';
  }

  @override
  String v2ReportsMinimumPath(String count) {
    return 'المسار الأدنى: $count';
  }

  @override
  String v2ReportsStandardPath(String count) {
    return 'المسار القياسي: $count';
  }

  @override
  String v2ReportsCurrentRhythm(String count) {
    return 'الإيقاع الحالي: $count يوم/أيام';
  }

  @override
  String v2ReportsLongestRhythm(String count) {
    return 'أطول إيقاع: $count يوم/أيام';
  }

  @override
  String v2ReportsFirstCompleted(String day) {
    return 'أول يوم مكتمل: $day';
  }

  @override
  String v2ReportsLastCompleted(String day) {
    return 'آخر يوم مكتمل: $day';
  }

  @override
  String get v2ReportsMeasurementStatusHeading => 'حالة سجل القياسات';

  @override
  String get v2ReportsMeasurementNone => 'لا توجد قياسات صحيحة بعد';

  @override
  String get v2ReportsMeasurementNoneBody =>
      'يؤدي إكمال فحص الدماغ إلى إنشاء قياس ذاتي يمكنك مراجعته هنا.';

  @override
  String get v2ReportsMeasurementBaseline => 'يوجد قياس أساسي واحد مسجّل';

  @override
  String get v2ReportsMeasurementComparable => 'تتوفر قياسات قابلة للمقارنة';

  @override
  String get v2ReportsMeasurementIncompatible =>
      'توجد قياسات لكنها غير قابلة للمقارنة بعد';

  @override
  String get v2ReportsMeasurementErrorBody => 'تعذّر إعداد سجل القياسات الآن.';

  @override
  String v2ReportsLatestScore(String value) {
    return 'أحدث تقدير: $value';
  }

  @override
  String get v2ReportsNoArtifacts => 'لا توجد تقارير أسبوعية بعد';

  @override
  String v2ReportsWeeklyReportPeriod(String start, String end) {
    return 'الأسبوع $start – $end';
  }

  @override
  String v2ReportsPremiumArchiveHint(String count) {
    return '$count تقرير/تقارير أقدم متاحة مع أرشيف Premium';
  }

  @override
  String get v2ReportsPremiumGatedTitle => 'الأرشيف الأقدم';

  @override
  String get v2ReportsPremiumGatedBody =>
      'يبقى أحدث تقرير أسبوعي والتقرير السابق مجانيين. عمق الأرشيف الأقدم جزء من Premium. لا تُخفى الأدلة الحالية.';

  @override
  String get v2ReportsArtifactMissing => 'تقرير الأسبوع غير موجود';

  @override
  String get v2ReportsArtifactMissingBody =>
      'تقرير الأسبوع هذا مفقود أو غير متاح. عد إلى التقارير.';

  @override
  String get v2ReportsArtifactUnsupportedBody =>
      'صيغة تقرير الأسبوع هذا غير مدعومة في هذا الإصدار.';

  @override
  String get v2ReportsArtifactCorrupt => 'تعذّر قراءة تقرير الأسبوع';

  @override
  String get v2ReportsArtifactCorruptBody =>
      'يبدو تقرير الأسبوع هذا غير مكتمل. عد إلى التقارير.';

  @override
  String get v2ReportsCtaLatestArtifact => 'فتح أحدث تقرير أسبوعي';

  @override
  String get v2ReportsOpenMeasurementHistory => 'فتح سجل القياسات';

  @override
  String get v2ReportsCtaToday => 'أكمل فعل اليوم أولاً';

  @override
  String get v2ReportsBackProgress => 'العودة إلى التقدّم';

  @override
  String get v2ReportsBackOverview => 'العودة إلى التقارير';

  @override
  String get v2ReportsComparisonHigher =>
      'تقديرك الذاتي الأخير أعلى من تقديرك السابق.';

  @override
  String get v2ReportsComparisonLower =>
      'تقديرك الذاتي الأخير أقل من تقديرك السابق.';

  @override
  String get v2ReportsComparisonUnchanged =>
      'تقديرك الذاتي الأخير لم يتغيّر عن تقديرك السابق.';

  @override
  String get v2ReportsComparisonNotComparable =>
      'هذه القياسات غير قابلة للمقارنة فيما بينها.';

  @override
  String get v2ReportsTooEarlyToInterpret =>
      'قد يكون الوقت مبكراً لتفسير هذا التغيير.';

  @override
  String get v2ReportsLowConfidenceQualifier =>
      'أحد القياسات على الأقل يحمل قدراً أكبر من عدم اليقين.';

  @override
  String get v2ReportsMeasurementListHeading => 'قياساتك';

  @override
  String v2ReportsMeasuredOn(String day) {
    return 'تاريخ القياس: $day';
  }

  @override
  String v2ReportsScoreValue(String value) {
    return 'التقدير: $value';
  }

  @override
  String v2ReportsScoreBand(String band) {
    return 'النطاق: $band';
  }

  @override
  String v2ReportsScoreConfidence(String confidence) {
    return 'الثقة: $confidence';
  }

  @override
  String v2ReportsMeasurementSemantics(
      String day, String score, String confidence) {
    return 'قياس في $day، تقدير $score، ثقة $confidence';
  }

  @override
  String get v2ReportsConfidenceStrong => 'قوية';

  @override
  String get v2ReportsConfidenceModerate => 'متوسطة';

  @override
  String get v2ReportsConfidenceProvisional => 'أولية';

  @override
  String get v2ReportsDomainHistoryHeading => 'سجل المجالات';

  @override
  String get v2ReportsDomainLatestOnly =>
      'أحدث لقطة للمجالات فقط — لا يوجد سجل مجالات كافٍ للمقارنة بعد.';

  @override
  String v2ReportsDomainRow(String title, String value) {
    return '$title: $value';
  }

  @override
  String v2ReportsDomainHistoryRow(String title, String day, String value) {
    return '$title في $day: $value';
  }

  @override
  String get v2NavHome => 'الرئيسية';

  @override
  String get v2NavToday => 'اليوم';

  @override
  String get v2NavCheck => 'فحص الدماغ';

  @override
  String get v2NavPlan => 'البرنامج';

  @override
  String get v2NavExercises => 'التمارين';

  @override
  String get v2NavProgress => 'التقدم';

  @override
  String get v2NavPro => 'Pro';

  @override
  String get v2NavReports => 'التقارير';

  @override
  String get v2NavProfile => 'الملف';

  @override
  String get v2ExercisesLibraryTitle => 'مكتبة التمارين';

  @override
  String get v2ExercisesFilterAll => 'الكل';

  @override
  String get v2ExercisesFilterFocus => 'تركيز';

  @override
  String get v2ExercisesFilterMemory => 'ذاكرة';

  @override
  String get v2ExercisesFilterSpeed => 'سرعة';

  @override
  String get v2ExercisesFilterReading => 'قراءة';

  @override
  String get v2ExercisesFilterMentalFitness => 'لياقة ذهنية';

  @override
  String get v2ExercisesDifficultyEasy => 'سهل';

  @override
  String get v2ExercisesDifficultyMedium => 'متوسط';

  @override
  String get v2ExercisesDifficultyHard => 'صعب';

  @override
  String v2ExercisesMinutes(int count) {
    return '$count د';
  }

  @override
  String get v2ExercisesSectionFree => 'مجاني';

  @override
  String get v2ExercisesSectionPro => 'Pro';

  @override
  String get v2ExercisesProBadge => 'Pro';

  @override
  String get v2ExercisesEmptyFilter => 'لا توجد تمارين لهذا التصنيف بعد.';

  @override
  String get v2ExercisesNBackTitle => 'N-Back';

  @override
  String get v2ExercisesNBackSubtitle => 'بروتوكول Dual N-Back للذاكرة العاملة';

  @override
  String get v2ExercisesStroopTitle => 'اختبار سترووب';

  @override
  String get v2ExercisesStroopSubtitle =>
      'تثبيط التشتت عبر تسمية لون الحبر لا الكلمة';

  @override
  String get v2ExercisesDigitSpanTitle => 'مدى الأرقام';

  @override
  String get v2ExercisesDigitSpanSubtitle =>
      'احفظ سلاسل أرقام متزايدة وأعد استدعاءها';

  @override
  String get v2ExercisesGoNoGoTitle => 'التحكم الاندفاعي (Go / No-Go)';

  @override
  String get v2ExercisesGoNoGoSubtitle => 'تدريب كبح الاستجابة تحت ضغط الوقت';

  @override
  String get v2ExercisesReadingComprehensionTitle =>
      'قراءة مركّزة + فهم الأسئلة';

  @override
  String get v2ExercisesReadingComprehensionSubtitle =>
      'اقرأ بلا مشتتات ثم أجب عن أسئلة الاستيعاب';

  @override
  String get v2ExercisesHiitTitle => 'تمارين رياضية سريعة للتركيز';

  @override
  String get v2ExercisesHiitSubtitle =>
      'جولات حسابية قصيرة لشحذ الانتباه المستمر';

  @override
  String get v2ExercisesPatternMatchTitle => 'مطابقة الأنماط المرئية';

  @override
  String get v2ExercisesPatternMatchSubtitle =>
      'احفظ نمط الشبكة وأعد إنشاءه من الذاكرة';

  @override
  String get v2ExercisesReadingTitle => 'جلسة قراءة مركّزة (10 دقائق)';

  @override
  String get v2ExercisesReadingSubtitle =>
      'قراءة خالية من المشتتات لزيادة مدى الانتباه';

  @override
  String get v2ExercisesDetoxTitle => 'تحدي الملل (بدون سوشيال ميديا)';

  @override
  String get v2ExercisesDetoxSubtitle =>
      'إعادة ضبط الدوبامين واستعادة الصبر العقلي';

  @override
  String get v2ExercisesAccountabilityTitle => 'صندوق المساءلة اليومية';

  @override
  String get v2ExercisesAccountabilitySubtitle =>
      'تقييم سحب الشاشة والمشتتات بصراحة';

  @override
  String get diagFlowTitle => 'تشخيص سريع';

  @override
  String get diagIntroTitle => '5 أسئلة سريعة';

  @override
  String get diagIntroBody =>
      'أجب بصدق — لا إجابات صحيحة أو خاطئة. هذه اللقطة تساعد على تخصيص برنامج تعافيك.';

  @override
  String get diagIntroMetricsTitle => 'ما الذي نقيسه';

  @override
  String get diagMetricAttention => 'مدى الانتباه';

  @override
  String get diagMetricWorkingMemory => 'الذاكرة العاملة';

  @override
  String get diagMetricScreenHabits => 'عادات الشاشة';

  @override
  String get diagMetricSleepQuality => 'جودة النوم';

  @override
  String get diagIntroDurationHint => 'حوالي دقيقتين · 5 أسئلة';

  @override
  String get diagIntroStart => 'ابدأ التشخيص';

  @override
  String diagQuestionProgress(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String get diagQ1Stem => 'أستطيع البقاء مع مهمة واحدة دون تبديل التطبيقات.';

  @override
  String get diagQ2Stem => 'أستطيع تذكّر عدة أمور في ذهني أثناء العمل.';

  @override
  String get diagQ3Stem => 'ألاحظ عندما أبدأ التصفح بدون هدف.';

  @override
  String get diagQ4Stem => 'أستطيع إبعاد هاتفي أثناء المهام المهمة.';

  @override
  String get diagQ5Stem => 'أستيقظ وأنا أشعر بالراحة في معظم الأيام.';

  @override
  String get diagBack => 'رجوع';

  @override
  String get diagContinue => 'متابعة';

  @override
  String get diagFinish => 'عرض النتيجة';

  @override
  String get diagResultTitle => 'لقطتك';

  @override
  String get diagResultOverallLabel => 'النتيجة الإجمالية';

  @override
  String get diagResultBreakdownTitle => 'تفصيل حسب المجال';

  @override
  String get diagResultWeakestHint => 'تركيز البرنامج الشخصي';

  @override
  String diagResultPlanUpdated(String area) {
    return 'تم تحديث برنامجك ليدعم $area أولاً.';
  }

  @override
  String get diagResultPlanUpdating => 'جاري تحديث برنامجك الشخصي…';

  @override
  String get diagResultPlanError =>
      'تعذّر تحديث البرنامج. يمكنك إعادة المحاولة من برنامجك اليومي.';

  @override
  String get diagResultContinue => 'عرض برنامجي';

  @override
  String get v2NavRecoverHome => 'العودة إلى الرئيسية';

  @override
  String get v2NavRouteNotFound => 'تعذّر العثور على هذه الصفحة';

  @override
  String get v2PremiumTitle => 'بريميوم';

  @override
  String get v2PremiumOrientation =>
      'بريميوم يعمّق الاستمرارية بعد أن تحقق تقدماً ملموساً — ولا يفتح باب التعافي.';

  @override
  String get v2PremiumFreeCoreReassurance =>
      'مسارك المجاني الأساسي يبقى متاحاً.';

  @override
  String get v2PremiumCurrentProgressRemains => 'تقدّمك الحالي يبقى متاحاً.';

  @override
  String get v2PremiumFourCapitalsHeading => 'ما يضيفه بريميوم';

  @override
  String get v2PremiumContinuity => 'الاستمرارية';

  @override
  String get v2PremiumContinuityBody =>
      'أرشيف أعمق لتقارير الأسبوع والأدلة على المدى الطويل.';

  @override
  String get v2PremiumInterpretation => 'التفسير';

  @override
  String get v2PremiumInterpretationBody =>
      'طبقات سياق حتمية مخطّط لها فقط — دون ادعاءات طبية بالذكاء الاصطناعي. غير مفعّلة بعد.';

  @override
  String get v2PremiumFit => 'الملاءمة';

  @override
  String get v2PremiumFitBody =>
      'عمق تكيّف معتمد مستقبلاً دون تغيير صامت للخطة.';

  @override
  String get v2PremiumSupport => 'الدعم';

  @override
  String get v2PremiumSupportBody =>
      'دعم استمرارية مستقبلي بموجب عقد منفصل — دون حصر الاستجابة العاجلة في بريميوم.';

  @override
  String get v2PremiumIncludesNowHeading => 'مشمول في بريميوم الآن';

  @override
  String get v2PremiumIncludeArchive =>
      'أرشيف التقارير الأقدم بعد أحدث إثبات والإثبات السابق';

  @override
  String get v2PremiumIncludeThemes => 'ثيمات ألوان حصرية';

  @override
  String get v2PremiumIncludeTools =>
      'أدوات مختارة: دائرة الأحاسيس، الصمت، الكلمات المتقاطعة، الألعاب، والاختبار المعرفي';

  @override
  String get v2PremiumIncludeChart => 'مخطط التقدّم لسبعة أيام';

  @override
  String get v2PremiumBenefitsBody =>
      'أحدث إثبات أسبوعي والإثبات السابق يبقيان مجانيين. بريميوم يعمّق الاستمرارية — ولا يفتح باب التعافي.';

  @override
  String get v2PremiumPlanMonthlyTitle => 'الباقة الشهرية المميزة';

  @override
  String get v2PremiumPlanMonthlyPrice => '49 ر.س / شهر';

  @override
  String get v2PremiumPlanMonthlySubtitle => 'وصول كامل — إلغاء في أي وقت';

  @override
  String get v2PremiumPlanAnnualTitle => 'الباقة السنوية الموفرة';

  @override
  String get v2PremiumPlanAnnualPrice => '399 ر.س / سنة';

  @override
  String get v2PremiumPlanAnnualSubtitle => 'أفضل قيمة — وفّر مقارنة بالشهرية';

  @override
  String get v2PremiumPlanAnnualBadge => 'وفّر 32%';

  @override
  String get v2PremiumFeaturesHeading => 'كل مزايا Pro';

  @override
  String get v2PremiumFeatureNoAds => 'إزالة كل الإعلانات';

  @override
  String get v2PremiumFeatureBiometric => 'قفل بيومتري للتطبيق';

  @override
  String get v2PremiumFeatureCloudSync => 'مزامنة سحابية بين الأجهزة';

  @override
  String get v2PremiumFeatureStealth => 'أيقونة تمويه (Stealth)';

  @override
  String get v2PremiumFeatureFullStats => 'إحصائيات كاملة ورسوم تفصيلية';

  @override
  String get v2PremiumFeatureWeeklyArchive => 'أرشيف تقارير أسبوعية عميق';

  @override
  String get v2PremiumViewPlans => 'عرض الخطط';

  @override
  String get v2PremiumRestorePurchases => 'استعادة المشتريات';

  @override
  String get v2PremiumPurchaseInProgress => 'جارٍ الشراء';

  @override
  String get v2PremiumPurchaseCompleted => 'اكتمل الشراء';

  @override
  String get v2PremiumPurchaseCancelled => 'أُلغي الشراء';

  @override
  String get v2PremiumPurchaseFailed =>
      'تعذّر الشراء. يمكنك المحاولة مجدداً أو استعادة المشتريات.';

  @override
  String get v2PremiumPurchasePending => 'الشراء معلّق';

  @override
  String get v2PremiumNoPlansAvailable => 'لا تتوفر خطط حالياً.';

  @override
  String get v2PremiumStoreUnavailable => 'المتجر غير متاح';

  @override
  String get v2PremiumRestored => 'تمت الاستعادة';

  @override
  String get v2PremiumNothingToRestore => 'لا يوجد ما يُستعاد';

  @override
  String get v2PremiumRestoreFailed =>
      'تعذّرت الاستعادة. يمكنك المحاولة لاحقاً.';

  @override
  String get v2PremiumRestoring => 'جارٍ استعادة المشتريات';

  @override
  String get v2PremiumSubscriptionExpired => 'انتهى الاشتراك';

  @override
  String get v2PremiumDeeperHistory => 'سجل أعمق';

  @override
  String get v2PremiumOlderArchive => 'أرشيف أقدم';

  @override
  String get v2PremiumManage => 'إدارة بريميوم';

  @override
  String get v2PremiumAlreadyActive => 'بريميوم مفعّل';

  @override
  String get v2PremiumFreeStatus => 'أنت على المسار المجاني الأساسي';

  @override
  String get v2PremiumLoading => 'جارٍ تحميل بريميوم';

  @override
  String get v2PremiumPurchaseCta => 'المتابعة مع بريميوم';

  @override
  String get v2PremiumContinue => 'متابعة';

  @override
  String get v2PremiumPeriodMonthly => 'فوترة شهرية';

  @override
  String get v2PremiumPeriodAnnual => 'فوترة سنوية';

  @override
  String get v2PremiumPeriodLifetime => 'مدى الحياة';

  @override
  String get v2PremiumTermsLink => 'الشروط';

  @override
  String get v2PremiumOfflineCached =>
      'بدون اتصال — يُستخدم وضع بريميوم المحفوظ';

  @override
  String get v2PremiumOfflineUnknown =>
      'بدون اتصال — حالة بريميوم غير معروفة. الشراء يحتاج اتصالاً.';

  @override
  String get v2PremiumUnavailableHere => 'لا يُعرض بريميوم على هذه الشاشة.';

  @override
  String get v2PremiumOpenFromArchive => 'عرض بريميوم للأرشيف الأقدم';

  @override
  String get v2ReportsPremiumOpen => 'فتح بريميوم';

  @override
  String get v2ReportsPremiumRestore => 'استعادة المشتريات';

  @override
  String get v2SafaTitle => 'صفا';

  @override
  String get v2SafaPurpose =>
      'دعم موجز لمساعدتك على المتابعة بخطوة هادئة واحدة.';

  @override
  String get v2SafaAiLimitation =>
      'قد تستخدم صفا خدمة ذكاء اصطناعي عبر الشبكة. ليست رعاية طبية وليست خدمات طوارئ.';

  @override
  String get v2SafaPrivacyNotice =>
      'قبل الإرسال: يُرسل فقط ما تكتبه وما تختاره صراحة. يمكنك المتابعة بدون صفا أو الإلغاء.';

  @override
  String get v2SafaAcknowledgeNotice => 'فهمت';

  @override
  String get v2SafaContinueWithout => 'المتابعة بدون صفا';

  @override
  String get v2SafaConsentBody =>
      'أرسِل فقط رسالتك المكتوبة وأي سياق تختاره. صفا ليست دعمًا طبيًا ولا طوارئ.';

  @override
  String get v2SafaConsentAllow => 'السماح برد واحد عبر الشبكة';

  @override
  String get v2SafaConsentDecline => 'استخدم الدعم دون اتصال';

  @override
  String get v2SafaContextOptionalHeading =>
      'سياق اختياري (لا شيء محدد مسبقًا)';

  @override
  String get v2SafaContextNone => 'بدون سياق إضافي';

  @override
  String get v2SafaContextDifficult => 'لحظة صعبة';

  @override
  String get v2SafaContextClarify => 'توضيح خطوة';

  @override
  String get v2SafaContextContinue => 'مساعدة على المتابعة';

  @override
  String get v2SafaIncludeApprovedContext =>
      'ضمّن سياقًا قصيرًا أوافق عليه لهذا الإرسال فقط';

  @override
  String get v2SafaInputLabel => 'رسالتك';

  @override
  String get v2SafaInputHint => 'اكتب باختصار ما تحتاج المساعدة فيه';

  @override
  String get v2SafaSend => 'إرسال';

  @override
  String get v2SafaSending => 'جارٍ الإرسال';

  @override
  String get v2SafaResponseHeading => 'رد صفا';

  @override
  String get v2SafaSuggestedReturn => 'العودة إلى حيث توقفت';

  @override
  String get v2SafaSuggestedReturnToday => 'العودة إلى اليوم';

  @override
  String get v2SafaFallbackGrounding => 'تهدئة: خذ دقيقة هادئة قبل المتابعة';

  @override
  String get v2SafaFallbackSimplify => 'تبسيط: نفّذ أصغر خطوة تالية فقط';

  @override
  String get v2SafaRetry => 'إعادة المحاولة';

  @override
  String get v2SafaUseLocalFallback => 'استخدم الدعم دون اتصال';

  @override
  String get v2SafaOffline =>
      'أنت دون اتصال — إليك خطوة تهدئة قصيرة يمكنك فعلها الآن.';

  @override
  String get v2SafaTimeout => 'انتهت مهلة الطلب. الدعم دون اتصال متاح.';

  @override
  String get v2SafaServiceUnavailable =>
      'صفا غير متصلة الآن — جرّب تنفسًا بطيئًا أو بسّط خطوتك التالية.';

  @override
  String get v2SafaOfflineTipTitle => 'نصيحة دون اتصال';

  @override
  String get v2SafaOfflineTipBody =>
      'تنفس شهيقًا لـ 4 عدّات، احبس 2، ازفر لـ 6. ثم عد إلى اليوم وأنهِ كتلة تركيز قصيرة واحدة.';

  @override
  String get v2SafaInvalidResponse =>
      'تعذّر عرض الرد بأمان. الدعم دون اتصال متاح.';

  @override
  String get v2SafaInputTooLong => 'يُرجى اختصار رسالتك (الحد الأقصى 500 حرف).';

  @override
  String get v2SafaSessionComplete =>
      'وصلت جلسة الدعم هذه إلى حدها. اختر خطوة تالية أو غادر.';

  @override
  String get v2SafaClearSession => 'مسح هذه الجلسة';

  @override
  String get v2SafaReturn => 'رجوع';

  @override
  String get v2SafaUrgentHelp => 'أحتاج مساعدة عاجلة';

  @override
  String get v2SafaUrgentBody =>
      'توقف صفا المحادثة هنا. لا تستطيع صفا تقديم رعاية الطوارئ.';

  @override
  String get v2SafaUrgentLocalEmergency =>
      'إذا كنت قد تكون في خطر فوري، اتصل بخدمات الطوارئ المحلية. هذا التطبيق لا يحل محلها.';

  @override
  String get v2SafaNotMedical => 'صفا ليست دعمًا طبيًا ولا طوارئ.';

  @override
  String get v2SafaOnlyTypedSent => 'يُرسل فقط ما تكتبه وتختاره.';

  @override
  String get v2SafaStartLater => 'ابدأ جلسة صفا جديدة لاحقًا';

  @override
  String get v2SafaLoading => 'جارٍ فتح صفا';

  @override
  String get v2SafaStateIdle => 'جاهز عندما تكون مستعدًا.';

  @override
  String get v2SafaStateReady => 'يمكنك كتابة رسالة قصيرة.';

  @override
  String get v2SafaStateResponseReady => 'رد موجز جاهز.';

  @override
  String get v2SafaStateLocalFallback => 'الدعم دون اتصال ظاهر أدناه.';

  @override
  String get v2SafaUserCancelled =>
      'تم الإلغاء. يمكنك الرجوع أو المحاولة لاحقًا.';

  @override
  String get v2SafaCleared => 'تم مسح الجلسة.';

  @override
  String v2SafaSessionLimit(String used, String max) {
    return 'جولات الدعم: $used من $max';
  }

  @override
  String get v2SafaEntryToday => 'اطلب دعم صفا';

  @override
  String get v2SafaEntryProfile => 'افتح صفا';

  @override
  String get v2ProfileTitle => 'الملف';

  @override
  String get v2ProfileDefaultIdentity => 'ملفك';

  @override
  String get v2ProfileOrientation =>
      'التفضيلات والخصوصية والضوابط الشخصية — وليس لوحة تقدّم أخرى.';

  @override
  String get v2ProfileSectionRecovery => 'إعداد التعافي';

  @override
  String get v2ProfilePurityHeading => 'رحلة النقاء';

  @override
  String v2ProfilePurityDay(int days) {
    return 'اليوم $days';
  }

  @override
  String get v2ProfilePuritySubtitle => 'أيام على مسار تعافيك منذ البداية';

  @override
  String get v2ProfileNotificationsRow => 'التنبيهات اليومية';

  @override
  String get v2ProfileNotificationsHint => 'تذكيرات الجلسة والمتابعة';

  @override
  String get v2ProfileBrainProfile => 'الملف الدماغي';

  @override
  String get v2ProfileBrainProfileLoading => 'جارٍ التحقق من تقييمك…';

  @override
  String get v2ProfileBrainProfileReady => 'عرض أحدث تقييم لديك';

  @override
  String get v2ProfileBrainProfileMissing => 'أكمل فحص الدماغ لإنشاء هذا';

  @override
  String get v2ProfileBaselineTestTitle => 'فحص أساسي للدماغ';

  @override
  String get v2ProfileBaselineTestSubtitle =>
      'مرة واحدة — يمكنك إعادته في أي وقت';

  @override
  String get v2ProfileWeeklyTestTitle => 'فحص دماغ أسبوعي';

  @override
  String get v2ProfileWeeklyTestSubtitle => 'يُفتح كل 7 أيام';

  @override
  String v2ProfileWeeklyTestLocked(int days) {
    return 'متاح بعد $days أيام';
  }

  @override
  String get v2ProfileWeeklyTestReady => 'جاهز — ابدأ فحص هذا الأسبوع';

  @override
  String get v2ProfileSectionPreferences => 'التفضيلات';

  @override
  String get v2ProfilePreferencesRow => 'التفضيلات والإعدادات';

  @override
  String get v2ProfilePreferencesHint =>
      'المظهر والإشعارات وقفل المقاييس الحيوية والخصوصية والبيانات';

  @override
  String get v2ProfileSectionPrivacy => 'الخصوصية والبيانات';

  @override
  String get v2ProfilePrivacyRow => 'ضوابط الخصوصية والبيانات';

  @override
  String get v2ProfilePrivacyHint => 'مسح البيانات المحلية (يتطلب تأكيداً)';

  @override
  String get v2ProfileSectionSubscription => 'الاشتراك';

  @override
  String get v2ProfileSubscriptionHint => 'حالة بريميوم والخطط والاستعادة';

  @override
  String get v2ProfileSectionHelp => 'المساعدة والدعم';

  @override
  String get v2ProfileHelpHint => 'دعم موجز لخطوة هادئة تالية';

  @override
  String get v2ProfileSectionAbout => 'حول التطبيق';

  @override
  String get v2ProfileEditNameTitle => 'الاسم الظاهر';

  @override
  String get v2ProfileEditNameHint => 'اختياري — يظهر على هذا الجهاز فقط';

  @override
  String get v2ProfileNameSaveFailed => 'تعذّر حفظ الاسم. حاول مرة أخرى.';

  @override
  String get v2ProfileLegalHint => 'يفتح سياسة الخصوصية في المتصفح';

  @override
  String get v2ProfileContactHint => 'يفتح تطبيق البريد';

  @override
  String get settingsOrientation =>
      'المظهر واللغة والإشعارات وحسابك على هذا الجهاز.';

  @override
  String get settingsProfileSection => 'الملف';

  @override
  String get settingsLanguageSection => 'اللغة';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsLogoutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get settingsLogoutConfirmBody =>
      'ستعود إلى بداية التطبيق. تبقى بيانات التعافي على هذا الجهاز حتى تحذفها.';

  @override
  String get settingsDeleteAccount => 'حذف الحساب';

  @override
  String get settingsDeleteAccountConfirmTitle => 'حذف الحساب؟';

  @override
  String get settingsDeleteAccountConfirmBody =>
      'سيتم حذف جميع البيانات المحلية على هذا الجهاز نهائياً. لا يمكن التراجع.';

  @override
  String get colorThemeMorningDark => 'داكن';

  @override
  String get colorThemeMorningLight => 'فاتح';

  @override
  String get colorThemeAmoled => 'أسود';

  @override
  String get colorThemeAmoledName => 'أسود';

  @override
  String get colorThemePureWhiteName => 'أبيض نقي';

  @override
  String get colorThemeWarmBeigeName => 'بيج هادئ';

  @override
  String get settingsThemeDarkSubtitle => 'لوحة Morning Light الداكنة';

  @override
  String get settingsThemeLightSubtitle => 'لوحة Morning Light الفاتحة';

  @override
  String get settingsThemeAmoledSubtitle => 'أسود خالص لشاشات OLED';

  @override
  String get settingsThemePureWhiteSubtitle => 'أبيض نقي مع لمسات خضراء';

  @override
  String get settingsThemeWarmBeigeSubtitle => 'بيج دافئ مع نص بني';

  @override
  String get dailyProgramMindfulness => 'قراءة — ١٥ دقيقة (كتاب أو مقال مفيد)';

  @override
  String get dailyProgramReflection =>
      'مراجعة مسائية — ماذا أنجزت؟ ما الذي سأحسنه غداً؟';

  @override
  String get dailyProgramReading => 'قراءة — ١٥ دقيقة (كتاب أو مقال مفيد)';

  @override
  String get dailyProgramPomodoro => 'بومودورو تركيز — ٢٥ دقيقة مهمة واحدة فقط';

  @override
  String get dailyProgramScreenFree => 'وقت بلا شاشة';

  @override
  String get dailyProgramEveningReview =>
      'مراجعة مسائية — ماذا أنجزت؟ ما الذي سأحسنه غداً؟';

  @override
  String get dailyProgramCognitive => 'تمرين معرفي';

  @override
  String get dailyProgramCognitiveNBack => 'تمرين معرفي — N-Back (٥ دقائق)';

  @override
  String get dailyProgramCognitiveStroop => 'تمرين معرفي — ستروب (٥ دقائق)';

  @override
  String get dailyProgramHeavyPomodoro => 'بومودورو تركيز إضافي';

  @override
  String get dailyProgramStroop => 'تمرين ستروب يومي';

  @override
  String get dailyProgramNBack => 'تدريب N-Back';

  @override
  String get dailyProgramDigitSpan => 'تمرين مدى الأرقام';

  @override
  String get dailyProgramNoMultitask => 'قاعدة لا تعدد مهام';

  @override
  String get dailyProgramSingleScreenRule => 'قاعدة الشاشة الواحدة فقط';

  @override
  String get dailyProgramSearchWaitRule =>
      'سجّل كل ما تريد البحث عنه ثم انتظر ساعة';

  @override
  String get dailyProgramDetoxBlock => 'كتلة ممتدة بلا شاشة';

  @override
  String get dailyProgramAppUsageReview => 'مراجعة استخدام التطبيقات';

  @override
  String get dailyProgramFullRecoveryBlock => 'كتلة تعافٍ كاملة';

  @override
  String get dailyProgramHourlyPlan => 'خطة ساعة بساعة';

  @override
  String get dailyProgramPersonalizedLocked => 'البرنامج اليومي المخصص';

  @override
  String get dailyProgramHourly07 => '٠٧:٠٠ — استيقاظ وترطيب وتمدد خفيف';

  @override
  String get dailyProgramHourly08 => '٠٨:٠٠ — قراءة مركّزة';

  @override
  String get dailyProgramHourly09 => '٠٩:٠٠ — كتلة بومودورو عميقة';

  @override
  String get dailyProgramHourly10 => '١٠:٠٠ — حركة / مشي';

  @override
  String get dailyProgramHourly11 => '١١:٠٠ — كتلة بومودورو عميقة';

  @override
  String get dailyProgramHourly12 => '١٢:٠٠ — وجبة وراحة قصيرة (بدون فيدز)';

  @override
  String get dailyProgramHourly13 => '١٣:٠٠ — كتلة بومودورو عميقة';

  @override
  String get dailyProgramHourly14 => '١٤:٠٠ — كتلة تعافٍ بلا شاشة';

  @override
  String get dailyProgramHourly15 =>
      '١٥:٠٠ — تمارين معرفية (N-Back + مدى الأرقام)';

  @override
  String get dailyProgramHourly16 => '١٦:٠٠ — كتلة بومودورو عميقة';

  @override
  String get dailyProgramHourly17 => '١٧:٠٠ — استراحة خارجية / ضوء شمس';

  @override
  String get dailyProgramHourly18 => '١٨:٠٠ — تركيز خفيف بمهمة واحدة';

  @override
  String get dailyProgramHourly19 => '١٩:٠٠ — بداية غروب رقمي';

  @override
  String get dailyProgramHourly20 => '٢٠:٠٠ — قراءة هادئة';

  @override
  String get dailyProgramHourly21 => '٢١:٠٠ — مراجعة مسائية مكتوبة';

  @override
  String get dailyProgramHourly22 => '٢٢:٠٠ — تهدئة والاستعداد للنوم';

  @override
  String dailyProgramActivityLine(String title, int minutes) {
    return '$title — $minutes دقائق';
  }

  @override
  String get settingsActionFailed => 'تعذّر إكمال هذا الإجراء. حاول مرة أخرى.';

  @override
  String get testsCatalogTitle => 'الاختبارات';

  @override
  String get testsCatalogSubtitle =>
      'فحوصات سريعة للاستدلال وعادات الشاشة والتركيز والذاكرة.';

  @override
  String get homeQuickTestsHeading => 'اختبارات سريعة';

  @override
  String get homeQuickTestIq => 'الذكاء';

  @override
  String get homeQuickTestDigitalBrainRot => 'تعفن رقمي';

  @override
  String get homeQuickTestFocus => 'تركيز';

  @override
  String get homeQuickTestMemory => 'ذاكرة';

  @override
  String get homeQuickTestAll => 'كل الاختبارات';

  @override
  String get v2ProfileTestsCatalogTitle => 'كتالوج الاختبارات';

  @override
  String get v2ProfileTestsCatalogSubtitle => 'ذكاء، تعفن رقمي، تركيز، وذاكرة';

  @override
  String quickTestProgress(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String get iqTestTitle => 'فحص الذكاء';

  @override
  String get iqTestSubtitle => '5 أسئلة استدلال وأنماط';

  @override
  String get iqTestContinue => 'متابعة';

  @override
  String get iqTestFinish => 'عرض النتيجة';

  @override
  String get iqTestDone => 'العودة إلى الرئيسية';

  @override
  String get iqTestResultTitle => 'نتيجة الاستدلال';

  @override
  String iqTestResultDetail(int correct, int total) {
    return '$correct من $total صحيحة';
  }

  @override
  String get iqTestDisclaimer =>
      'لقطة تدريبية قصيرة — وليست اختبار ذكاء سريرياً.';

  @override
  String get iqQ1Stem => 'أي رقم يكمل النمط: 2، 4، 8، 16، ؟';

  @override
  String get iqQ1OptA => '18';

  @override
  String get iqQ1OptB => '24';

  @override
  String get iqQ1OptC => '32';

  @override
  String get iqQ1OptD => '30';

  @override
  String get iqQ2Stem => 'أوجد المختلف: دائرة، مربع، مثلث، تفاحة';

  @override
  String get iqQ2OptA => 'دائرة';

  @override
  String get iqQ2OptB => 'تفاحة';

  @override
  String get iqQ2OptC => 'مربع';

  @override
  String get iqQ2OptD => 'مثلث';

  @override
  String get iqQ3Stem =>
      'إذا اكتسب كل شكل ضلعاً إضافياً في كل خطوة (مثلث ← مربع ← خماسي)، ما التالي؟';

  @override
  String get iqQ3OptA => 'مثلث';

  @override
  String get iqQ3OptB => 'مربع';

  @override
  String get iqQ3OptC => 'خماسي';

  @override
  String get iqQ3OptD => 'سداسي';

  @override
  String get iqQ4Stem => 'أكمل التشبيه: الكتاب للقراءة كما الشوكة لـ ؟';

  @override
  String get iqQ4OptA => 'الأكل';

  @override
  String get iqQ4OptB => 'المطبخ';

  @override
  String get iqQ4OptC => 'المعدن';

  @override
  String get iqQ4OptD => 'الطبق';

  @override
  String get iqQ5Stem =>
      'في شبكة 3×3، الخلية الناقصة التي تجعل مجموع كل صف 15 هي؟';

  @override
  String get iqQ5OptA => '2';

  @override
  String get iqQ5OptB => '4';

  @override
  String get iqQ5OptC => '6';

  @override
  String get iqQ5OptD => '9';

  @override
  String get digitalBrainRotTestTitle => 'تعفن الدماغ الرقمي';

  @override
  String get digitalBrainRotTestSubtitle =>
      '8 أسئلة عن الشاشات والتصفح ومدى الانتباه';

  @override
  String get digitalBrainRotContinue => 'متابعة';

  @override
  String get digitalBrainRotFinish => 'عرض درجة الصفاء';

  @override
  String get digitalBrainRotDone => 'العودة إلى الرئيسية';

  @override
  String get digitalBrainRotResultTitle => 'الصفاء الرقمي';

  @override
  String get digitalBrainRotResultClarityLabel => 'درجة الصفاء (الأعلى أصح)';

  @override
  String get digitalBrainRotResultHealthy => 'عادات شاشتك تبدو مستقرة نسبياً.';

  @override
  String get digitalBrainRotResultModerate =>
      'هناك بعض الاحتكاك — كتل تركيز قصيرة قد تساعد.';

  @override
  String get digitalBrainRotResultHigh =>
      'جذب الشاشة قوي الآن — احمِ نوافذ انتباهك.';

  @override
  String get digitalBrainRotDisclaimer =>
      'تقرير ذاتي فقط — وليس تشخيصاً طبياً.';

  @override
  String get digitalBrainRotQ1Stem => 'أفتح تطبيقات التواصل بدون هدف واضح.';

  @override
  String get digitalBrainRotQ2Stem =>
      'أصعب عليّ البقاء مع مهمة واحدة لمدة 10 دقائق.';

  @override
  String get digitalBrainRotQ3Stem => 'أتصفح بعد وقت النوم في أغلب الليالي.';

  @override
  String get digitalBrainRotQ4Stem =>
      'الفيديوهات القصيرة تجعل القراءة الطويلة أصعب.';

  @override
  String get digitalBrainRotQ5Stem => 'أتحقق من هاتفي خلال دقائق من الاستيقاظ.';

  @override
  String get digitalBrainRotQ6Stem => 'الإشعارات تسحبني أثناء المحادثة.';

  @override
  String get digitalBrainRotQ7Stem =>
      'أشعر بالقلق عندما أترك هاتفي في غرفة أخرى.';

  @override
  String get digitalBrainRotQ8Stem => 'أستطيع إبعاد هاتفي أثناء العمل المهم.';
}
