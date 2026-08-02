import 'brain_check_question.dart';

/// Progressive chapter / section within a Brain Check mode.
class BrainCheckSection {
  const BrainCheckSection({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.order,
    required this.questions,
  });

  final String id;
  final String titleEn;
  final String titleAr;
  final int order;
  final List<BrainCheckQuestion> questions;

  String titleForLocale(String languageCode) {
    final code = languageCode.toLowerCase();
    if (code.startsWith('ar')) return titleAr;
    return titleEn;
  }

  bool get isEmpty => questions.isEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'titleEn': titleEn,
        'titleAr': titleAr,
        'order': order,
        'questions': questions.map((q) => q.toJson()).toList(growable: false),
      };

  factory BrainCheckSection.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'];
    final questions = <BrainCheckQuestion>[];
    if (rawQuestions is List) {
      for (final item in rawQuestions) {
        if (item is Map) {
          questions.add(
            BrainCheckQuestion.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return BrainCheckSection(
      id: json['id'] as String,
      titleEn: json['titleEn'] as String,
      titleAr: json['titleAr'] as String,
      order: (json['order'] as num?)?.toInt() ?? 0,
      questions: List<BrainCheckQuestion>.unmodifiable(questions),
    );
  }
}
