import 'localized_text.dart';

class ClarityScaleOption {
  const ClarityScaleOption({required this.value, required this.label});

  final int value;
  final LocalizedText label;

  factory ClarityScaleOption.fromJson(Map<String, dynamic> json) {
    return ClarityScaleOption(
      value: (json['value'] as num).toInt(),
      label: LocalizedText.fromJson(json['label'], path: 'scale.label'),
    );
  }
}

class ClarityScreenTimeOption {
  const ClarityScreenTimeOption({required this.value, required this.label});

  final double value;
  final LocalizedText label;

  factory ClarityScreenTimeOption.fromJson(Map<String, dynamic> json) {
    return ClarityScreenTimeOption(
      value: (json['value'] as num).toDouble(),
      label: LocalizedText.fromJson(
        json['label'],
        path: 'screenTimeQuestion.options.label',
      ),
    );
  }
}

class ClarityScreenTimeQuestion {
  const ClarityScreenTimeQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.scored,
  });

  final String id;
  final LocalizedText text;
  final List<ClarityScreenTimeOption> options;
  final bool scored;

  factory ClarityScreenTimeQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List? ?? const [])
        .map(
          (e) => ClarityScreenTimeOption.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList(growable: false);
    return ClarityScreenTimeQuestion(
      id: json['id'] as String,
      text: LocalizedText.fromJson(
        json['text'],
        path: 'screenTimeQuestion.text',
      ),
      options: options,
      scored: json['scored'] as bool? ?? false,
    );
  }
}

class ClarityQuestion {
  const ClarityQuestion({
    required this.id,
    required this.area,
    required this.reverse,
    required this.text,
  });

  final String id;
  final String area;
  final bool reverse;
  final LocalizedText text;

  factory ClarityQuestion.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return ClarityQuestion(
      id: id,
      area: json['area'] as String,
      reverse: json['reverse'] as bool? ?? false,
      text: LocalizedText.fromJson(json['text'], path: 'questions[$id].text'),
    );
  }
}

class ClarityBand {
  const ClarityBand({
    required this.min,
    required this.max,
    required this.label,
    required this.text,
  });

  final int min;
  final int max;
  final LocalizedText label;
  final LocalizedText text;

  factory ClarityBand.fromJson(Map<String, dynamic> json) {
    return ClarityBand(
      min: (json['min'] as num).toInt(),
      max: (json['max'] as num).toInt(),
      label: LocalizedText.fromJson(json['label'], path: 'bands.label'),
      text: LocalizedText.fromJson(json['text'], path: 'bands.text'),
    );
  }
}

class ClarityScoringSpec {
  const ClarityScoringSpec({
    required this.formula,
    required this.areas,
    required this.areaFormula,
    required this.bands,
  });

  final String formula;
  final Map<String, LocalizedText> areas;
  final String areaFormula;
  final List<ClarityBand> bands;

  factory ClarityScoringSpec.fromJson(Map<String, dynamic> json) {
    final areasRaw = Map<String, dynamic>.from(json['areas'] as Map? ?? {});
    final areas = <String, LocalizedText>{};
    for (final entry in areasRaw.entries) {
      areas[entry.key] = LocalizedText.fromJson(
        entry.value,
        path: 'scoring.areas.${entry.key}',
      );
    }
    final bands = (json['bands'] as List? ?? const [])
        .map((e) => ClarityBand.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
    return ClarityScoringSpec(
      formula: json['formula'] as String? ?? '',
      areas: areas,
      areaFormula: json['areaFormula'] as String? ?? '',
      bands: bands,
    );
  }
}

class ClarityCheckContent {
  const ClarityCheckContent({
    required this.version,
    required this.name,
    required this.intro,
    required this.screenTimeQuestion,
    required this.scale,
    required this.questions,
    required this.scoring,
    required this.schedule,
    required this.afterProgram,
  });

  final int version;
  final LocalizedText name;
  final LocalizedText intro;
  final ClarityScreenTimeQuestion screenTimeQuestion;
  final List<ClarityScaleOption> scale;
  final List<ClarityQuestion> questions;
  final ClarityScoringSpec scoring;
  final List<int> schedule;
  final String afterProgram;

  factory ClarityCheckContent.fromJson(Map<String, dynamic> json) {
    final scale = (json['scale'] as List? ?? const [])
        .map(
          (e) =>
              ClarityScaleOption.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false);
    final questions = (json['questions'] as List? ?? const [])
        .map(
          (e) => ClarityQuestion.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false);
    return ClarityCheckContent(
      version: (json['version'] as num?)?.toInt() ?? 1,
      name: LocalizedText.fromJson(json['name'], path: 'clarity.name'),
      intro: LocalizedText.fromJson(json['intro'], path: 'clarity.intro'),
      screenTimeQuestion: ClarityScreenTimeQuestion.fromJson(
        Map<String, dynamic>.from(json['screenTimeQuestion'] as Map),
      ),
      scale: scale,
      questions: questions,
      scoring: ClarityScoringSpec.fromJson(
        Map<String, dynamic>.from(json['scoring'] as Map),
      ),
      schedule: (json['schedule'] as List? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(growable: false),
      afterProgram: json['afterProgram'] as String? ?? '',
    );
  }
}
