/// Bilingual (or multi-locale) string from content JSON: `{"ar": "...", "en": "..."}`.
class LocalizedText {
  const LocalizedText(this.values);

  final Map<String, String> values;

  factory LocalizedText.fromJson(Object? json, {String path = ''}) {
    if (json is! Map) {
      throw FormatException('Expected localized text object at $path');
    }
    final map = Map<String, dynamic>.from(json);
    final out = <String, String>{};
    for (final entry in map.entries) {
      final v = entry.value;
      if (v is! String) {
        throw FormatException(
          'Expected string locales at $path (got ${v.runtimeType} for ${entry.key})',
        );
      }
      out[entry.key] = v;
    }
    if (!out.containsKey('ar') || !out.containsKey('en')) {
      throw FormatException('Localized text at $path must include ar and en');
    }
    return LocalizedText(out);
  }

  /// Resolves for [languageCode], falling back to `en`, then any value.
  String resolve(String languageCode) {
    final code = languageCode.toLowerCase();
    return values[code] ?? values['en'] ?? values.values.first;
  }

  bool get hasArAndEn =>
      values.containsKey('ar') && values.containsKey('en');
}

/// Bilingual list from content JSON: `{"ar": [...], "en": [...]}`.
class LocalizedStringList {
  const LocalizedStringList(this.values);

  final Map<String, List<String>> values;

  factory LocalizedStringList.fromJson(Object? json, {String path = ''}) {
    if (json is! Map) {
      throw FormatException('Expected localized list object at $path');
    }
    final map = Map<String, dynamic>.from(json);
    final out = <String, List<String>>{};
    for (final entry in map.entries) {
      final raw = entry.value;
      if (raw is! List) {
        throw FormatException(
          'Expected list locales at $path (got ${raw.runtimeType} for ${entry.key})',
        );
      }
      out[entry.key] = raw.map((e) => e.toString()).toList(growable: false);
    }
    if (!out.containsKey('ar') || !out.containsKey('en')) {
      throw FormatException('Localized list at $path must include ar and en');
    }
    return LocalizedStringList(out);
  }

  List<String> resolve(String languageCode) {
    final code = languageCode.toLowerCase();
    return values[code] ?? values['en'] ?? values.values.first;
  }

  bool get lengthsMatch {
    final ar = values['ar'];
    final en = values['en'];
    if (ar == null || en == null) return false;
    return ar.length == en.length;
  }
}
