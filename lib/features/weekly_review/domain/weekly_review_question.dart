import 'weekly_review_enums.dart';

/// Frozen V1 question definition.
class WeeklyReviewQuestion {
  const WeeklyReviewQuestion({
    required this.id,
    required this.type,
    required this.required,
    this.allowedValues = const [],
    this.scaleMin,
    this.scaleMax,
    this.maxSelections,
  });

  final String id;
  final WeeklyReviewQuestionType type;
  final bool required;
  final List<String> allowedValues;
  final int? scaleMin;
  final int? scaleMax;
  final int? maxSelections;
}

/// Exact Contract V1 catalog — order is authoritative.
abstract final class WeeklyReviewQuestionCatalog {
  static const manageability = 'wrv_manageability';
  static const pauseFocus = 'wrv_pause_focus';
  static const obstacle = 'wrv_obstacle';
  static const support = 'wrv_support';
  static const accessibilityUsed = 'wrv_accessibility_used';

  static const List<WeeklyReviewQuestion> inOrder = [
    WeeklyReviewQuestion(
      id: manageability,
      type: WeeklyReviewQuestionType.singleChoice,
      required: true,
      allowedValues: ['too_light', 'about_right', 'too_demanding'],
    ),
    WeeklyReviewQuestion(
      id: pauseFocus,
      type: WeeklyReviewQuestionType.boundedScale,
      required: true,
      scaleMin: 1,
      scaleMax: 5,
    ),
    WeeklyReviewQuestion(
      id: obstacle,
      type: WeeklyReviewQuestionType.singleChoice,
      required: true,
      allowedValues: [
        'time',
        'forgetfulness',
        'low_energy',
        'interruptions',
        'unclear_step',
        'access_or_environment',
        'no_major_obstacle',
      ],
    ),
    WeeklyReviewQuestion(
      id: support,
      type: WeeklyReviewQuestionType.multiSelect,
      required: false,
      maxSelections: 2,
      allowedValues: [
        'shorter_path',
        'clearer_timing',
        'quieter_environment',
        'accessibility_alternative',
        'stronger_reminder',
        'same_plan_is_working',
      ],
    ),
    WeeklyReviewQuestion(
      id: accessibilityUsed,
      type: WeeklyReviewQuestionType.boolean_,
      required: false,
    ),
  ];

  static WeeklyReviewQuestion byId(String id) {
    for (final q in inOrder) {
      if (q.id == id) return q;
    }
    throw ArgumentError.value(id, 'id', 'Unknown weekly review question');
  }

  static int indexOf(String id) {
    for (var i = 0; i < inOrder.length; i++) {
      if (inOrder[i].id == id) return i;
    }
    return -1;
  }
}
