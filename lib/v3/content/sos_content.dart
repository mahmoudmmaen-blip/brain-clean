import 'localized_text.dart';

class SosFlowStep {
  const SosFlowStep({
    required this.type,
    this.text,
    this.seconds,
    this.key,
    this.pattern,
    this.duration,
  });

  final String type;
  final LocalizedText? text;
  final int? seconds;
  final String? key;

  /// Either a list of ints `[inhale, hold, exhale, hold]` or `"double_sigh"`.
  final Object? pattern;
  final String? duration;

  factory SosFlowStep.fromJson(Map<String, dynamic> json, {String path = ''}) {
    Object? pattern = json['pattern'];
    if (pattern is List) {
      pattern = pattern.map((e) => (e as num).toInt()).toList(growable: false);
    }
    return SosFlowStep(
      type: json['type'] as String,
      text: json['text'] == null
          ? null
          : LocalizedText.fromJson(json['text'], path: '$path.text'),
      seconds: (json['seconds'] as num?)?.toInt(),
      key: json['key'] as String?,
      pattern: pattern,
      duration: json['duration']?.toString(),
    );
  }
}

class SosFlow {
  const SosFlow({
    required this.id,
    required this.icon,
    required this.label,
    required this.steps,
    this.safety,
  });

  final String id;
  final String icon;
  final LocalizedText label;
  final List<SosFlowStep> steps;
  final LocalizedText? safety;

  factory SosFlow.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final steps = (json['steps'] as List? ?? const [])
        .asMap()
        .entries
        .map(
          (e) => SosFlowStep.fromJson(
            Map<String, dynamic>.from(e.value as Map),
            path: 'flows[$id].steps[${e.key}]',
          ),
        )
        .toList(growable: false);
    return SosFlow(
      id: id,
      icon: json['icon'] as String? ?? '',
      label: LocalizedText.fromJson(json['label'], path: 'flows[$id].label'),
      steps: steps,
      safety: json['safety'] == null
          ? null
          : LocalizedText.fromJson(json['safety'], path: 'flows[$id].safety'),
    );
  }
}

class SosContent {
  const SosContent({
    required this.version,
    required this.title,
    required this.subtitle,
    required this.tier,
    required this.note,
    required this.flows,
  });

  final int version;
  final LocalizedText title;
  final LocalizedText subtitle;
  final String tier;
  final String note;
  final List<SosFlow> flows;

  factory SosContent.fromJson(Map<String, dynamic> json) {
    final flows = (json['flows'] as List? ?? const [])
        .map((e) => SosFlow.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
    return SosContent(
      version: (json['version'] as num?)?.toInt() ?? 1,
      title: LocalizedText.fromJson(json['title'], path: 'sos.title'),
      subtitle: LocalizedText.fromJson(json['subtitle'], path: 'sos.subtitle'),
      tier: json['tier'] as String? ?? 'free',
      note: json['note'] as String? ?? '',
      flows: flows,
    );
  }
}
