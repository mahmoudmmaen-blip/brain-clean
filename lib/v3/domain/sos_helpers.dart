import '../content/sos_content.dart';
import '../data/user_inputs.dart';

/// Resolve replacement suggestions for an SOS duration key (`5` / `15` / `60`).
List<String> resolveSosReplacements({
  required SosContent sos,
  required UserInputs inputs,
  required String duration,
  required String languageCode,
}) {
  final user = inputs.replacements
      .forDuration(duration)
      .where((e) => e.trim().isNotEmpty)
      .toList(growable: false);
  if (user.isNotEmpty) return user;
  final defaults = sos.defaultReplacements[duration];
  if (defaults == null) return const [];
  return defaults.resolve(languageCode);
}

String resolveSosWhy({
  required UserInputs inputs,
  required String defaultWhy,
}) {
  final why = inputs.whyStatement?.trim();
  if (why != null && why.isNotEmpty) return why;
  return defaultWhy;
}
