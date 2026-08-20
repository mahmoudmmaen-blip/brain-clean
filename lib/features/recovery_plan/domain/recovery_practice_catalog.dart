import 'recovery_plan_versions.dart';
import 'recovery_practice.dart';

/// Bounded V1 catalog — exact contract IDs (§10).
abstract final class RecoveryPracticeCatalog {
  static const version = RecoveryPlanVersions.catalog;

  static const completionRule = 'user_mark_or_timer';
  static const skipBehavior = 'allowed_no_penalty';

  static const List<String> allIds = [
    'prac_single_task',
    'prac_notify_friction',
    'prac_settle_breath',
    'prac_screen_pause',
    'prac_offline_interval',
    'prac_body_move',
    'prac_sleep_winddown',
    'prac_one_change',
    'prac_env_reset',
    'prac_awareness_check',
    'prac_starter_calm',
  ];

  static RecoveryPractice byId(String id) {
    final practice = _byId[id];
    if (practice == null) {
      throw ArgumentError.value(id, 'id', 'Unknown practice');
    }
    return practice;
  }

  static List<RecoveryPractice> get all =>
      allIds.map(byId).toList(growable: false);

  /// Domain → ordered primary practices (contract §11).
  static List<String> primaryForDomain(String domainId) {
    switch (domainId) {
      case 'lite_attention':
      case 'full_attention':
        return const ['prac_single_task', 'prac_notify_friction'];
      case 'lite_recovery':
        return const ['prac_one_change', 'prac_screen_pause'];
      case 'pulse_check':
        return const ['prac_awareness_check', 'prac_settle_breath'];
      case 'full_mood':
        return const ['prac_settle_breath', 'prac_screen_pause'];
      case 'full_habits':
        return const ['prac_body_move', 'prac_offline_interval'];
      case 'full_intention':
        return const ['prac_one_change'];
      default:
        return const [];
    }
  }

  /// Domain → ordered secondary practices.
  static List<String> secondaryForDomain(String domainId) {
    switch (domainId) {
      case 'lite_attention':
      case 'full_attention':
        return const ['prac_env_reset', 'prac_awareness_check'];
      case 'lite_recovery':
        return const ['prac_settle_breath', 'prac_offline_interval'];
      case 'pulse_check':
        return const ['prac_screen_pause'];
      case 'full_mood':
        return const ['prac_sleep_winddown'];
      case 'full_habits':
        return const ['prac_sleep_winddown', 'prac_env_reset'];
      case 'full_intention':
        return const ['prac_single_task'];
      default:
        return const [];
    }
  }

  static final Map<String, RecoveryPractice> _byId = {
    for (final p in _practices) p.id: p,
  };

