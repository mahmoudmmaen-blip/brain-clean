import 'brain_check_mode.dart';

/// Durable measurement payload produced when a Brain Check completes.
///
/// Feeds CHK-03 / ProfilePack later. No diagnostic labels.
class MeasurementEvent {
  const MeasurementEvent({
    required this.id,
    required this.mode,
    required this.capturedAt,
    required this.answers,
    required this.sectionIds,
    this.source,
    this.languageCode,
  });

  final String id;
  final BrainCheckMode mode;
  final DateTime capturedAt;
  final Map<String, int> answers;
  final List<String> sectionIds;
  final String? source;
  final String? languageCode;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'mode': mode.wireName,
        'capturedAt': capturedAt.toUtc().toIso8601String(),
        'answers': answers,
        'sectionIds': sectionIds,
        if (source != null) 'source': source,
        if (languageCode != null) 'languageCode': languageCode,
      };

  factory MeasurementEvent.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    final answers = <String, int>{};
    if (rawAnswers is Map) {
      rawAnswers.forEach((key, value) {
        if (value is num) answers[key.toString()] = value.toInt();
      });
    }

    final rawSections = json['sectionIds'];
    final sectionIds = <String>[];
    if (rawSections is List) {
      for (final item in rawSections) {
        sectionIds.add(item.toString());
      }
    }

    return MeasurementEvent(
      id: json['id'] as String,
      mode: BrainCheckModeX.fromWire(json['mode'] as String?),
      capturedAt: DateTime.parse(json['capturedAt'] as String).toUtc(),
      answers: Map<String, int>.unmodifiable(answers),
      sectionIds: List<String>.unmodifiable(sectionIds),
      source: json['source'] as String?,
      languageCode: json['languageCode'] as String?,
    );
  }
}
