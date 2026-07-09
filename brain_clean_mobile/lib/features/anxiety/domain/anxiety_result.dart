import 'package:freezed_annotation/freezed_annotation.dart';

import 'anxiety_level.dart';

part 'anxiety_result.freezed.dart';
part 'anxiety_result.g.dart';

@freezed
class AnxietyResult with _$AnxietyResult {
  const factory AnxietyResult({
    required List<int> answers,
    required double score,
    required AnxietyLevel level,
    required DateTime timestamp,
  }) = _AnxietyResult;

  factory AnxietyResult.fromJson(Map<String, dynamic> json) =>
      _$AnxietyResultFromJson(json);
}
