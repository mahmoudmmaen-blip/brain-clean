import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_challenge.freezed.dart';
part 'daily_challenge.g.dart';

@freezed
class DailyChallenge with _$DailyChallenge {
  const factory DailyChallenge({
    required DateTime date,
    required String gameKey,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
  }) = _DailyChallenge;

  factory DailyChallenge.fromJson(Map<String, dynamic> json) =>
      _$DailyChallengeFromJson(json);
}
