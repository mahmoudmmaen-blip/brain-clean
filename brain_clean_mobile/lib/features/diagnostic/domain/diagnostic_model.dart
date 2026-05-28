import 'package:json_annotation/json_annotation.dart';

import '../../../core/constants/bc_score_constants.dart';

part 'diagnostic_model.g.dart';

/// Severity bands for Dr. Moneam's Brain Rot score (0–10).
enum InterpretationBand {
  /// 0–2 affirmative answers.
  mild,

  /// 3–5 affirmative answers.
  moderate,

  /// 6–8 affirmative answers.
  severe,

  /// 9–10 affirmative answers.
  critical,
}

/// Typed access to centralized Arabic band copy — no widget-level translation.
extension InterpretationBandLabels on InterpretationBand {
  /// Exact Dr. Moneam severity label for this band.
  String get labelAr => BrainRotTest.interpretationLabelAr(this);

  /// Inclusive score range for this band on the 0–10 Brain Rot scale.
  (int min, int max) get scoreRange => switch (this) {
        InterpretationBand.mild => (0, 2),
        InterpretationBand.moderate => (3, 5),
        InterpretationBand.severe => (6, 8),
        InterpretationBand.critical => (9, 10),
      };
}

/// Machine-readable Brain Rot outcome — UI reads [interpretationAr] only.
class BrainRotInterpretation {
  const BrainRotInterpretation({
    required this.score,
    required this.band,
    required this.interpretationAr,
  });

  final int score;
  final InterpretationBand band;

  /// Exact Arabic band copy from Dr. Moneam's protocol (never hardcode in UI).
  final String interpretationAr;
}

/// Dr. Moneam's Brain Rot (تعفن الدماغ) self-assessment — 10 yes/no items.
///
/// Each affirmative answer counts as 1 point; total score is 0–10.
abstract final class BrainRotTest {
  BrainRotTest._();

  static const int questionCount = 10;

  /// Band 0–2 — Dr. Moneam protocol.
  static const String labelMildAr = 'ضباب دماغي خفيف أو شبه معدوم';

  /// Band 3–5 — Dr. Moneam protocol.
  static const String labelModerateAr =
      'بداية تعفن دماغ وبعض التأثير على الحياة اليومية';

  /// Band 6–8 — Dr. Moneam protocol.
  static const String labelSevereAr =
      'تعفن دماغ واضح يؤثر على التركيز والإنتاجية';

  /// Band 9–10 — Dr. Moneam protocol.
  static const String labelCriticalAr =
      'تعفن دماغ شديد ينصح بمراجعة طبيب أو مختص';

  /// All four Arabic interpretation bands — single source of truth for UI/tests.
  static const Map<InterpretationBand, String> interpretationLabelsAr = {
    InterpretationBand.mild: labelMildAr,
    InterpretationBand.moderate: labelModerateAr,
    InterpretationBand.severe: labelSevereAr,
    InterpretationBand.critical: labelCriticalAr,
  };

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

  /// Exact Arabic label for [band] — use instead of hardcoding strings in widgets.
  static String interpretationLabelAr(InterpretationBand band) =>
      interpretationLabelsAr[band]!;

  /// Clinical interpretation bands per Dr. Moneam's protocol (0–2 / 3–5 / 6–8 / 9–10).
  static String interpretScore(int score) =>
      interpretationLabelAr(getBand(score));

  /// Full scoring pipeline: count → band → centralized Arabic label.
  static BrainRotInterpretation evaluate(List<bool> answers) {
    final score = calculateScore(answers);
    final band = getBand(score);
    return BrainRotInterpretation(
      score: score,
      band: band,
      interpretationAr: interpretationLabelAr(band),
    );
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

  /// Centralized Brain Rot copy — questions + four interpretation bands.
  static const List<String> brainRotQuestionsAr = BrainRotTest.questionsAr;

  static const Map<InterpretationBand, String> brainRotInterpretationLabelsAr =
      BrainRotTest.interpretationLabelsAr;

  static int calculateBrainRotScore(List<bool> answers) =>
      BrainRotTest.calculateScore(answers);

  static String interpretBrainRotScore(int score) =>
      BrainRotTest.interpretScore(score);

  /// Arabic severity label for [band] — prefer [InterpretationBand.labelAr].
  static String brainRotInterpretationLabelAr(InterpretationBand band) =>
      band.labelAr;

  static InterpretationBand getBrainRotBand(int score) =>
      BrainRotTest.getBand(score);

  static BrainRotInterpretation evaluateBrainRot(List<bool> answers) =>
      BrainRotTest.evaluate(answers);

  /// Score → band → Arabic label (single entry for result screens).
  static String brainRotInterpretationForScore(int score) =>
      getBrainRotBand(score).labelAr;

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
