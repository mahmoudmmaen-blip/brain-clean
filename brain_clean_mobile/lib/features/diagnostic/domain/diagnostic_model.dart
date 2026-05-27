import 'package:json_annotation/json_annotation.dart';

import '../../../core/constants/bc_score_constants.dart';

part 'diagnostic_model.g.dart';

/// Severity bands for Dr. Moneam's Brain Rot score (0–10).
enum InterpretationBand {
  mild,
  moderate,
  severe,
  critical,
}

/// Dr. Moneam's Brain Rot (تعفن الدماغ) self-assessment — 10 yes/no items.
///
/// Each affirmative answer counts as 1 point; total score is 0–10.
abstract final class BrainRotTest {
  BrainRotTest._();

  static const int questionCount = 10;

  /// Arabic prompts shown in the diagnostic flow (yes = symptom present).
  static const List<String> questionsAr = [
    'أشعر أن ذاكرتي قصيرة المدى ضعفت (أنسى ما قيل لي مؤخراً).',
    'أواجه صعوبة في التركيز على مهمة واحدة لفترة كافية.',
    'يبدو لي أن تفكيري بطيء مقارنة بما كنت عليه من قبل.',
    'أصاب بحالة "تشويش ذهني" أو أجد صعوبة في تنظيم أفكاري.',
    'أشعر بتعب ذهني بعد فترات قصيرة من التفكير أو العمل الذهني.',
    'أجد صعوبة في العثور على الكلمات المناسبة عند التحدث أو الكتابة.',
    'أشعر بأنني "مشتت" أو أن أفكاري تقفز من فكرة لأخرى بسرعة.',
    'يصبح من الصعب علي اتخاذ قرارات بسيطة أو التخطيط لمهام.',
    'أجد نفسي أعمل ببطء أكثر من المعتاد، أو أحتاج إلى وقت أطول لإنجاز نفس المهام.',
    'هذه الأعراض تؤثر على حياتي اليومية (في العمل أو الدراسة أو العلاقات).',
  ];

  /// Sums affirmative answers (symptom present = true → +1).
  static int calculateScore(List<bool> answers) {
    if (answers.length != questionCount) {
      throw ArgumentError.value(
        answers,
        'answers',
        'Brain Rot test requires exactly $questionCount yes/no answers.',
      );
    }
    return answers.where((a) => a).length;
  }

  static InterpretationBand getBand(int score) {
    final s = score.clamp(0, questionCount);
    if (s <= 2) return InterpretationBand.mild;
    if (s <= 5) return InterpretationBand.moderate;
    if (s <= 8) return InterpretationBand.severe;
    return InterpretationBand.critical;
  }

  /// Clinical interpretation bands per Dr. Moneam's protocol.
  static String interpretScore(int score) {
    switch (getBand(score)) {
      case InterpretationBand.mild:
        return 'ضباب دماغي خفيف أو شبه معدوم';
      case InterpretationBand.moderate:
        return 'بداية تعفن دماغ وبعض التأثير على الحياة اليومية';
      case InterpretationBand.severe:
        return 'تعفن دماغ واضح يؤثر على التركيز والإنتاجية';
      case InterpretationBand.critical:
        return 'تعفن دماغ شديد ينصح بمراجعة طبيب أو مختص';
    }
  }
}

/// Firestore + legacy camelCase JSON keys for detox habit metrics.
abstract final class DiagnosticModelJsonKeys {
  static const boredomBefriendedSnake = 'boredom_befriended';
  static const boredomBefriendedCamel = 'boredomBefriended';
  static const delayedGratificationCountSnake = 'delayed_gratification_count';
  static const delayedGratificationCountCamel = 'delayedGratificationCount';
  static const bodyActivatedSnake = 'body_activated';
  static const bodyActivatedCamel = 'bodyActivated';
}

