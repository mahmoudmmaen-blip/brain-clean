/// One persisted answer for a Brain Check item.
class BrainCheckAnswer {
  const BrainCheckAnswer({
    required this.questionId,
    required this.value,
    required this.answeredAt,
  });

  final String questionId;
  final int value;
  final DateTime answeredAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'questionId': questionId,
        'value': value,
        'answeredAt': answeredAt.toUtc().toIso8601String(),
      };

  factory BrainCheckAnswer.fromJson(Map<String, dynamic> json) {
    return BrainCheckAnswer(
      questionId: json['questionId'] as String,
      value: (json['value'] as num).toInt(),
      answeredAt: DateTime.parse(json['answeredAt'] as String).toUtc(),
    );
  }
}
