class DailyQuote {
  const DailyQuote({required this.ar, required this.en});

  final String ar;
  final String en;

  String forLocale(bool isArabic) => isArabic ? ar : en;
}

/// 30 science-based focus / dopamine / brain quotes.
const List<DailyQuote> dailyQuotes = [
  DailyQuote(
    ar: 'كل مرة تقاوم فيها الإلهاء، تبني خلية عصبية جديدة',
    en: 'Every time you resist distraction, you build a new neural pathway',
  ),
  DailyQuote(
    ar: 'الدوبامين لا يكافئ الإنجاز، بل يكافئ التوقع',
    en: 'Dopamine rewards anticipation, not achievement',
  ),
  DailyQuote(
    ar: 'التركيز مهارة عضلية — كل تمرين يقوّيها',
    en: 'Focus is a muscle — every rep makes it stronger',
  ),
  DailyQuote(
    ar: '10 دقائق من التركيز العميق تفوق ساعة من التشتت',
    en: 'Ten minutes of deep focus beats an hour of scattered attention',
  ),
  DailyQuote(
    ar: 'دماغك يتعلم من التكرار، لا من النية',
    en: 'Your brain learns from repetition, not intention',
  ),
  DailyQuote(
    ar: 'الهاتف مصمم لسرقة انتباهك — أنت من يستعيده',
    en: 'Your phone is designed to steal attention — you reclaim it',
  ),
  DailyQuote(
    ar: 'الملل ليس عدوك، بل بوابة الإبداع',
    en: 'Boredom is not your enemy — it is the gateway to creativity',
  ),
  DailyQuote(
    ar: 'النوم العميق يغسل دماغك من السموم العصبية',
    en: 'Deep sleep washes neurotoxins from your brain',
  ),
  DailyQuote(
    ar: 'مهمة واحدة في كل مرة = دماغ أهدأ',
    en: 'One task at a time equals a calmer brain',
  ),
  DailyQuote(
    ar: 'كل "لا" للإشعار هو "نعم" لتركيزك',
    en: 'Every no to a notification is a yes to your focus',
  ),
  DailyQuote(
    ar: 'الانتباه المستدام يبني ثقة بالنفس',
    en: 'Sustained attention builds self-trust',
  ),
  DailyQuote(
    ar: 'الإفراط في المحفزات يُضعف دائرة المكافأة',
    en: 'Overstimulation weakens your reward circuitry',
  ),
  DailyQuote(
    ar: 'الصمت يعيد معايرة جهازك العصبي',
    en: 'Silence recalibrates your nervous system',
  ),
  DailyQuote(
    ar: 'التركيز على التنفس ينشط القشرة الأمامية',
    en: 'Breath focus activates your prefrontal cortex',
  ),
  DailyQuote(
    ar: 'العادات الصغيرة تعيد تشكيل الدماغ على المدى الطويل',
    en: 'Small habits reshape the brain over time',
  ),
  DailyQuote(
    ar: 'تأجيل المكافأة يقوّي ضبط النفس',
    en: 'Delayed gratification strengthens self-control',
  ),
  DailyQuote(
    ar: 'الحركة البدنية تغذّي الخلايا العصبية',
    en: 'Physical movement feeds your neurons',
  ),
  DailyQuote(
    ar: 'الضوضاء البيضاء تخفّض القلق وتزيد التركيز',
    en: 'White noise lowers anxiety and boosts focus',
  ),
  DailyQuote(
    ar: 'الوعي بالمشاعر يقلل اندفاعات الدوبامين',
    en: 'Emotional awareness reduces dopamine impulsivity',
  ),
  DailyQuote(
    ar: 'الدماغ يحب الروتين المفيد، لا الفوضى',
    en: 'Your brain loves useful routine, not chaos',
  ),
  DailyQuote(
    ar: 'كل يوم بدون إدمان هو انتصار عصبي',
    en: 'Every addiction-free day is a neural victory',
  ),
  DailyQuote(
    ar: 'التركيز العميق يطلق موجات ألفا المهدئة',
    en: 'Deep focus triggers calming alpha brain waves',
  ),
  DailyQuote(
    ar: 'قلل المدخلات، زد الوضوح الذهني',
    en: 'Reduce inputs, increase mental clarity',
  ),
  DailyQuote(
    ar: 'الانتباه الواعي يبطئ ردود الفعل العاطفية',
    en: 'Mindful attention slows emotional reactivity',
  ),
  DailyQuote(
    ar: 'الدماغ البشري يتعب من التبديل المتكرر بين المهام',
    en: 'The human brain fatigues from constant task-switching',
  ),
  DailyQuote(
    ar: 'الاستراحات القصيرة تمنع احتراق الانتباه',
    en: 'Short breaks prevent attention burnout',
  ),
  DailyQuote(
    ar: 'الهدف الواضح يوجّه طاقة الدماغ',
    en: 'A clear goal directs brain energy',
  ),
  DailyQuote(
    ar: 'الامتنان يعيد توازن الكيمياء العصبية',
    en: 'Gratitude rebalances your neurochemistry',
  ),
  DailyQuote(
    ar: 'كل جلسة تركيز تبني عادات عصبية أقوى',
    en: 'Each focus session builds stronger neural habits',
  ),
  DailyQuote(
    ar: 'العقل النقي يبدأ بقرار واحد واعٍ اليوم',
    en: 'A pure mind starts with one conscious choice today',
  ),
];

/// Picks today's quote index (0–29) from day-of-year.
int dailyQuoteIndex(DateTime date) {
  final start = DateTime(date.year, 1, 1);
  final dayOfYear = date.difference(start).inDays + 1;
  return dayOfYear % dailyQuotes.length;
}

DailyQuote quoteForDate(DateTime date) =>
    dailyQuotes[dailyQuoteIndex(date)];
