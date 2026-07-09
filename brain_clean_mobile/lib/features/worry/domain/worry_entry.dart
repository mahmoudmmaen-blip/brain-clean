import 'package:freezed_annotation/freezed_annotation.dart';

part 'worry_entry.freezed.dart';
part 'worry_entry.g.dart';

@freezed
class WorryEntry with _$WorryEntry {
  const factory WorryEntry({
    required String id,
    required String content,
    required DateTime createdAt,
    @Default(0) int sessionMinutes,
  }) = _WorryEntry;

  factory WorryEntry.fromJson(Map<String, dynamic> json) =>
      _$WorryEntryFromJson(json);
}

bool worryEntryIsToday(WorryEntry entry, DateTime now) {
  final local = entry.createdAt.toLocal();
  return local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
}
