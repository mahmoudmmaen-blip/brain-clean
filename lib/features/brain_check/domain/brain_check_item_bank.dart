import 'brain_check_mode.dart';
import 'brain_check_question.dart';
import 'brain_check_scale.dart';
import 'brain_check_section.dart';

/// Foundation item bank for Brain Check (Assessment Bible placeholder).
///
/// Progressive sections only — adaptive deepeners arrive in a later slice.
abstract final class BrainCheckItemBank {
  static List<BrainCheckSection> sectionsFor(BrainCheckMode mode) {
    switch (mode) {
      case BrainCheckMode.lite:
        return _lite;
      case BrainCheckMode.full:
        return _full;
      case BrainCheckMode.pulse:
        return _pulse;
    }
  }

  static List<BrainCheckQuestion> questionsFor(BrainCheckMode mode) {
    return sectionsFor(mode)
        .expand((section) => section.questions)
        .toList(growable: false);
  }

  static BrainCheckQuestion? questionById(BrainCheckMode mode, String id) {
    for (final question in questionsFor(mode)) {
      if (question.id == id) return question;
    }
    return null;
  }

  static int sectionIndexForQuestion(BrainCheckMode mode, int questionIndex) {
    final sections = sectionsFor(mode);
    var cursor = 0;
    for (var i = 0; i < sections.length; i++) {
      final next = cursor + sections[i].questions.length;
      if (questionIndex < next) return i;
      cursor = next;
    }
    return sections.isEmpty ? 0 : sections.length - 1;
  }

  /// True when [questionIndex] is the first item of a section after the first.
  static bool isSectionBoundaryStart(BrainCheckMode mode, int questionIndex) {
    if (questionIndex <= 0) return false;
    final sections = sectionsFor(mode);
    var cursor = 0;
    for (var i = 0; i < sections.length; i++) {
      if (questionIndex == cursor && i > 0) return true;
      cursor += sections[i].questions.length;
    }
    return false;
  }

  static final List<BrainCheckSection> _lite = List.unmodifiable([
    BrainCheckSection(
      id: 'lite_attention',
      titleEn: 'Attention',
      titleAr: 'الانتباه',
      order: 0,
      questions: [
        const BrainCheckQuestion(
          id: 'lite_q1',
          sectionId: 'lite_attention',
          stemEn: 'I can stay with one task without switching apps.',
          stemAr: 'أستطيع البقاء مع مهمة واحدة دون تبديل التطبيقات.',
          scale: BrainCheckScale.likert5,
          order: 0,
        ),
        const BrainCheckQuestion(
          id: 'lite_q2',
          sectionId: 'lite_attention',
          stemEn: 'My mind feels clear enough for short focused work.',
          stemAr: 'أشعر أن ذهني صافٍ بما يكفي لعمل قصير ومركّز.',
          scale: BrainCheckScale.likert5,
          order: 1,
        ),
        const BrainCheckQuestion(
          id: 'lite_q3',
          sectionId: 'lite_attention',
          stemEn: 'I notice when I start scrolling without a purpose.',
          stemAr: 'ألاحظ عندما أبدأ التصفح بدون هدف.',
          scale: BrainCheckScale.frequency,
          order: 2,
        ),
      ],
    ),
    BrainCheckSection(
      id: 'lite_recovery',
      titleEn: 'Recovery readiness',
      titleAr: 'جاهزية التعافي',
      order: 1,
      questions: [
        const BrainCheckQuestion(
          id: 'lite_q4',
          sectionId: 'lite_recovery',
          stemEn: 'I want a calmer daily routine this week.',
          stemAr: 'أريد روتيناً يومياً أكثر هدوءاً هذا الأسبوع.',
          scale: BrainCheckScale.yesNo,
          order: 3,
        ),
        const BrainCheckQuestion(
          id: 'lite_q5',
          sectionId: 'lite_recovery',
          stemEn: 'I can protect a short recovery session most days.',
          stemAr: 'أستطيع حماية جلسة تعافٍ قصيرة في معظم الأيام.',
          scale: BrainCheckScale.likert5,
          order: 4,
        ),
        const BrainCheckQuestion(
          id: 'lite_q6',
          sectionId: 'lite_recovery',
          stemEn: 'I feel ready to start a gentle recovery plan.',
          stemAr: 'أشعر أنني مستعد لبدء خطة تعافٍ لطيفة.',
          scale: BrainCheckScale.likert5,
          order: 5,
        ),
      ],
    ),
  ]);

  static final List<BrainCheckSection> _pulse = List.unmodifiable([
    BrainCheckSection(
      id: 'pulse_check',
      titleEn: 'Pulse check',
      titleAr: 'نبضة سريعة',
      order: 0,
      questions: [
        const BrainCheckQuestion(
          id: 'pulse_q1',
          sectionId: 'pulse_check',
          stemEn: 'Today my focus feels steadier than last week.',
          stemAr: 'أشعر أن تركيزي اليوم أكثر ثباتاً من الأسبوع الماضي.',
          scale: BrainCheckScale.likert5,
          order: 0,
        ),
        const BrainCheckQuestion(
          id: 'pulse_q2',
          sectionId: 'pulse_check',
          stemEn: 'I protected at least one calm break recently.',
          stemAr: 'حميت على الأقل استراحة هادئة مؤخراً.',
          scale: BrainCheckScale.yesNo,
          order: 1,
        ),
        const BrainCheckQuestion(
          id: 'pulse_q3',
          sectionId: 'pulse_check',
          stemEn: 'Urge to escape into screens feels manageable.',
          stemAr: 'الرغبة في الهروب إلى الشاشات تبدو قابلة للإدارة.',
          scale: BrainCheckScale.likert5,
          order: 2,
        ),
        const BrainCheckQuestion(
          id: 'pulse_q4',
          sectionId: 'pulse_check',
          stemEn: 'I still want to continue my recovery path.',
          stemAr: 'ما زلت أرغب في مواصلة مسار التعافي.',
          scale: BrainCheckScale.yesNo,
          order: 3,
        ),
      ],
    ),
  ]);

