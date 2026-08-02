import 'measurement_confidence.dart';

/// User-facing explanation keys / resolved copy for a ProfilePack.
class MeasurementExplanation {
  const MeasurementExplanation({
    required this.whatItIsEn,
    required this.whatItIsAr,
    required this.whatItIsNotEn,
    required this.whatItIsNotAr,
    required this.strongerAreasEn,
    required this.strongerAreasAr,
    required this.supportAreasEn,
    required this.supportAreasAr,
    required this.whyMayChangeEn,
    required this.whyMayChangeAr,
    required this.confidenceEn,
    required this.confidenceAr,
    required this.retakeEn,
    required this.retakeAr,
    required this.scorePendingEn,
    required this.scorePendingAr,
  });

  final String whatItIsEn;
  final String whatItIsAr;
  final String whatItIsNotEn;
  final String whatItIsNotAr;
  final String strongerAreasEn;
  final String strongerAreasAr;
  final String supportAreasEn;
  final String supportAreasAr;
  final String whyMayChangeEn;
  final String whyMayChangeAr;
  final String confidenceEn;
  final String confidenceAr;
  final String retakeEn;
  final String retakeAr;
  final String scorePendingEn;
  final String scorePendingAr;

  String whatItIs(String lang) => lang == 'ar' ? whatItIsAr : whatItIsEn;
  String whatItIsNot(String lang) => lang == 'ar' ? whatItIsNotAr : whatItIsNotEn;
  String strongerAreas(String lang) =>
      lang == 'ar' ? strongerAreasAr : strongerAreasEn;
  String supportAreas(String lang) =>
      lang == 'ar' ? supportAreasAr : supportAreasEn;
  String whyMayChange(String lang) =>
      lang == 'ar' ? whyMayChangeAr : whyMayChangeEn;
  String confidence(String lang) => lang == 'ar' ? confidenceAr : confidenceEn;
  String retake(String lang) => lang == 'ar' ? retakeAr : retakeEn;
  String scorePending(String lang) =>
      lang == 'ar' ? scorePendingAr : scorePendingEn;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'whatItIsEn': whatItIsEn,
        'whatItIsAr': whatItIsAr,
        'whatItIsNotEn': whatItIsNotEn,
        'whatItIsNotAr': whatItIsNotAr,
        'strongerAreasEn': strongerAreasEn,
        'strongerAreasAr': strongerAreasAr,
        'supportAreasEn': supportAreasEn,
        'supportAreasAr': supportAreasAr,
        'whyMayChangeEn': whyMayChangeEn,
        'whyMayChangeAr': whyMayChangeAr,
        'confidenceEn': confidenceEn,
        'confidenceAr': confidenceAr,
        'retakeEn': retakeEn,
        'retakeAr': retakeAr,
        'scorePendingEn': scorePendingEn,
        'scorePendingAr': scorePendingAr,
      };

  factory MeasurementExplanation.fromJson(Map<String, dynamic> json) {
    return MeasurementExplanation(
      whatItIsEn: json['whatItIsEn'] as String? ?? '',
      whatItIsAr: json['whatItIsAr'] as String? ?? '',
      whatItIsNotEn: json['whatItIsNotEn'] as String? ?? '',
      whatItIsNotAr: json['whatItIsNotAr'] as String? ?? '',
      strongerAreasEn: json['strongerAreasEn'] as String? ?? '',
      strongerAreasAr: json['strongerAreasAr'] as String? ?? '',
      supportAreasEn: json['supportAreasEn'] as String? ?? '',
      supportAreasAr: json['supportAreasAr'] as String? ?? '',
      whyMayChangeEn: json['whyMayChangeEn'] as String? ?? '',
      whyMayChangeAr: json['whyMayChangeAr'] as String? ?? '',
      confidenceEn: json['confidenceEn'] as String? ?? '',
      confidenceAr: json['confidenceAr'] as String? ?? '',
      retakeEn: json['retakeEn'] as String? ?? '',
      retakeAr: json['retakeAr'] as String? ?? '',
      scorePendingEn: json['scorePendingEn'] as String? ?? '',
      scorePendingAr: json['scorePendingAr'] as String? ?? '',
    );
  }
}

