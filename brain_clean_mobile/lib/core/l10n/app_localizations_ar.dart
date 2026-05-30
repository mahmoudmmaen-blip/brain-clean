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
  String get cognitiveVisualTestSubtitle => 'انتباه وتمييز أنماط (قريباً)';

  @override
  String get cognitiveMemoryGameTitle => 'ألعاب الذاكرة';

  @override
  String get cognitiveMemoryGameSubtitle =>
      'مهام تسلسل الذاكرة العاملة (قريباً)';

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
  String get homeStreakDays => 'أيام';

  @override
  String get homeStreakHours => 'ساعات';

  @override
  String get homeStreakMinutes => 'دقائق';

  @override
  String get homeStreakSeconds => 'ثوانٍ';

  @override
  String get homeDistractionButton => 'تشتت مؤقت';

  @override
  String get homeDistractionConfirmTitle => 'تأكيد التشتت';

  @override
  String get homeDistractionConfirmMessage =>
      'هل أنت متأكد؟ سيتم خصم 12 ساعة من streak.';

  @override
  String get homeDistractionConfirm => 'تأكيد';

  @override
  String get homeDistractionCancel => 'إلغاء';

  @override
  String get homeOpenAccountability => 'غرفة المساءلة الرقمية';

  @override
  String get accountabilityRoomTitle => 'غرفة المساءلة الرقمية';

  @override
  String get accountabilityPenaltyRecorded => 'تم تسجيل العقوبة ✓';

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
  String get accountabilityPenMental1 => 'تخطي تمارين التنفس';

  @override
  String get accountabilityPenMental2 => 'تجنب التدوين';

  @override
  String get accountabilityPenMental3 => 'حلقة أفكار سلبية';

  @override
  String get accountabilityPenMental4 => 'تفويت فحص ذهني';

  @override
  String get accountabilityPenMental5 => 'إدمان شاشة متصاعد';

  @override
  String get breathingInhale => 'استنشق...';

  @override
  String get breathingHold => 'احتبس...';

  @override
  String get breathingExhale => 'أخرج...';

  @override
  String breathingCountdownSeconds(int seconds) {
    return 'متبقي $seconds ثانية';
  }

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
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAccountSection => 'الحساب';

  @override
  String get settingsProActive => 'Brain Clean Pro ✓';

  @override
  String get settingsUpgradeToPro => 'ترقية إلى Pro';

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
  String get homeDistractionConfirmAction => 'تأكيد التشتت';

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
  String get profileBadgeStreak7 => '7 أيام متواصلة';

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
  String get accountabilityModalCatAltruistic => 'العمل الخيري';

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
  String get breathingInhaleSlow => 'استنشق ببطء...';

  @override
  String get breathingExhaleFull => 'أخرج الهواء...';

  @override
  String get asyncErrorRetry => 'حدث خطأ، حاول مجدداً';

  @override
  String get chartEmptyState => 'لا توجد بيانات بعد، ابدأ رحلتك اليوم';

  @override
  String get homeStreakMotivation => 'ابدأ أول جلسة تركيز الآن 🚀';

  @override
  String get dailyQuoteSource => 'علم الأعصاب';

  @override
  String get streakFreezeConfirm =>
      'هل تريد تجميد الـ Streak؟ متاح مرة أسبوعياً';

  @override
  String get shareProgressLabel => 'شارك تقدمك';

  @override
  String levelPointsToNext(int points) {
    return '$points نقطة للمستوى التالي';
  }

  @override
  String get weeklyReportTitle => 'تقرير الأسبوع';

  @override
  String get weeklyReportStreakDays => 'أيام التركيز هذا الأسبوع';

  @override
  String get weeklyReportAvgBcs => 'متوسط BCS';

  @override
  String get weeklyReportBestEmotion => 'أبرز إحساس';

  @override
  String get weeklyReportChallenges => 'التحديات المكتملة';
}