  static final List<BrainCheckSection> _full = List.unmodifiable([
    BrainCheckSection(
      id: 'full_attention',
      titleEn: 'Attention',
      titleAr: 'الانتباه',
      order: 0,
      questions: [
        const BrainCheckQuestion(
          id: 'full_q1',
          sectionId: 'full_attention',
          stemEn: 'I finish short tasks without opening other apps.',
          stemAr: 'أُكمل المهام القصيرة دون فتح تطبيقات أخرى.',
          scale: BrainCheckScale.likert5,
          order: 0,
        ),
        const BrainCheckQuestion(
          id: 'full_q2',
          sectionId: 'full_attention',
          stemEn: 'I can read a page without losing the thread.',
          stemAr: 'أستطيع قراءة صفحة دون فقدان الخيط.',
          scale: BrainCheckScale.likert5,
          order: 1,
        ),
        const BrainCheckQuestion(
          id: 'full_q3',
          sectionId: 'full_attention',
          stemEn: 'Notifications pull me away often.',
          stemAr: 'الإشعارات تسحبني بعيداً كثيراً.',
          scale: BrainCheckScale.frequency,
          order: 2,
        ),
      ],
    ),
    BrainCheckSection(
      id: 'full_mood',
      titleEn: 'Mood balance',
      titleAr: 'توازن المزاج',
      order: 1,
      questions: [
        const BrainCheckQuestion(
          id: 'full_q4',
          sectionId: 'full_mood',
          stemEn: 'My evenings feel calmer without late scrolling.',
          stemAr: 'أشعر بهدوء أكبر مساءً دون تصفح متأخر.',
          scale: BrainCheckScale.likert5,
          order: 3,
        ),
        const BrainCheckQuestion(
          id: 'full_q5',
          sectionId: 'full_mood',
          stemEn: 'I recover quickly after a stressful online moment.',
          stemAr: 'أتعافى بسرعة بعد لحظة توتر عبر الإنترنت.',
          scale: BrainCheckScale.likert5,
          order: 4,
        ),
        const BrainCheckQuestion(
          id: 'full_q6',
          sectionId: 'full_mood',
          stemEn: 'I use screens to avoid uncomfortable feelings.',
          stemAr: 'أستخدم الشاشات لتجنب مشاعر غير مريحة.',
          scale: BrainCheckScale.frequency,
          order: 5,
        ),
      ],
    ),
    BrainCheckSection(
      id: 'full_habits',
      titleEn: 'Daily habits',
      titleAr: 'العادات اليومية',
      order: 2,
      questions: [
        const BrainCheckQuestion(
          id: 'full_q7',
          sectionId: 'full_habits',
          stemEn: 'I keep a consistent sleep window most nights.',
          stemAr: 'أحافظ على نافذة نوم ثابتة في معظم الليالي.',
          scale: BrainCheckScale.likert5,
          order: 6,
        ),
        const BrainCheckQuestion(
          id: 'full_q8',
          sectionId: 'full_habits',
          stemEn: 'I move my body at least briefly most days.',
          stemAr: 'أحرّك جسمي ولو لفترة قصيرة في معظم الأيام.',
          scale: BrainCheckScale.yesNo,
          order: 7,
        ),
        const BrainCheckQuestion(
          id: 'full_q9',
          sectionId: 'full_habits',
          stemEn: 'I protect offline time for rest or people.',
          stemAr: 'أحمي وقتاً دون اتصال للراحة أو للناس.',
          scale: BrainCheckScale.frequency,
          order: 8,
        ),
      ],
    ),
    BrainCheckSection(
      id: 'full_intention',
      titleEn: 'Intention',
      titleAr: 'النية',
      order: 3,
      questions: [
        const BrainCheckQuestion(
          id: 'full_q10',
          sectionId: 'full_intention',
          stemEn: 'I know why I want a cleaner digital life.',
          stemAr: 'أعرف لماذا أريد حياة رقمية أنظف.',
          scale: BrainCheckScale.likert5,
          order: 9,
        ),
        const BrainCheckQuestion(
          id: 'full_q11',
          sectionId: 'full_intention',
          stemEn: 'I can name one small change I will try next.',
          stemAr: 'أستطيع تسمية تغيير صغير سأجربه لاحقاً.',
          scale: BrainCheckScale.yesNo,
          order: 10,
        ),
        const BrainCheckQuestion(
          id: 'full_q12',
          sectionId: 'full_intention',
          stemEn: 'I feel ready for a personal recovery path.',
          stemAr: 'أشعر أنني مستعد لمسار تعافٍ شخصي.',
          scale: BrainCheckScale.likert5,
          order: 11,
        ),
      ],
    ),
  ]);
}