dynamic _parseMetric(
  Map<String, dynamic> json,
  String snakeKey,
  String camelKey,
  dynamic defaultValue,
) {
  if (json.containsKey(snakeKey)) return json[snakeKey];
  if (json.containsKey(camelKey)) return json[camelKey];
  return defaultValue;
}

bool _parseBoolMetric(
  Map<String, dynamic> json,
  String snakeKey,
  String camelKey,
) =>
    _parseMetric(json, snakeKey, camelKey, false) as bool;

int _parseIntMetric(
  Map<String, dynamic> json,
  String snakeKey,
  String camelKey,
) =>
    (_parseMetric(json, snakeKey, camelKey, 0) as num).toInt();

/// BHI pillars (0–100 each) plus 7-Day Dopamine Detox Protocol habit metrics.
@JsonSerializable(createFactory: false)
class DiagnosticModel {
  const DiagnosticModel({
    required this.brainPerformance,
    required this.digitalDiscipline,
    required this.healthyHabits,
    required this.consistency,
    this.boredomBefriended = false,
    this.delayedGratificationCount = 0,
    this.bodyActivated = false,
  });

  final double brainPerformance;
  final double digitalDiscipline;
  final double healthyHabits;
  final double consistency;

  @JsonKey(name: DiagnosticModelJsonKeys.boredomBefriendedSnake)
  final bool boredomBefriended;

  @JsonKey(name: DiagnosticModelJsonKeys.delayedGratificationCountSnake)
  final int delayedGratificationCount;

  @JsonKey(name: DiagnosticModelJsonKeys.bodyActivatedSnake)
  final bool bodyActivated;

  @JsonKey(includeFromJson: false, includeToJson: false)
  double get bcScore => calculateBcScore();

  @JsonKey(includeFromJson: false, includeToJson: false)
  int get bcScoreRounded => bcScore.round();

  @JsonKey(includeFromJson: false, includeToJson: false)
  double get habitsPillarContribution =>
      healthyHabits * BcScoreConstants.healthyHabitsWeight;

  static const List<String> brainRotQuestionsAr = BrainRotTest.questionsAr;

  static int calculateBrainRotScore(List<bool> answers) =>
      BrainRotTest.calculateScore(answers);

  static String interpretBrainRotScore(int score) =>
      BrainRotTest.interpretScore(score);

  static InterpretationBand getBrainRotBand(int score) =>
      BrainRotTest.getBand(score);

  double calculateBcScore() {
    final score = (brainPerformance * BcScoreConstants.brainPerformanceWeight) +
        (digitalDiscipline * BcScoreConstants.digitalDisciplineWeight) +
        (healthyHabits * BcScoreConstants.healthyHabitsWeight) +
        (consistency * BcScoreConstants.consistencyWeight);

    if (score < BcScoreConstants.bhiScoreFloor) {
      return BcScoreConstants.bhiScoreFloor;
    }
    return score.clamp(0.0, 100.0);
  }

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticModel(
      brainPerformance: (json['brainPerformance'] as num).toDouble(),
      digitalDiscipline: (json['digitalDiscipline'] as num).toDouble(),
      healthyHabits: (json['healthyHabits'] as num).toDouble(),
      consistency: (json['consistency'] as num).toDouble(),
      boredomBefriended: _parseBoolMetric(
        json,
        DiagnosticModelJsonKeys.boredomBefriendedSnake,
        DiagnosticModelJsonKeys.boredomBefriendedCamel,
      ),
      delayedGratificationCount: _parseIntMetric(
        json,
        DiagnosticModelJsonKeys.delayedGratificationCountSnake,
        DiagnosticModelJsonKeys.delayedGratificationCountCamel,
      ),
      bodyActivated: _parseBoolMetric(
        json,
        DiagnosticModelJsonKeys.bodyActivatedSnake,
        DiagnosticModelJsonKeys.bodyActivatedCamel,
      ),
    );
  }

  Map<String, dynamic> toJson() => _$DiagnosticModelToJson(this);
}
