/// Resolved bilingual `plan.today.because` line.
class PlanBecause {
  const PlanBecause({
    required this.templateKey,
    required this.textEn,
    required this.textAr,
  });

  final String templateKey;
  final String textEn;
  final String textAr;

  String forLocale(String languageCode) =>
      languageCode == 'ar' ? textAr : textEn;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'templateKey': templateKey,
        'textEn': textEn,
        'textAr': textAr,
      };

  factory PlanBecause.fromJson(Map<String, dynamic> json) {
    return PlanBecause(
      templateKey: json['templateKey'] as String? ?? 'because_fallback',
      textEn: json['textEn'] as String? ?? '',
      textAr: json['textAr'] as String? ?? '',
    );
  }
}

/// Local template resolution (no AI). Placeholders use titles only.
abstract final class PlanBecauseTemplates {
  static const priority = 'because_priority';
  static const priorityLowConf = 'because_priority_lowconf';
  static const withStrength = 'because_with_strength';
  static const pulse = 'because_pulse';
  static const starter = 'because_starter';
  static const fallback = 'because_fallback';

  static const allKeys = [
    priority,
    priorityLowConf,
    withStrength,
    pulse,
    starter,
    fallback,
  ];

  static PlanBecause resolve({
    required String templateKey,
    String domainEn = '',
    String domainAr = '',
    String strengthEn = '',
    String strengthAr = '',
  }) {
    switch (templateKey) {
      case priority:
        return PlanBecause(
          templateKey: priority,
          textEn:
              'Today focuses on $domainEn because your check showed it needs gentler support.',
          textAr:
              'اليوم نركز على $domainAr لأن فحصك أظهر أنه يحتاج دعماً ألطف.',
        );
      case priorityLowConf:
        return PlanBecause(
          templateKey: priorityLowConf,
          textEn:
              'Today gently supports $domainEn. This estimate is still early — keep it light.',
          textAr:
              'اليوم ندعم $domainAr بلطف. هذا التقدير ما زال مبكراً — اجعله خفيفاً.',
        );
      case withStrength:
        return PlanBecause(
          templateKey: withStrength,
          textEn:
              'Today supports $domainEn, while keeping $strengthEn as something that already helps.',
          textAr:
              'اليوم ندعم $domainAr، مع الإبقاء على $strengthAr كشيء يساعدك بالفعل.',
        );
      case pulse:
        return const PlanBecause(
          templateKey: pulse,
          textEn:
              'A short check-in today helps you notice how focus and calm feel right now.',
          textAr:
              'تفقد قصير اليوم يساعدك على ملاحظة كيف يبدو التركيز والهدوء الآن.',
        );
      case starter:
        return const PlanBecause(
          templateKey: starter,
          textEn:
              'A calm starter step while your personal plan finishes shaping.',
          textAr: 'خطوة بداية هادئة بينما تتشكّل خطتك الشخصية.',
        );
      case fallback:
      default:
        return const PlanBecause(
          templateKey: fallback,
          textEn: 'A simple practice to keep momentum without overload.',
          textAr: 'ممارسة بسيطة للحفاظ على الزخم دون إرهاق.',
        );
    }
  }
}
