import 'brain_check_mode.dart';
import 'brain_check_question.dart';
import 'brain_check_scale.dart';
import 'brain_check_section.dart';

/// Foundation item bank for Brain Check — direct, concrete stems.
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
          stemEn: 'How often can you finish one task without switching apps?',
          stemAr: 'كم مرة تُكمل مهمة واحدة دون تبديل التطبيقات؟',
          scale: BrainCheckScale.likert5,
          order: 0,
        ),
        const BrainCheckQuestion(
          id: 'lite_q2',
          sectionId: 'lite_attention',
          stemEn: 'How clear does your mind feel for 10–15 minutes of focus?',
          stemAr: 'ما مدى صفاء ذهنك لعمل مركّز لمدة 10–15 دقيقة؟',
          scale: BrainCheckScale.likert5,
          order: 1,
        ),
        const BrainCheckQuestion(
          id: 'lite_q3',
          sectionId: 'lite_attention',
          stemEn: 'How often do you browse your phone with no specific reason?',
          stemAr: 'كم مرة تتصفح هاتفك بدون سبب محدد؟',
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
          stemEn: 'Do you want a calmer daily routine this week?',
          stemAr: 'هل تريد روتيناً يومياً أكثر هدوءاً هذا الأسبوع؟',
          scale: BrainCheckScale.yesNo,
          order: 3,
        ),
        const BrainCheckQuestion(
          id: 'lite_q5',
          sectionId: 'lite_recovery',
          stemEn: 'Can you protect a short recovery session on most days?',
          stemAr: 'هل تستطيع حماية جلسة تعافٍ قصيرة في معظم الأيام؟',
          scale: BrainCheckScale.likert5,
          order: 4,
        ),
        const BrainCheckQuestion(
          id: 'lite_q6',
          sectionId: 'lite_recovery',
          stemEn: 'How ready are you to start your daily program?',
          stemAr: 'ما مدى استعدادك لبدء برنامجك اليومي؟',
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
          stemEn: 'Compared with last week, how steady is your focus today?',
          stemAr: 'مقارنة بالأسبوع الماضي، ما مدى ثبات تركيزك اليوم؟',
          scale: BrainCheckScale.likert5,
          order: 0,
        ),
        const BrainCheckQuestion(
          id: 'pulse_q2',
          sectionId: 'pulse_check',
          stemEn: 'Did you take at least one calm break recently?',
          stemAr: 'هل أخذت استراحة هادئة واحدة على الأقل مؤخراً؟',
          scale: BrainCheckScale.yesNo,
          order: 1,
        ),
        const BrainCheckQuestion(
          id: 'pulse_q3',
          sectionId: 'pulse_check',
          stemEn: 'How manageable is the urge to escape into screens?',
          stemAr: 'ما مدى قابلية إدارة الرغبة في الهروب إلى الشاشات؟',
          scale: BrainCheckScale.likert5,
          order: 2,
        ),
        const BrainCheckQuestion(
          id: 'pulse_q4',
          sectionId: 'pulse_check',
          stemEn: 'Do you still want to continue your recovery path?',
          stemAr: 'هل ما زلت تريد مواصلة مسار التعافي؟',
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
          stemEn: 'How often do you finish short tasks without opening other apps?',
          stemAr: 'كم مرة تُكمل المهام القصيرة دون فتح تطبيقات أخرى؟',
          scale: BrainCheckScale.likert5,
          order: 0,
        ),
        const BrainCheckQuestion(
          id: 'full_q2',
          sectionId: 'full_attention',
          stemEn: 'How often can you read a full page without losing the thread?',
          stemAr: 'كم مرة تستطيع قراءة صفحة كاملة دون فقدان الخيط؟',
          scale: BrainCheckScale.likert5,
          order: 1,
        ),
        const BrainCheckQuestion(
          id: 'full_q3',
          sectionId: 'full_attention',
          stemEn: 'How often do notifications pull you away from what you were doing?',
          stemAr: 'كم مرة تسحبك الإشعارات بعيداً عما كنت تفعله؟',
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
          stemEn: 'How calm are your evenings when you avoid late scrolling?',
          stemAr: 'ما مدى هدوء مسائك عندما تتجنب التصفح المتأخر؟',
          scale: BrainCheckScale.likert5,
          order: 3,
        ),
        const BrainCheckQuestion(
          id: 'full_q5',
          sectionId: 'full_mood',
          stemEn: 'How quickly do you recover after a stressful online moment?',
          stemAr: 'كم بسرعة تتعافى بعد لحظة توتر عبر الإنترنت؟',
          scale: BrainCheckScale.likert5,
          order: 4,
        ),
        const BrainCheckQuestion(
          id: 'full_q6',
          sectionId: 'full_mood',
          stemEn: 'How often do you use screens to avoid uncomfortable feelings?',
          stemAr: 'كم مرة تستخدم الشاشات لتجنب مشاعر غير مريحة؟',
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
          stemEn: 'How consistent is your sleep window most nights?',
          stemAr: 'ما مدى ثبات نافذة نومك في معظم الليالي؟',
          scale: BrainCheckScale.likert5,
          order: 6,
        ),
        const BrainCheckQuestion(
          id: 'full_q8',
          sectionId: 'full_habits',
          stemEn: 'Do you move your body at least briefly on most days?',
          stemAr: 'هل تحرّك جسمك ولو لفترة قصيرة في معظم الأيام؟',
          scale: BrainCheckScale.yesNo,
          order: 7,
        ),
        const BrainCheckQuestion(
          id: 'full_q9',
          sectionId: 'full_habits',
          stemEn: 'How often do you protect offline time for rest or people?',
          stemAr: 'كم مرة تحمي وقتاً دون اتصال للراحة أو للناس؟',
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
          stemEn: 'How clearly do you know why you want a cleaner digital life?',
          stemAr: 'ما مدى وضوح سبب رغبتك في حياة رقمية أنظف؟',
          scale: BrainCheckScale.likert5,
          order: 9,
        ),
        const BrainCheckQuestion(
          id: 'full_q11',
          sectionId: 'full_intention',
          stemEn: 'Can you name one small change you will try next?',
          stemAr: 'هل تستطيع تسمية تغيير صغير ستجربه لاحقاً؟',
          scale: BrainCheckScale.yesNo,
          order: 10,
        ),
        const BrainCheckQuestion(
          id: 'full_q12',
          sectionId: 'full_intention',
          stemEn: 'How ready do you feel for a personal recovery path?',
          stemAr: 'ما مدى استعدادك لمسار تعافٍ شخصي؟',
          scale: BrainCheckScale.likert5,
          order: 11,
        ),
      ],
    ),
  ]);
}
