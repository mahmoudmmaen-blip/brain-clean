import 'brain_check_scale.dart';

/// Single self-report Brain Check item (CHK-02).
class BrainCheckQuestion {
  const BrainCheckQuestion({
    required this.id,
    required this.sectionId,
    required this.stemEn,
    required this.stemAr,
    required this.scale,
    required this.order,
  });

  final String id;
  final String sectionId;
  final String stemEn;
  final String stemAr;
  final BrainCheckScale scale;
  final int order;

  /// Locale-aware stem (`ar` → Arabic, otherwise English).
  String stemForLocale(String languageCode) {
    final code = languageCode.toLowerCase();
    if (code.startsWith('ar')) return stemAr;
    return stemEn;
  }

  /// RTL when Arabic stem is active.
  bool isRtlForLocale(String languageCode) =>
      languageCode.toLowerCase().startsWith('ar');

  TextDirectionHint textDirectionForLocale(String languageCode) =>
      isRtlForLocale(languageCode)
          ? TextDirectionHint.rtl
          : TextDirectionHint.ltr;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'sectionId': sectionId,
        'stemEn': stemEn,
        'stemAr': stemAr,
        'scale': scale.wireName,
        'order': order,
      };

  factory BrainCheckQuestion.fromJson(Map<String, dynamic> json) {
    return BrainCheckQuestion(
      id: json['id'] as String,
      sectionId: json['sectionId'] as String,
      stemEn: json['stemEn'] as String,
      stemAr: json['stemAr'] as String,
      scale: BrainCheckScaleX.fromWire(json['scale'] as String?),
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Lightweight direction hint so domain stays Flutter-widget free.
enum TextDirectionHint { ltr, rtl }
