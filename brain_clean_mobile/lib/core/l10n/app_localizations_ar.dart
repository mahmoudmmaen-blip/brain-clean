// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get dashboardTitle => 'مؤشر الصفاء';

  @override
  String get dashboardEmptyDiagnosticPrompt =>
      'أكمل فحص التركيز لعرض مؤشر الصفاء.';

  @override
  String get dashboardEmptyTitle => 'رحلتك تبدأ من هنا';

  @override
  String get dashboardEmptySubtitle => 'مع البرنامج اليومي سيظهر تقدّمك هنا';

  @override
  String get dashboardEmptyCta => 'ابدأ الفحص القصير';

  @override
  String get dashboardRetakeDiagnostic => 'إعادة فحص التركيز';

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
  String get diagnosticTitle => 'مؤشر الصفاء';

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
  String get accountabilityAdjustment => 'ملاحظة المساءلة';

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
  String get detoxSyncing => 'جارٍ الحفظ…';

  @override
  String get detoxSyncError =>
      'تعذّر إكمال الحفظ. تسجيلك محفوظ على هذا الجهاز.';

  @override
  String get diagnosticBrainRotTitle => 'فحص التركيز';

  @override
  String get diagnosticBhiTitle => 'تقييم العادات الرقمية';

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
  String get diagnosticBrainRotScoreTitle => 'مؤشر الصفاء';

  @override
  String diagnosticBrainRotScoreOutOf(int max) {
    return 'من $max';
  }

  @override
  String diagnosticBrainRotBandRange(int min, int max) {
    return 'نطاق الشدة: $min–$max';
  }

  @override
  String get diagnosticBrainRotInterpretationTitle => 'ماذا تقول إجاباتك';

  @override
  String get diagnosticContinueToBhi => 'متابعة تقييم العادات الرقمية';

  @override
  String get diagnosticReviewAnswers => 'مراجعة إجاباتي';

  @override
  String get diagnosticBrainRotIncomplete => 'أكمل الأسئلة العشرة أولاً.';

  @override
  String get diagnosticBrainRotScoring => 'جارٍ حساب نتيجتك…';

  @override
  String get diagnosticSyncError => 'تعذر حفظ فحص التركيز. حاول مرة أخرى.';

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
    return 'مؤشر الصفاء: $score/10';
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
  String get splashInitError => 'تعذر إكمال التحميل. أعد فتح التطبيق من فضلك.';

  @override
  String get homeTitle => 'الرئيسية — Brain Clean';

  @override
  String get homeEmptyDiagnosticPrompt =>
      'أكمل فحص التركيز لتفعيل متتبع الصفاء المباشر.';

  @override
  String get homeChallengeProgressTitle => 'تحدي التعافي — 30 يوماً';

  @override
  String homeChallengeProgressPercent(int percent) {
    return '$percent% مكتمل';
  }

  @override
  String get homeOpenDiagnostic => 'فحص وضوح قصير';

  @override
  String get homeOpenDiagnosticSubtitle => 'استبيان قصير + مقاييس التركيز';

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
  String get cognitiveHubEmptyHint => 'لم تُجرِ أي اختبار بعد — جرّب الآن!';

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
      'فحص التركيز جاهز عندما تكون مستعداً. جرّب جولة قصيرة لترى الإحساس.';

  @override
  String get cognitivePlaceholderComplete => 'احفظ نتيجة هذه الممارسة';

  @override
  String cognitivePlaceholderRecorded(int score) {
    return 'تم حفظ نتيجة الممارسة: $score%';
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
  String get recoverySleepCheckTitle => 'جودة النوم';

  @override
  String get recoverySleepCheckSubtitle =>
      'نوم كافٍ ومنتظم اليوم (20% من تقييم اليوم)';

  @override
  String get recoveryWaterCheckTitle => 'شرب المياه';

  @override
  String get recoveryWaterCheckSubtitle =>
      'ترطيب كافٍ اليوم (20% من تقييم اليوم)';

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
      'احتاجت البيانات المحلية لبداية جديدة. تقدّمك يبدأ من اليوم.';

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
  String get accountabilityPenMental5 => 'يوم شاشات ثقيل';

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
  String get onboardingPage1Body => 'ابنِ هدوءاً رقمياً يوماً بعد يوم';

  @override
  String get onboardingPage2Title => 'برنامجك اليومي';

  @override
  String get onboardingPage2Body =>
      'كل يوم: تهيئة، تركيز، تأمّل، إكمال، وراحة — برفق';

  @override
  String get onboardingPage3Title => 'ابدأ رحلتك الآن';

  @override
  String get onboardingPage3Body =>
      'فحص قصير أولاً — ثم البرنامج اليومي يرافقك كل يوم';

  @override
  String get onboardingStartQuiz => 'متابعة';

  @override
  String get proPaywallTitle => 'Brain Clean Pro';

  @override
  String get proPaywallSubtitle => 'افتح مزايا Pro الهادئة';

  @override
  String get proFeatureAdvancedBcs => 'محرك Brain Clarity Score المتقدم';

  @override
  String get proFeatureSevenDayChart => 'مخطط التقدم 7 أيام';

  @override
  String get proFeatureEmotionWheel => 'رؤى أعمق عن المشاعر والعادات';

  @override
  String get proFeatureFocusChallenges => 'جلسات سكون وتركيز أطول';

  @override
  String get proFeatureAdvancedReports => 'رؤى صفاء متقدمة لـ 30 / 90 يوماً';

  @override
  String get proFeatureExportData => 'تصدير بياناتك المحلية';

  @override
  String get proFeatureCustomReminders => 'تذكيرات مخصّصة';

  @override
  String get proFeatureExtraQuotes => 'مكتبة اقتباسات يومية أوسع';

  @override
  String get proFeatureCloudSync => 'رؤى Pro إضافية';

  @override
  String get proFeatureColorThemes => '4 ثيمات ألوان حصرية لـ Pro';

  @override
  String get proWelcomeSnack => 'مرحباً بك في Pro! 🎉';

  @override
  String get proPriceMonthly => 'مزايا Pro اختيارية';

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
  String get proPurchaseError =>
      'حدث خطأ أثناء إتمام العملية. من فضلك حاول مرة أخرى.';

  @override
  String get proPlansUnavailable =>
      'الباقات غير متاحة الآن. جرّب لاحقًا أو استخدم الاستعادة إذا كنت مشتركًا.';

  @override
  String get paywallRetryLoad => 'إعادة المحاولة';

  @override
  String get paywallLifetimeLabel => 'ادفع مرة واحدة واستمر للأبد';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAccountSection => 'الاشتراك';

  @override
  String get settingsProActive => 'Brain Clean Pro ✓';

  @override
  String get settingsUpgradeToPro => 'ترقية إلى Pro';

  @override
  String get settingsProCardTitle => 'Brain Clean Pro';

  @override
  String get settingsProStatusFree => 'مجاني';

  @override
  String get settingsProStatusPro => 'Pro';

  @override
  String get settingsProBenefitHint =>
      'Pro يفتح مزايا إضافية بدون تغيير البرنامج اليومي الأساسي.';

  @override
  String get settingsRestorePurchases => 'استعادة المشتريات';

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
  String get colorThemeSlateName => 'أردوازي';

  @override
  String get colorThemeDaylightName => 'ضوء النهار';

  @override
  String get settingsNotificationsSection => 'الإشعارات';

  @override
  String get settingsEmotionNotifications => 'تنبيهات الأحاسيس السلبية';

  @override
  String get settingsDailyFocusReminder => 'تذكير يومي بالتركيز';

  @override
  String get settingsDailyReminder => 'تذكير يومي';

  @override
  String get settingsDailyReminderSub => 'تذكير يومي الساعة 9 صباحاً';

  @override
  String get notifDailyTitle => 'حان وقت تمرينك اليومي 🧠';

  @override
  String get notifDailyBody => 'افتح Brain Clean وابدأ يومك بتركيز';

  @override
  String get settingsDataSection => 'البيانات';

  @override
  String get settingsResetData => 'إعادة تعيين البيانات';

  @override
  String get settingsResetDataConfirmTitle => 'إعادة تعيين البيانات';

  @override
  String get settingsResetDataConfirmBody =>
      'سيُمسح كل التقدم المحلي واليوميات والبرنامج اليومي والإعدادات على هذا الجهاز، وستبدأ من جديد. مفاتيح التشفير تُبقى. هل تريد المتابعة؟';

  @override
  String get settingsExportData => 'تصدير البيانات — قريبًا';

  @override
  String get settingsExportDataPro => 'تصدير البيانات';

  @override
  String get settingsExportReadyBody => 'شارك ملخصاً محلياً لتقدّمك.';

  @override
  String get settingsExportShared => 'ملخص التقدّم المحلي جاهز للمشاركة.';

  @override
  String get settingsExportProOnly => 'التصدير ميزة Pro.';

  @override
  String get settingsComingSoon => 'قريباً...';

  @override
  String get settingsAdvancedInsightsTitle => 'رؤى 30 / 90 يوماً';

  @override
  String get settingsAdvancedInsightsLocked =>
      'افتح رؤى الصفاء المتقدمة مع Pro.';

  @override
  String get settingsCustomRemindersLocked =>
      'جداول التذكير المخصّصة تُفتح مع Pro.';

  @override
  String get silenceDurationProLocked => 'الجلسات الأطول تُفتح مع Pro.';

  @override
  String get settingsAboutSection => 'حول التطبيق';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsPrivacyOptions => 'خيارات الخصوصية';

  @override
  String get settingsContactUs => 'تواصل معنا';

  @override
  String get settingsLinkOpenFailed => 'تعذر فتح الرابط على هذا الجهاز.';

  @override
  String get settingsLocalModeHint => 'بياناتك محفوظة على هذا الجهاز.';

  @override
  String get emotionWheelTitle => 'عجلة المشاعر';

  @override
  String get emotionImpactDialogTitle => 'تسجيل الشعور';

  @override
  String get emotionLogDialogBody =>
      'تسجيل هذا الشعور يساعدك تفهم يومك ويتابع تقدّمك بهدوء. هل تريد تسجيله؟';

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
  String get silenceChallengeDurationLabel => 'مدة الجلسة';

  @override
  String silenceChallengeDurationOption(int minutes) {
    return '$minutes د';
  }

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
  String get profileNoEmotionsYet =>
      'لم تسجّل أي مشاعر بعد — جرّب عجلة المشاعر عندما تكون مستعداً';

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
  String shareScoreText(int score) {
    return 'حققت نتيجة $score في اختبار Brain Clean! 🧠\nحمّل التطبيق وابدأ رحلتك:';
  }

  @override
  String shareProfileText(int level) {
    return 'أنا في مستوى $level في Brain Clean! 🏆\nانضم إليّ:';
  }

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

  @override
  String get weeklyReportEmpty =>
      'لا توجد بيانات هذا الأسبوع — استمر في التحدي!';

  @override
  String get weeklyReportEmptyCta => 'عُد للرئيسية';

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
    return 'تشتت مسجّل: $count';
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
  String get bciCardTitle => 'صفاء الدماغ (BCI)';

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
  String get bciOneLiner =>
      '٦٠٪ تقييمك الأسبوعي + ٤٠٪ التزامك اليومي آخر 7 أيام';

  @override
  String get bciFullExplanation =>
      'صفاء الدماغ (BCI) رقم حي بين 0 و100 بيتجدد يومياً. 60% منه جاي من نتيجة تقييمك الأسبوعي (اختبار BHI ووضوح الذهن)، و40% من مدى التزامك ببروتوكول التعافي في آخر 7 أيام. لو لسه معملتش التقييم الأسبوعي، الرقم بيتحسب من الالتزام بس.';

  @override
  String get calmIndexOneLiner =>
      'عكس نتيجة اختبار القلق — كل ما قلّ القلق، زاد الهدوء';

  @override
  String get calmIndexFullExplanation =>
      'مؤشر الهدوء بيتحسب من نتيجة اختبار القلق بتاعك: 100 ناقص درجة القلق. يظهر على الرسم البياني لما يكون عندك نتيجتين على الأقل من اختبار القلق، والأيام اللي بينهم بتتحسب تقريبياً بالتدرج.';

  @override
  String get metricInfoA11yLabel => 'ما معنى هذا الرقم؟';

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
  String get biometricFallbackPin => 'استخدم رمز PIN بدلاً من ذلك';

  @override
  String get securityCompromisedBanner => 'بياناتك محفوظة على هذا الجهاز.';

  @override
  String get emotionOasisTitle => 'واحة المشاعر — صفا';

  @override
  String get emotionOasisHint => 'شاركني ما تشعر به الآن...';

  @override
  String get emotionOasisAnalyze => 'تحدث مع صفا';

  @override
  String get emotionOasisPromptLabel => 'ما الذي يشغل تفكيرك؟';

  @override
  String get navTabHome => 'الرئيسية';

  @override
  String get navTabExercises => 'التمارين';

  @override
  String get navTabSafa => 'صفا';

  @override
  String get navTabJourney => 'رحلتي';

  @override
  String get navTabMore => 'المزيد';

  @override
  String get sosFabTooltip => 'مساعدة سريعة';

  @override
  String get exercisesTabTitle => 'التمارين';

  @override
  String get exercisesCardCognitiveHubTitle => 'مكتبة التمارين';

  @override
  String get exercisesCardCognitiveHubSubtitle => '20 تمرين معتمد علمياً';

  @override
  String get exercisesCardPomodoroTitle => 'بومودورو';

  @override
  String get exercisesCardPomodoroSubtitle => 'تركيز 25 دقيقة';

  @override
  String get exercisesCardBreathingTitle => 'تمرين التنفس';

  @override
  String get exercisesCardBreathingSubtitle => '4·4·4·4 مربّع';

  @override
  String get exercisesCardGamesTitle => 'ألعاب معرفية';

  @override
  String get exercisesCardGamesSubtitle => 'تحدّ دماغك';

  @override
  String get exercisesCardSingleTaskTitle => 'مهمة واحدة';

  @override
  String get exercisesCardSingleTaskSubtitle => 'التركيز الأحادي';

  @override
  String get exercisesCardDeepThinkingTitle => 'تفكير عميق';

  @override
  String get exercisesCardDeepThinkingSubtitle => '10 دقائق بلا تشتيت';

  @override
  String get exercisesCardSukoonTitle => 'سكون';

  @override
  String get exercisesCardSukoonSubtitle => 'استراحة يقظة — صفّي ذهنك';

  @override
  String get safaTabTitle => 'صفا';

  @override
  String get safaTabSubtitle => 'مرشدتك الذكية · هنا لما تحتاجها';

  @override
  String get safaTalkButton => 'تحدّثي مع صفا';

  @override
  String get safaOasisButton => 'واحة المشاعر';

  @override
  String get safaTrialExpiredMessage =>
      'خلصت فترة تجربة صفا المجانية — كمّلي معاها بالاشتراك في Pro';

  @override
  String get safaMedicalDisclaimer =>
      'صفا مساعد دعم ذاتي بالذكاء الاصطناعي، وليس بديلًا عن مختص. لو شعرت أن الموضوع أكبر من قدرتك، اطلب دعمًا من شخص مؤهل.';

  @override
  String get journeyTabTitle => 'رحلتي';

  @override
  String get journeyCardBciTitle => 'مؤشر صفاء الدماغ BCI';

  @override
  String get journeyCardDiagnosticTitle => 'فحص التركيز';

  @override
  String get journeyCardWeeklyReportTitle => 'التقرير الأسبوعي';

  @override
  String get journeyQuickLinksTitle => 'روابط سريعة';

  @override
  String get moreTabTitle => 'المزيد';

  @override
  String get moreProfile => 'الملف الشخصي';

  @override
  String get moreSettings => 'الإعدادات';

  @override
  String get morePro => 'Brain Clean Pro';

  @override
  String get moreAccountability => 'شريك المتابعة';

  @override
  String moreVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get homeGreetingMorning => 'صباح الخير ☀️';

  @override
  String get homeGreetingAfternoon => 'مساء الخير 🌤️';

  @override
  String get homeGreetingEvening => 'مساء الخير 🌙';

  @override
  String get homeHeroName => 'يا بطل';

  @override
  String get homeStreakLabel => 'يوم متواصل';

  @override
  String get homeBciLabel => 'مؤشر صفاء الدماغ';

  @override
  String get homeBciTrend => '↑ هذا الأسبوع';

  @override
  String get homeActivitiesTitle => 'أنشطة اليوم';

  @override
  String get homeActivitiesOf => 'من';

  @override
  String get homeSafaMessage => 'فخورة بيك! كمّل كده 💚';

  @override
  String get homeProFeature => 'رؤى وتقارير أعمق';

  @override
  String get homeActivityExercise => 'تمرين';

  @override
  String get homeActivityWater => 'مياه';

  @override
  String get homeActivitySleep => 'نوم';

  @override
  String get homeActivityMovement => 'حركة';

  @override
  String get settingsSubscriptionSection => 'الاشتراك';

  @override
  String get anxietyScreenTitle => 'تشخيص القلق';

  @override
  String get anxietyResultTitle => 'نتيجة تشخيص القلق';

  @override
  String anxietyProgressLabel(int current, int total) {
    return '$current / $total';
  }

  @override
  String get anxietyQ1 => 'هل تفكّر كثيراً قبل النوم؟';

  @override
  String get anxietyQ2 => 'هل تعيد السيناريو في راسك أكثر من مرة؟';

  @override
  String get anxietyQ3 => 'هل تتوقّع الأسوأ غالباً؟';

  @override
  String get anxietyQ4 => 'هل يصعُب عليك إيقاف التفكير؟';

  @override
  String get anxietyQ5 => 'هل تشعر أن عقلك يعمل طوال الوقت؟';

  @override
  String get anxietyQ6 =>
      'هل تلاحظ توتراً جسدياً (كتف مشدود، معدة، تنفّس سريع)؟';

  @override
  String get anxietyQ7 => 'هل تتجنّب مهام أو مواقف بسبب القلق منها؟';

  @override
  String get anxietyQ8 => 'هل يؤثر القلق على تركيزك أو نومك بشكل يومي؟';

  @override
  String get anxietyOptionNever => 'أبداً';

  @override
  String get anxietyOptionSometimes => 'أحياناً';

  @override
  String get anxietyOptionOften => 'غالباً';

  @override
  String get anxietyOptionAlways => 'دائماً';

  @override
  String get anxietyLevelCalm => 'هادئ';

  @override
  String get anxietyLevelModerate => 'متوسط';

  @override
  String get anxietyLevelHigh => 'مرتفع';

  @override
  String get anxietyLevelSevere => 'شديد';

  @override
  String get anxietyInterpretationCalm =>
      'قلقك في المنطقة الطبيعية — استمر على نفس الوتيرة.';

  @override
  String get anxietyInterpretationModerate =>
      'بداية قلق مزمن — دفتر القلق هيفيدك كتير.';

  @override
  String get anxietyInterpretationHigh =>
      'القلق بيأثر على حياتك — صفا معاك خطوة خطوة.';

  @override
  String get anxietyInterpretationSevere =>
      'يُنصح بمراجعة مختص + ابدأ برنامج القلق مع صفا.';

  @override
  String get anxietyStartProgramCta => 'ابدأ البرنامج مع صفا';

  @override
  String get anxietyRetakeTest => 'أعد الاختبار';

  @override
  String get anxietyJourneyCardTitle => 'تشخيص القلق';

  @override
  String get anxietyJourneyCardSubtitle => '8 أسئلة · فحص القلق المزمن';

  @override
  String anxietyJourneyCardLatestScore(int score) {
    return 'آخر نتيجة: $score%';
  }

  @override
  String get anxietySaveError => 'تعذّر حفظ النتيجة. حاول مرة أخرى.';

  @override
  String get anxietyLoadError => 'تعذّر تحميل النتيجة.';

  @override
  String get anxietyNoResultYet =>
      'لا توجد نتيجة بعد. أكمل فحصاً قصيراً أولاً.';

  @override
  String get worryWindowTitle => 'نافذة القلق';

  @override
  String get worryJournalTitle => 'دفتر القلق';

  @override
  String get worrySafaPrompt =>
      'اكتب اللي في دماغك دلوقتي — مش لازم يكون منظّم، بس طلّعه بره 🌿';

  @override
  String get worryJournalHint => 'إيه اللي قلقانك النهارده؟';

  @override
  String get worryDurationTen => '١٠ دقائق';

  @override
  String get worryDurationFifteen => '١٥ دقيقة';

  @override
  String get worryRuleReminder => '💡 مش قبل النوم';

  @override
  String get worryTimerStart => 'ابدأ';

  @override
  String get worryTimerPause => 'إيقاف';

  @override
  String get worryTimerReset => 'إعادة';

  @override
  String get worryWindowCompleteMessage =>
      'أحسنت — فرّغت دماغك 💚 النوم هيبقى أهدى.';

  @override
  String get worrySaveAndClose => 'حفظ وإغلاق';

  @override
  String get worrySaveFab => 'حفظ';

  @override
  String get worrySavedSnackbar => '✓ اتحفظ';

  @override
  String get worryPastEntriesTitle => 'إدخالات اليوم';

  @override
  String get worryNoEntriesToday => 'مفيش إدخالات النهارده.';

  @override
  String get worryLoadError => 'تعذّر تحميل الإدخالات.';

  @override
  String get worryDiscardTitle => 'تجاهل الكتابة؟';

  @override
  String get worryDiscardBody => 'عندك نص مش محفوظ. تقفل من غير حفظ؟';

  @override
  String get worrySettingsSectionTitle => 'نافذة القلق اليومية';

  @override
  String get worrySettingsReminderTime => 'وقت التذكير';

  @override
  String get worrySettingsReminderEnabled => 'تفعيل التذكير';

  @override
  String get worryTimingWarning =>
      '⚠️ نافذة القلق تكون قبل النوم — اختر وقتاً أبكر.';

  @override
  String get worryNotifTitle => 'وقت نافذة القلق 🧠';

  @override
  String get worryNotifBody => '١٠ دقايق تفرّغ دماغك — هتفضل أهدى طول الليل';

  @override
  String get homeActivityWorryJournal => '✍️ دفتر القلق';

  @override
  String get homeActivityWorryWindow => '⏱️ نافذة القلق';

  @override
  String get safaProgramTitle => 'برنامجك مع صفا 🌿';

  @override
  String get safaProgramCta => 'ابدأ مع صفا';

  @override
  String get safaProgramLoadError => 'تعذّر تحميل البرنامج.';

  @override
  String get safaProgramFallbackCalm =>
      'قلقك تحت السيطرة — استمر على نفس الإيقاع. ركّز على دفتر القلق لو حسيت بأي ضغط. صفا هنا لو محتاج. أنت على الطريق الصح 💚';

  @override
  String get safaProgramFallbackModerate =>
      'لاحظت بداية قلق مزمن — دفتر القلق هيفيدك كتير. جرّب نافذة القلق كل يوم الساعة 5 العصر. صفا هتابع معاك أسبوعياً. خطوة صغيرة كل يوم تصنع فرقاً 🌿';

  @override
  String get safaProgramFallbackHigh =>
      'القلق بيأثر على يومك — ابدأ بنافذة القلق اليومية وأضف حركة خفيفة. صفا ستبني معك خطة أسبوعية. أنت أقوى من القلق 💪';

  @override
  String get safaProgramFallbackSevere =>
      'القلق عالي — يُنصح بمراجعة مختص إلى جانب البرنامج. ابدأ بدفتر القلق يومياً. صفا معاك في كل خطوة. مش لازم تعدي ده لوحدك 🤝';

  @override
  String get calmIndexLegendBci => 'صفاء الذهن (BCI)';

  @override
  String get calmIndexLegendCalm => 'مؤشر الهدوء';

  @override
  String get safaCheckinIcon => '🌙';

  @override
  String get safaCheckinTitle => 'ملاحظة من صفا';

  @override
  String get safaCheckinBody =>
      'لاحظت إنك بتكتب في دفتر القلق بالليل كتير — ده ممكن يأثر على نومك. تحب ننقل نافذة القلق للعصر؟';

  @override
  String get safaCheckinAction => 'غيّر الوقت';

  @override
  String get safaCheckinTimeUpdated => 'تم تحديث وقت تذكير نافذة القلق.';

  @override
  String get dailyChallengeIcon => '🧠';

  @override
  String get dailyChallengeTitle => 'تحدي اليوم';

  @override
  String get dailyChallengeCompleted => 'مكتمل ✓';

  @override
  String get dailyChallengeStart => 'ابدأ التحدي';

  @override
  String get dailyChallengeReplay => 'أعد التحدي 🔄';

  @override
  String get dailyChallengeGameNBack => 'ذاكرة N-Back';

  @override
  String get dailyChallengeGameSpeedSort => 'الترتيب السريع';

  @override
  String get dailyChallengeGameColorWord => 'كلمة اللون';

  @override
  String get dailyChallengeGameNumberMemory => 'ذاكرة الأرقام';

  @override
  String get dailyChallengeGamePatternMatch => 'تطابق الأنماط';

  @override
  String get dailyChallengeGameCrossword => 'كلمة متقاطعة';

  @override
  String get dailyChallengeSubtitleNBack => 'تدرّب على ذاكرتك العاملة';

  @override
  String get dailyChallengeSubtitleSpeedSort => 'سرّع تفكيرك المنطقي';

  @override
  String get dailyChallengeSubtitleColorWord => 'تحدّ تركيزك البصري';

  @override
  String get dailyChallengeSubtitleNumberMemory => 'درّب انتباهك اليومي';

  @override
  String get dailyChallengeSubtitlePatternMatch => 'اشحذ تمييزك البصري';

  @override
  String get dailyChallengeSubtitleCrossword => 'وسّع مفرداتك العربية';

  @override
  String get weeklyReportEntryIcon => '📊';

  @override
  String get weeklyReportEntryTitle => 'تقرير الأسبوع';

  @override
  String get weeklyReportEntrySubtitle => 'شوف تقدمك هذا الأسبوع';

  @override
  String get weeklyReportLoadError => 'تعذّر تحميل تقرير الأسبوع.';

  @override
  String get weeklyReportBciLabel => 'مؤشر صفاء الذهن';

  @override
  String get weeklyReportBciNoData => 'لم يُسجَّل بيانات هذا الأسبوع';

  @override
  String weeklyReportBciUp(String percent) {
    return '↑ +$percent%';
  }

  @override
  String weeklyReportBciDown(String percent) {
    return '↓ -$percent%';
  }

  @override
  String get weeklyReportBciFlat => '→ ثابت';

  @override
  String get weeklyReportActivityTitle => 'ملخص النشاط';

  @override
  String get weeklyReportStatGamesIcon => '🎮';

  @override
  String get weeklyReportStatGames => 'لعبة';

  @override
  String get weeklyReportStatChallengesIcon => '🧩';

  @override
  String get weeklyReportStatChallenges => 'تحديات';

  @override
  String weeklyReportStatChallengesValue(int count) {
    return '$count/٧';
  }

  @override
  String get weeklyReportStatWorryIcon => '✍️';

  @override
  String get weeklyReportStatWorry => 'تدوينة قلق';

  @override
  String get weeklyReportStatStreakIcon => '🔥';

  @override
  String get weeklyReportStatStreak => 'يوم تواصل';

  @override
  String get weeklyReportBestGameTitle => 'نجم الأسبوع 🏆';

  @override
  String get weeklyReportBestGameSubtitle => 'أفضل أداء هذا الأسبوع';

  @override
  String get weeklyReportCalmTitle => 'مؤشر الهدوء';

  @override
  String get weeklyReportSafaAvatar => 'ص';

  @override
  String get smartReminderSectionTitle => 'التذكير الذكي';

  @override
  String get smartReminderToggle => 'تذكير ذكي';

  @override
  String smartReminderStatusDetected(int hour) {
    return 'سيُرسَل تذكير الساعة $hour:00 بناءً على عادتك 🎯';
  }

  @override
  String get smartReminderStatusLearning =>
      'افتح التطبيق ٣ أيام متتالية عشان نتعلم وقتك المفضل';

  @override
  String get smartReminderInfoChip => 'بيتعلم من سلوكك تلقائياً';

  @override
  String get dailyProgramTitle => 'البرنامج اليومي';

  @override
  String get dailyProgramLoadError => 'تعذّر تحميل برنامج اليوم.';

  @override
  String get dailyProgramGreetingGeneric => 'صباح الخير 🌿';

  @override
  String dailyProgramGreetingNamed(String name) {
    return 'صباح الخير يا $name 🌿';
  }

  @override
  String dailyProgramDayLabel(int day) {
    return 'اليوم $day';
  }

  @override
  String dailyProgramRemaining(int count) {
    return 'تبقى لك $count خطوات';
  }

  @override
  String get dailyProgramRemainingZero => 'خلّصت كل الخطوات';

  @override
  String dailyProgramProgressPercent(int percent) {
    return '$percent%';
  }

  @override
  String get dailyProgramDoneCta => 'تم ✅';

  @override
  String get dailyProgramChooseMood => 'اختر مزاجك';

  @override
  String get dailyProgramOpenEmotionWheel => 'فتح عجلة المشاعر';

  @override
  String get dailyProgramOpenCalmExercise => 'فتح تمرين السكون';

  @override
  String get dailyProgramOpenSingleTask => 'فتح مهمة التركيز';

  @override
  String get dailyProgramOpenWorryJournal => 'فتح دفتر القلق';

  @override
  String get dailyProgramSkip => 'تخطّي';

  @override
  String get dailyProgramAllStepsTitle => 'كل خطوات اليوم';

  @override
  String get dailyProgramCompleteTitle => '🏁 خلّصت رحلة اليوم! فخورين بيك 💚';

  @override
  String get dailyProgramViewReport => 'شوف تقرير اليوم';

  @override
  String get dailyProgramHomeIcon => '🌿';

  @override
  String get dailyProgramHomeTitle => 'برنامجي اليومي';

  @override
  String get dailyProgramHomeStart => 'ابدأ رحلة يومك';

  @override
  String dailyProgramHomeInProgress(int count) {
    return 'تبقى لك $count خطوات';
  }

  @override
  String get dailyProgramHomeDone => 'خلّصت رحلة النهارده ✅';

  @override
  String get dailyProgramWaterSheetTitle => '💧 شربت كوب ماء؟';

  @override
  String get dailyProgramWaterSheetSubtitle => 'الماء بيساعد دماغك يشتغل أحسن';

  @override
  String get dailyProgramWaterConfirm => 'أيوه، شربت ✅';

  @override
  String get dailyProgramWaterLater => 'لسه، هشرب دلوقتي';

  @override
  String get dailyProgramMovementSheetTitle => '🚶 عملت أي حركة النهارده؟';

  @override
  String get dailyProgramMovementSheetSubtitle => 'حتى 5 دقايق مشي بتفرق';

  @override
  String get dailyProgramMovementConfirm => 'أيوه ✅';

  @override
  String get dailyProgramMovementDoNow => 'هعمل دلوقتي';

  @override
  String get dailyProgramMovementSkipToday => 'مش قادر النهارده';

  @override
  String get dayEndTitle => 'أختِم يومك بلطف 💚';

  @override
  String get dayEndSubtitle =>
      'كل خطوة عملتها النهارده كافية. الإغلاق بهدوء هو تقدّم.';

  @override
  String get dayEndSummaryTitle => 'ملخّص يومك';

  @override
  String dayEndProgressSummary(int completed, int total) {
    return '$completed من $total خطوات اكتملت';
  }

  @override
  String dayEndSkippedSummary(int count) {
    return '$count تم تخطيها — وده تمام';
  }

  @override
  String dayEndRemainingSummary(int count) {
    return '$count ما زالت مفتوحة';
  }

  @override
  String get dayEndReflection0 => 'إيه أحسن حاجة حصلت معاك النهارده؟';

  @override
  String get dayEndReflection1 => 'إيه اللي عايز تعمله تاني بكره؟';

  @override
  String get dayEndReflection2 => 'إيه اللي شعرت بيه النهارده؟';

  @override
  String get dayEndReflection3 => 'حاجة واحدة شكرت ربنا عليها النهارده؟';

  @override
  String get dayEndClosingMessage => 'ارتاح كويس 🌙 بكره بداية جديدة.';

  @override
  String get dayEndFinishButton => 'أنهيت يومي';

  @override
  String get sukoonTitle => 'سكون';

  @override
  String get sukoonIntro =>
      'اقعد في سكون. سيب دماغك حر — يشرد، يفكّر، أو ما يفكّرش في حاجة.\nالعلم بيقول إن لحظات السكون دي بتعيد شحن انتباهك.';

  @override
  String get sukoonDurationLabel => 'المدة';

  @override
  String get sukoonDuration3 => '٣ دقائق';

  @override
  String get sukoonDuration5 => '٥ دقائق';

  @override
  String get sukoonDuration10 => '١٠ دقائق';

  @override
  String get sukoonDuration15 => '١٥ دقيقة';

  @override
  String sukoonDurationOption(int minutes) {
    return '$minutes د';
  }

  @override
  String get sukoonStart => 'ابدأ';

  @override
  String get sukoonPause => 'إيقاف مؤقت';

  @override
  String get sukoonContinue => 'أكمل';

  @override
  String get sukoonRestart => 'من جديد';

  @override
  String get sukoonReset => 'إعادة';

  @override
  String get sukoonInterruptedMessage =>
      'السكون اتقطع — مفيش مشكلة، تقدر تكمّل أو تبدأ من جديد 🌿';

  @override
  String sukoonCompleteTitle(int minutes) {
    return 'خلّصت $minutes دقايق سكون 🌿 دماغك ارتاح.';
  }

  @override
  String get sukoonWanderHint => 'وين سرح بالك؟ (اختياري)';

  @override
  String get sukoonSave => 'حفظ';

  @override
  String get sukoonSkip => 'تخطّي';

  @override
  String get socialMediaUsageLoading => 'جاري تحميل وقت السوشيال ميديا…';

  @override
  String get socialMediaUsagePromptTitle => 'تابع وقتك على السوشيال ميديا';

  @override
  String get socialMediaUsagePromptBody =>
      'معلومة بس عن وقتك النهارده — من غير حظر ولا حكم. فعّل صلاحية الوصول للاستخدام من إعدادات النظام.';

  @override
  String get socialMediaUsageGrantButton => 'فتح إعدادات الوصول للاستخدام';

  @override
  String socialMediaUsageTodayTotal(int minutes) {
    return 'قضيت $minutes دقيقة النهاردة على السوشيال ميديا';
  }

  @override
  String get socialMediaUsageTodaySubtitle =>
      'إنستغرام · تيك توك · سناب · فيسبوك · X — للمعلومة فقط';
}
