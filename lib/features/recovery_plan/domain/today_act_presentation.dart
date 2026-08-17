import 'recovery_plan.dart';

/// Resolves a calm human-readable TodayAct title from plan steps.
///
/// TodayAct has no title field; use the first minimum-path (else required) step.
String? resolveTodayActTitle(RecoveryPlan plan, String languageCode) {
  final today = plan.dayTemplate.todayPreview;
  final ids = today.minimumPathStepIds.isNotEmpty
      ? today.minimumPathStepIds
      : today.requiredStepIds;
  if (ids.isEmpty) return null;
  final byId = {for (final s in plan.steps) s.stepId: s};
  return byId[ids.first]?.nameForLocale(languageCode);
}

/// Minimum-path step labels for preview surfaces.
List<String> resolveTodayMinimumPathLabels(
  RecoveryPlan plan,
  String languageCode,
) {
  final today = plan.dayTemplate.todayPreview;
  final byId = {for (final s in plan.steps) s.stepId: s};
  final labels = <String>[];
  for (final id in today.minimumPathStepIds) {
    final step = byId[id];
    if (step != null) {
      labels.add(step.nameForLocale(languageCode));
    }
  }
  return labels;
}