  static final List<RecoveryPractice> _practices = [
    RecoveryPractice(
      id: 'prac_single_task',
      version: RecoveryPlanVersions.practiceVersion,
      nameEn: 'One-task focus setup',
      nameAr: 'إعداد التركيز على مهمة واحدة',
      targetDomainTags: const ['attention', 'pulse'],
      purposeEn: 'Choose one task and reduce one distraction.',
      purposeAr: 'اختر مهمة واحدة وقلل مصدر تشتيت واحد.',
      minimumPathEn: 'Choose 1 task; silence one distraction',
      minimumPathAr: 'اختر مهمة واحدة؛ أوقف مصدر تشتيت واحد',
      standardPathEn: '5-min single-task timer',
      standardPathAr: 'مؤقت مهمة واحدة لمدة 5 دقائق',
      durationMinutesMin: 3,
      durationMinutesMax: 8,
      completionRule: completionRule,
      skipBehavior: skipBehavior,
      accessibilityAltEn: 'Voice-only choose task',
      accessibilityAltAr: 'اختر المهمة بالصوت فقط',
      offline: true,
      starterOnly: false,
      safetyBoundaryEn: 'Stop if distress rises; no forced exposure.',
      safetyBoundaryAr: 'توقف إذا زاد الضيق؛ بلا تعريض قسري.',
      becauseTemplateKey: 'because_priority',
      evidenceClass: PracticeEvidenceClass.hypothesis,
      prohibitedClaims: const [
        'cure',
        'brain-training intelligence',
        'ADHD treatment',
      ],
    ),
    RecoveryPractice(
      id: 'prac_notify_friction',
      version: RecoveryPlanVersions.practiceVersion,
      nameEn: 'Notification friction',
      nameAr: 'تقليل سحب الإشعارات',
      targetDomainTags: const ['attention'],
      purposeEn: 'Add a small pause before notification pull.',
      purposeAr: 'أضف توقفاً قصيراً قبل سحب الإشعارات.',
      minimumPathEn: 'Mute one noisy channel 10 min',
      minimumPathAr: 'اكتم قناة مزعجة لمدة 10 دقائق',
      standardPathEn: 'Place phone face-down + mute 15 min',
      standardPathAr: 'ضع الهاتف مقلوباً مع كتم الصوت 15 دقيقة',
      durationMinutesMin: 2,
      durationMinutesMax: 5,
      completionRule: completionRule,
      skipBehavior: skipBehavior,
      accessibilityAltEn: 'Ask helper to mute',
      accessibilityAltAr: 'اطلب مساعدة لكتم الإشعارات',
      offline: true,
      starterOnly: false,
      safetyBoundaryEn: 'Stop if distress rises; no forced exposure.',
      safetyBoundaryAr: 'توقف إذا زاد الضيق؛ بلا تعريض قسري.',
      becauseTemplateKey: 'because_priority',
      evidenceClass: PracticeEvidenceClass.hypothesis,
      prohibitedClaims: const ['dopamine detox', 'cure'],
    ),
    RecoveryPractice(
      id: 'prac_settle_breath',
      version: RecoveryPlanVersions.practiceVersion,
      nameEn: 'Brief settle pause',
      nameAr: 'توقف تهدئة قصير',
      targetDomainTags: const ['mood', 'pulse', 'recovery'],
      purposeEn: 'A short settling pause to steady attention.',
      purposeAr: 'توقف قصير لتهدئة الانتباه.',
      minimumPathEn: '3 calm counts',
      minimumPathAr: '3 عدّات هادئة',
      standardPathEn: '1-min paced settle pause',
      standardPathAr: 'توقف تهدئة بإيقاع لمدة دقيقة',
      durationMinutesMin: 1,
      durationMinutesMax: 3,
      completionRule: completionRule,
      skipBehavior: skipBehavior,
      accessibilityAltEn: 'Eyes-open counting pause',
      accessibilityAltAr: 'عدّ هادئ والعينان مفتوحتان',
      offline: true,
      starterOnly: false,
      safetyBoundaryEn: 'Stop if distress rises; no forced exposure.',
      safetyBoundaryAr: 'توقف إذا زاد الضيق؛ بلا تعريض قسري.',
      becauseTemplateKey: 'because_priority',
      evidenceClass: PracticeEvidenceClass.hypothesis,
      prohibitedClaims: const ['clinical CBT', 'medical treatment'],
    ),
    RecoveryPractice(
      id: 'prac_screen_pause',
      version: RecoveryPlanVersions.practiceVersion,
      nameEn: 'Intentional screen pause',
      nameAr: 'توقف مقصود عن الشاشة',
      targetDomainTags: const ['mood', 'pulse', 'recovery'],
      purposeEn: 'Pause screens briefly with intention.',
      purposeAr: 'أوقف الشاشات قليلاً بقصد.',
      minimumPathEn: '2-min pause',
      minimumPathAr: 'توقف لمدة دقيقتين',
      standardPathEn: '5-min pause + stand',
      standardPathAr: 'توقف 5 دقائق مع الوقوف',
      durationMinutesMin: 2,
      durationMinutesMax: 5,
      completionRule: completionRule,
      skipBehavior: skipBehavior,
      accessibilityAltEn: 'Audio cue only',
      accessibilityAltAr: 'إشارة صوتية فقط',
      offline: true,
      starterOnly: false,
      safetyBoundaryEn: 'Stop if distress rises; no forced exposure.',
      safetyBoundaryAr: 'توقف إذا زاد الضيق؛ بلا تعريض قسري.',
      becauseTemplateKey: 'because_priority',
      evidenceClass: PracticeEvidenceClass.hypothesis,
      prohibitedClaims: const ['dopamine detox', 'punishment'],
    ),
    RecoveryPractice(
      id: 'prac_offline_interval',
      version: RecoveryPlanVersions.practiceVersion,
      nameEn: 'Planned offline interval',
      nameAr: 'فترة دون اتصال',
      targetDomainTags: const ['habits', 'recovery'],
      purposeEn: 'A short planned offline stretch.',
      purposeAr: 'فترة قصيرة مخططة دون اتصال.',
      minimumPathEn: '5-min offline',
      minimumPathAr: '5 دقائق دون اتصال',
      standardPathEn: '10-min offline walk/room',
      standardPathAr: '10 دقائق دون اتصال مشياً أو في الغرفة',
      durationMinutesMin: 5,
      durationMinutesMax: 10,
      completionRule: completionRule,
      skipBehavior: skipBehavior,
      accessibilityAltEn: 'Stay seated offline',
      accessibilityAltAr: 'ابق جالساً دون اتصال',
      offline: true,
      starterOnly: false,
      safetyBoundaryEn: 'Stop if distress rises; no forced exposure.',
      safetyBoundaryAr: 'توقف إذا زاد الضيق؛ بلا تعريض قسري.',
      becauseTemplateKey: 'because_priority',
      evidenceClass: PracticeEvidenceClass.hypothesis,
      prohibitedClaims: const ['deprivation', 'punishment'],
    ),
    RecoveryPractice(
      id: 'prac_body_move',
      version: RecoveryPlanVersions.practiceVersion,
      nameEn: 'Brief body move',
      nameAr: 'حركة جسم قصيرة',
      targetDomainTags: const ['habits'],
      purposeEn: 'Gentle short movement to reset the body.',
      purposeAr: 'حركة قصيرة لطيفة لإعادة ضبط الجسم.',
      minimumPathEn: 'Stand + stretch 1 min',
      minimumPathAr: 'قف وتمدد لدقيقة',
      standardPathEn: '3-min gentle walk',
      standardPathAr: 'مشي لطيف لمدة 3 دقائق',
      durationMinutesMin: 1,
      durationMinutesMax: 5,
      completionRule: completionRule,
      skipBehavior: skipBehavior,
      accessibilityAltEn: 'Seated stretch',
      accessibilityAltAr: 'تمدد وأنت جالس',
      offline: true,
      starterOnly: false,
      safetyBoundaryEn: 'Stop if distress rises; no forced exposure.',
      safetyBoundaryAr: 'توقف إذا زاد الضيق؛ بلا تعريض قسري.',
      becauseTemplateKey: 'because_priority',
      evidenceClass: PracticeEvidenceClass.hypothesis,
      prohibitedClaims: const ['supplement advice', 'medical treatment'],
    ),
    RecoveryPractice(
      id: 'prac_sleep_winddown',
      version: RecoveryPlanVersions.practiceVersion,
      nameEn: 'Sleep wind-down prep',
      nameAr: 'تهيئة النوم',
      targetDomainTags: const ['habits', 'mood'],
      purposeEn: 'Prepare a gentler wind-down before sleep intent.',
      purposeAr: 'هيّئ تهدئة ألطف قبل النوم.',
      minimumPathEn: 'Dim one screen 10 min before bed intent',
      minimumPathAr: 'اخفض سطوع شاشة واحدة قبل النوم بعشر دقائق',
      standardPathEn: 'Same + no new feeds',
      standardPathAr: 'نفس الخطوة مع تجنب تغذية جديدة',
      durationMinutesMin: 3,
      durationMinutesMax: 8,
      completionRule: completionRule,
      skipBehavior: skipBehavior,
      accessibilityAltEn: 'Audio wind-down only',
      accessibilityAltAr: 'تهدئة صوتية فقط',
      offline: true,
      starterOnly: false,
      safetyBoundaryEn: 'Stop if distress rises; no forced exposure.',
      safetyBoundaryAr: 'توقف إذا زاد الضيق؛ بلا تعريض قسري.',
      becauseTemplateKey: 'because_priority',
      evidenceClass: PracticeEvidenceClass.hypothesis,
      prohibitedClaims: const ['medical sleep treatment', 'cure'],
    ),
    RecoveryPractice(
      id: 'prac_one_change',
      version: RecoveryPlanVersions.practiceVersion,
      nameEn: 'Name one small change',
      nameAr: 'تسمية تغيير صغير',
      targetDomainTags: const ['intention', 'recovery'],
      purposeEn: 'Name one small change without overloading.',
      purposeAr: 'سمِّ تغييراً صغيراً دون إرهاق.',
      minimumPathEn: 'Write/speak one change',
      minimumPathAr: 'اكتب أو انطق تغييراً واحداً',
      standardPathEn: 'Same + when you will try it',
      standardPathAr: 'نفس الخطوة مع وقت المحاولة',
      durationMinutesMin: 2,
      durationMinutesMax: 4,
      completionRule: completionRule,
      skipBehavior: skipBehavior,
      accessibilityAltEn: 'Voice memo',
      accessibilityAltAr: 'مذكرة صوتية',
      offline: true,
      starterOnly: false,
      safetyBoundaryEn: 'Stop if distress rises; no forced exposure.',
      safetyBoundaryAr: 'توقف إذا زاد الضيق؛ بلا تعريض قسري.',
      becauseTemplateKey: 'because_priority',
      evidenceClass: PracticeEvidenceClass.hypothesis,
      prohibitedClaims: const ['guarantee of outcome', 'cure'],
    ),
    RecoveryPractice(
      id: 'prac_env_reset',
      version: RecoveryPlanVersions.practiceVersion,
      nameEn: 'Environment reset',
      nameAr: 'إعادة ضبط المكان',
      targetDomainTags: const ['attention', 'habits'],
      purposeEn: 'Reset one small part of your space.',
      purposeAr: 'أعد ضبط جزء صغير من مكانك.',
      minimumPathEn: 'Clear one surface',
      minimumPathAr: 'نظف سطحاً واحداً',
      standardPathEn: 'Clear surface + water nearby',
      standardPathAr: 'نظف سطحاً وضع ماءً قريباً',
      durationMinutesMin: 2,
      durationMinutesMax: 5,
      completionRule: completionRule,
      skipBehavior: skipBehavior,
      accessibilityAltEn: 'Verbal checklist',
      accessibilityAltAr: 'قائمة تحقق شفهية',
      offline: true,
      starterOnly: false,
      safetyBoundaryEn: 'Stop if distress rises; no forced exposure.',
      safetyBoundaryAr: 'توقف إذا زاد الضيق؛ بلا تعريض قسري.',
      becauseTemplateKey: 'because_priority',
      evidenceClass: PracticeEvidenceClass.hypothesis,
      prohibitedClaims: const ['punishment', 'cure'],
    ),
    RecoveryPractice(
      id: 'prac_awareness_check',
      version: RecoveryPlanVersions.practiceVersion,
      nameEn: 'Awareness check-in',
      nameAr: 'تفقد الوعي',
      targetDomainTags: const ['attention', 'pulse'],
      purposeEn: 'Notice what is present and choose a next step.',
      purposeAr: 'لاحظ ما هو حاضر واختر الخطوة التالية.',
      minimumPathEn: 'Notice urge 30s',
      minimumPathAr: 'لاحظ الرغبة لمدة 30 ثانية',
      standardPathEn: 'Notice + choose next 1 min',
      standardPathAr: 'لاحظ واختر التالي لمدة دقيقة',
      durationMinutesMin: 1,
      durationMinutesMax: 3,
      completionRule: completionRule,
      skipBehavior: skipBehavior,
      accessibilityAltEn: 'Tactile cue',
      accessibilityAltAr: 'إشارة لمسية',
      offline: true,
      starterOnly: false,
      safetyBoundaryEn: 'Stop if distress rises; no forced exposure.',
      safetyBoundaryAr: 'توقف إذا زاد الضيق؛ بلا تعريض قسري.',
      becauseTemplateKey: 'because_priority',
      evidenceClass: PracticeEvidenceClass.hypothesis,
      prohibitedClaims: const ['long journaling', 'clinical CBT'],
    ),
    RecoveryPractice(
      id: 'prac_starter_calm',
      version: RecoveryPlanVersions.practiceVersion,
      nameEn: 'Calm start (starter)',
      nameAr: 'بداية هادئة',
      targetDomainTags: const ['any'],
      purposeEn: 'A calm starter step without fabricated personalization.',
      purposeAr: 'خطوة بداية هادئة دون تخصيص مُختلق.',
      minimumPathEn: '3 breaths + one kind next step',
      minimumPathAr: '3 أنفاس وخطوة لطيفة تالية',
      standardPathEn: 'Same + 2-min pause',
      standardPathAr: 'نفس الخطوة مع توقف دقيقتين',
      durationMinutesMin: 2,
      durationMinutesMax: 5,
      completionRule: completionRule,
      skipBehavior: skipBehavior,
      accessibilityAltEn: 'Breath count only',
      accessibilityAltAr: 'عدّ الأنفاس فقط',
      offline: true,
      starterOnly: true,
      safetyBoundaryEn: 'Stop if distress rises; no forced exposure.',
      safetyBoundaryAr: 'توقف إذا زاد الضيق؛ بلا تعريض قسري.',
      becauseTemplateKey: 'because_starter',
      evidenceClass: PracticeEvidenceClass.hypothesis,
      prohibitedClaims: const ['failure', 'medical treatment', 'cure'],
    ),
  ];
}
