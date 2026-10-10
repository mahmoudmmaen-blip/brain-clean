enum EveningChallengeAnswer { yes, partly, no }

EveningChallengeAnswer eveningChallengeAnswerFromJson(String raw) {
  switch (raw) {
    case 'yes':
      return EveningChallengeAnswer.yes;
    case 'partly':
      return EveningChallengeAnswer.partly;
    case 'no':
      return EveningChallengeAnswer.no;
    default:
      return EveningChallengeAnswer.no;
  }
}

String eveningChallengeAnswerToJson(EveningChallengeAnswer value) {
  switch (value) {
    case EveningChallengeAnswer.yes:
      return 'yes';
    case EveningChallengeAnswer.partly:
      return 'partly';
    case EveningChallengeAnswer.no:
      return 'no';
  }
}

class EveningCheckIn {
  const EveningCheckIn({
    required this.date,
    required this.mood,
    required this.challenge,
    this.note,
  });

  /// Local calendar date (`yyyy-MM-dd`).
  final String date;
  final int mood;
  final EveningChallengeAnswer challenge;
  final String? note;

  Map<String, dynamic> toJson() => {
        'date': date,
        'mood': mood,
        'challenge': eveningChallengeAnswerToJson(challenge),
        'note': note,
      };

  factory EveningCheckIn.fromJson(Map<String, dynamic> json) {
    return EveningCheckIn(
      date: json['date'] as String,
      mood: (json['mood'] as num).toInt(),
      challenge: eveningChallengeAnswerFromJson(json['challenge'] as String),
      note: json['note'] as String?,
    );
  }
}