/// Static bilingual catalog — no evidence IDs.
abstract final class ProfileExplanationCatalog {
  static MeasurementExplanation build({
    required List<String> strongerTitlesEn,
    required List<String> strongerTitlesAr,
    required List<String> supportTitlesEn,
    required List<String> supportTitlesAr,
    required MeasurementConfidence confidence,
    required bool scorePending,
  }) {
    final strongerEn = strongerTitlesEn.isEmpty
        ? 'No stronger area stood out yet — that is okay.'
        : 'Reported stronger areas right now: ${strongerTitlesEn.join(', ')}.';
    final strongerAr = strongerTitlesAr.isEmpty
        ? 'لم تبرز منطقة أقوى بعد — وهذا طبيعي.'
        : 'مناطق أقوى كما ظهرت الآن: ${strongerTitlesAr.join('، ')}.';
    final supportEn = supportTitlesEn.isEmpty
        ? 'No clear support focus yet from this check.'
        : 'Areas that may need gentler support: ${supportTitlesEn.join(', ')}.';
    final supportAr = supportTitlesAr.isEmpty
        ? 'لا يوجد تركيز دعم واضح بعد من هذا الفحص.'
        : 'مناطق قد تحتاج دعماً ألطف: ${supportTitlesAr.join('، ')}.';

    final confidenceEn = switch (confidence) {
      MeasurementConfidence.provisional =>
        'This is a provisional snapshot (often from a shorter check). Confidence is limited.',
      MeasurementConfidence.moderate =>
        'This snapshot has moderate confidence — some answers may still be thin.',
      MeasurementConfidence.solid =>
        'This snapshot has solid coverage for the path you took.',
    };
    final confidenceAr = switch (confidence) {
      MeasurementConfidence.provisional =>
        'هذه لقطة أولية (غالباً من فحص أقصر). درجة الثقة محدودة.',
      MeasurementConfidence.moderate =>
        'هذه اللقطة بثقة متوسطة — قد تظل بعض الإجابات خفيفة.',
      MeasurementConfidence.solid =>
        'هذه اللقطة بتغطية جيدة للمسار الذي اخترته.',
    };

    return MeasurementExplanation(
      whatItIsEn:
          'Your Brain Profile is a self-reported snapshot from your Brain Check answers. It is an estimate to help you notice change over time.',
      whatItIsAr:
          'ملف الدماغ لقطة مبنية على إجاباتك في فحص الدماغ. وهو تقدير يساعدك على ملاحظة التغيير مع الوقت.',
      whatItIsNotEn:
          'It is not a medical diagnosis, a neurological exam, evidence of injury, or a measure of intelligence.',
      whatItIsNotAr:
          'ليس تشخيصاً طبياً، ولا فحصاً عصبياً، ولا دليلاً على إصابة، ولا مقياساً للذكاء.',
      strongerAreasEn: strongerEn,
      strongerAreasAr: strongerAr,
      supportAreasEn: supportEn,
      supportAreasAr: supportAr,
      whyMayChangeEn:
          'Your estimate can change when your answers change, when you retake a check, or when more of your path is filled in.',
      whyMayChangeAr:
          'قد يتغير التقدير عندما تتغير إجاباتك، أو عند إعادة الفحص، أو عند اكتمال المزيد من مسارك.',
      confidenceEn: confidenceEn,
      confidenceAr: confidenceAr,
      retakeEn:
          'You can retake a Brain Check anytime. A new check creates a new snapshot — earlier ones stay in history.',
      retakeAr:
          'يمكنك إعادة فحص الدماغ في أي وقت. الفحص الجديد ينشئ لقطة جديدة — وتبقى اللقطات السابقة في السجل.',
      scorePendingEn: scorePending
          ? 'An overall Recovery Score estimate is not finalized yet. Domain summaries below are from your answers only.'
          : 'Overall Recovery Score estimate is available for this snapshot.',
      scorePendingAr: scorePending
          ? 'تقدير درجة التعافي الإجمالية غير مكتمل بعد. ملخصات المجالات أدناه مأخوذة من إجاباتك فقط.'
          : 'تقدير درجة التعافي الإجمالية متاح لهذه اللقطة.',
    );
  }
}
