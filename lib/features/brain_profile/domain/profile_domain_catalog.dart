import '../../brain_check/domain/brain_check_mode.dart';
import 'brain_profile_domain.dart';

/// Non-medical domain definitions for PRF-02 (plain language only).
abstract final class ProfileDomainCatalog {
  static BrainProfileDomain? byId(String id) {
    for (final d in all) {
      if (d.id == id) return d;
    }
    return null;
  }

  static List<BrainProfileDomain> forMode(BrainCheckMode mode) {
    switch (mode) {
      case BrainCheckMode.lite:
        return [attentionLite, recoveryLite];
      case BrainCheckMode.pulse:
        return [pulseCheck];
      case BrainCheckMode.full:
        return [
          fullAttention,
          fullMood,
          fullHabits,
          fullIntention,
        ];
    }
  }

  static final List<BrainProfileDomain> all = List.unmodifiable([
    attentionLite,
    recoveryLite,
    pulseCheck,
    fullAttention,
    fullMood,
    fullHabits,
    fullIntention,
  ]);

  static const attentionLite = BrainProfileDomain(
    id: 'lite_attention',
    titleEn: 'Attention',
    titleAr: 'الانتباه',
    definitionEn:
        'How clearly you notice focus and distraction in everyday moments. This is a self-report, not a clinical attention test.',
    definitionAr:
        'كيف تلاحظ التركيز والتشتت في لحظات يومك. هذا تقرير ذاتي، وليس اختبار انتباه سريرياً.',
  );

  static const recoveryLite = BrainProfileDomain(
    id: 'lite_recovery',
    titleEn: 'Recovery readiness',
    titleAr: 'جاهزية التعافي',
    definitionEn:
        'How ready you feel to build calmer habits this week. It reflects your answers, not a medical prognosis.',
    definitionAr:
        'مدى جاهزيتك لبناء عادات أهدأ هذا الأسبوع. يعكس إجاباتك، وليس توقعاً طبياً.',
  );

  static const pulseCheck = BrainProfileDomain(
    id: 'pulse_check',
    titleEn: 'Pulse check',
    titleAr: 'نبضة سريعة',
    definitionEn:
        'A short snapshot of how things feel right now. Useful for noticing change — not a diagnosis.',
    definitionAr:
        'لقطة قصيرة لكيف تشعر الآن. مفيدة لملاحظة التغيير — وليست تشخيصاً.',
  );

  static const fullAttention = BrainProfileDomain(
    id: 'full_attention',
    titleEn: 'Attention',
    titleAr: 'الانتباه',
    definitionEn:
        'Self-reported focus and mental clarity across daily tasks. Not a neurological examination.',
    definitionAr:
        'تقرير ذاتي عن التركيز وصفاء الذهن في المهام اليومية. ليس فحصاً عصبياً.',
  );

  static const fullMood = BrainProfileDomain(
    id: 'full_mood',
    titleEn: 'Mood & steadiness',
    titleAr: 'المزاج والثبات',
    definitionEn:
        'How steady your mood has felt lately according to you. Not a clinical mood score.',
    definitionAr:
        'مدى ثبات مزاجك مؤخراً كما وصفته. ليس درجة مزاج سريرية.',
  );

  static const fullHabits = BrainProfileDomain(
    id: 'full_habits',
    titleEn: 'Habits',
    titleAr: 'العادات',
    definitionEn:
        'Patterns you reported around screens and routines. A starting point for support, not proof of harm.',
    definitionAr:
        'أنماط أبلغت عنها حول الشاشات والروتين. نقطة بداية للدعم، وليست إثباتاً لضرر.',
  );

  static const fullIntention = BrainProfileDomain(
    id: 'full_intention',
    titleEn: 'Intention',
    titleAr: 'النية',
    definitionEn:
        'Your stated wish to change. Motivation can shift — this is not a guarantee of outcome.',
    definitionAr:
        'رغبتك المعلنة في التغيير. الدافع قد يتغير — وهذه ليست ضماناً للنتيجة.',
  );
}
