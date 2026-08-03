import 'weekly_review_enums.dart';
import 'weekly_review_question.dart';

/// One answer payload for a question (local only).
class WeeklyReviewResponse {
  const WeeklyReviewResponse({
    required this.questionId,
    required this.answeredAt,
    this.singleChoice,
    this.scaleValue,
    this.multiSelect,
    this.booleanValue,
  });

  final String questionId;
  final DateTime answeredAt;
  final String? singleChoice;
  final int? scaleValue;
  final List<String>? multiSelect;
  final bool? booleanValue;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'questionId': questionId,
        'answeredAt': answeredAt.toUtc().toIso8601String(),
        if (singleChoice != null) 'singleChoice': singleChoice,
        if (scaleValue != null) 'scaleValue': scaleValue,
        if (multiSelect != null) 'multiSelect': multiSelect,
        if (booleanValue != null) 'booleanValue': booleanValue,
      };

  factory WeeklyReviewResponse.fromJson(Map<String, dynamic> json) {
    return WeeklyReviewResponse(
      questionId: json['questionId'] as String,
      answeredAt: DateTime.parse(json['answeredAt'] as String).toUtc(),
      singleChoice: json['singleChoice'] as String?,
      scaleValue: json['scaleValue'] as int?,
      multiSelect: (json['multiSelect'] as List?)
          ?.map((e) => e as String)
          .toList(growable: false),
      booleanValue: json['booleanValue'] as bool?,
    );
  }
}

/// Validation result — invalid values must not be persisted.
class WeeklyReviewValidationResult {
  const WeeklyReviewValidationResult._({
    required this.isValid,
    this.errorCode,
  });

  const WeeklyReviewValidationResult.ok()
      : this._(isValid: true);

  const WeeklyReviewValidationResult.fail(String code)
      : this._(isValid: false, errorCode: code);

  final bool isValid;
  final String? errorCode;
}

abstract final class WeeklyReviewResponseValidator {
  static WeeklyReviewValidationResult validate(WeeklyReviewResponse response) {
    WeeklyReviewQuestion question;
    try {
      question = WeeklyReviewQuestionCatalog.byId(response.questionId);
    } catch (_) {
      return const WeeklyReviewValidationResult.fail('unknown_question');
    }

    switch (question.type) {
      case WeeklyReviewQuestionType.singleChoice:
        final v = response.singleChoice;
        if (v == null || !question.allowedValues.contains(v)) {
          return const WeeklyReviewValidationResult.fail('invalid_single_choice');
        }
        if (response.scaleValue != null ||
            response.multiSelect != null ||
            response.booleanValue != null) {
          return const WeeklyReviewValidationResult.fail('extra_fields');
        }
        return const WeeklyReviewValidationResult.ok();

      case WeeklyReviewQuestionType.boundedScale:
        final v = response.scaleValue;
        final min = question.scaleMin ?? 1;
        final max = question.scaleMax ?? 5;
        if (v == null || v < min || v > max) {
          return const WeeklyReviewValidationResult.fail('invalid_scale');
        }
        if (response.singleChoice != null ||
            response.multiSelect != null ||
            response.booleanValue != null) {
          return const WeeklyReviewValidationResult.fail('extra_fields');
        }
        return const WeeklyReviewValidationResult.ok();

      case WeeklyReviewQuestionType.multiSelect:
        final list = response.multiSelect;
        if (list == null) {
          return const WeeklyReviewValidationResult.fail('invalid_multi_select');
        }
        final maxSel = question.maxSelections ?? 2;
        if (list.length > maxSel) {
          return const WeeklyReviewValidationResult.fail('too_many_selections');
        }
        if (list.toSet().length != list.length) {
          return const WeeklyReviewValidationResult.fail('duplicate_selection');
        }
        for (final item in list) {
          if (!question.allowedValues.contains(item)) {
            return const WeeklyReviewValidationResult.fail('invalid_multi_select');
          }
        }
        if (response.singleChoice != null ||
            response.scaleValue != null ||
            response.booleanValue != null) {
          return const WeeklyReviewValidationResult.fail('extra_fields');
        }
        return const WeeklyReviewValidationResult.ok();

      case WeeklyReviewQuestionType.boolean_:
        if (response.booleanValue == null) {
          return const WeeklyReviewValidationResult.fail('invalid_boolean');
        }
        if (response.singleChoice != null ||
            response.scaleValue != null ||
            response.multiSelect != null) {
          return const WeeklyReviewValidationResult.fail('extra_fields');
        }
        return const WeeklyReviewValidationResult.ok();
    }
  }

  /// Required questions must have a valid stored answer for completion.
  static bool requiredAnswersComplete(Map<String, WeeklyReviewResponse> byId) {
    for (final q in WeeklyReviewQuestionCatalog.inOrder) {
      if (!q.required) continue;
      final r = byId[q.id];
      if (r == null) return false;
      if (!validate(r).isValid) return false;
    }
    return true;
  }
}
