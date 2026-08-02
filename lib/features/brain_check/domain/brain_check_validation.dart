import 'brain_check_question.dart';
import 'brain_check_scale.dart';

/// Validation outcomes for Brain Check answers and restart gates.
enum BrainCheckValidationCode {
  ok,
  emptyAnswer,
  outOfRange,
  unknownQuestion,
  wrongQuestion,
  restartNotConfirmed,
  notInProgress,
  alreadyComplete,
  noDraft,
}

class BrainCheckValidationResult {
  const BrainCheckValidationResult({
    required this.code,
    this.messageEn,
    this.messageAr,
  });

  final BrainCheckValidationCode code;
  final String? messageEn;
  final String? messageAr;

  bool get isOk => code == BrainCheckValidationCode.ok;

  String messageForLocale(String languageCode) {
    final codeLang = languageCode.toLowerCase();
    if (codeLang.startsWith('ar')) {
      return messageAr ?? messageEn ?? code.name;
    }
    return messageEn ?? messageAr ?? code.name;
  }

  static const ok = BrainCheckValidationResult(code: BrainCheckValidationCode.ok);
}

/// Pure validation helpers for the Brain Check foundation.
abstract final class BrainCheckValidation {
  static BrainCheckValidationResult validateAnswer({
    required BrainCheckQuestion? question,
    required int? value,
    String? expectedQuestionId,
  }) {
    if (question == null) {
      return const BrainCheckValidationResult(
        code: BrainCheckValidationCode.unknownQuestion,
        messageEn: 'Unknown question.',
        messageAr: 'سؤال غير معروف.',
      );
    }
    if (expectedQuestionId != null && expectedQuestionId != question.id) {
      return const BrainCheckValidationResult(
        code: BrainCheckValidationCode.wrongQuestion,
        messageEn: 'Answer does not match the current question.',
        messageAr: 'الإجابة لا تطابق السؤال الحالي.',
      );
    }
    if (value == null) {
      return const BrainCheckValidationResult(
        code: BrainCheckValidationCode.emptyAnswer,
        messageEn: 'Please choose an answer to continue.',
        messageAr: 'يرجى اختيار إجابة للمتابعة.',
      );
    }
    if (value < question.scale.minValue || value > question.scale.maxValue) {
      return BrainCheckValidationResult(
        code: BrainCheckValidationCode.outOfRange,
        messageEn:
            'Answer must be between ${question.scale.minValue} and ${question.scale.maxValue}.',
        messageAr:
            'يجب أن تكون الإجابة بين ${question.scale.minValue} و ${question.scale.maxValue}.',
      );
    }
    return BrainCheckValidationResult.ok;
  }

  static BrainCheckValidationResult validateRestart({required bool confirmed}) {
    if (!confirmed) {
      return const BrainCheckValidationResult(
        code: BrainCheckValidationCode.restartNotConfirmed,
        messageEn: 'Confirm before starting over.',
        messageAr: 'أكد قبل البدء من جديد.',
      );
    }
    return BrainCheckValidationResult.ok;
  }
}
