import 'recovery_plan_step.dart';
import 'today_act.dart';

/// Repeated daily template stored on the plan (not a clinical program).
class RecoveryPlanDayTemplate {
  const RecoveryPlanDayTemplate({
    required this.dayIndexSeed,
    required this.steps,
    required this.todayPreview,
  });

  /// Seed day index (0 at creation).
  final int dayIndexSeed;
  final List<RecoveryPlanStep> steps;
  final TodayAct todayPreview;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'dayIndexSeed': dayIndexSeed,
        'steps': steps.map((s) => s.toJson()).toList(growable: false),
        'todayPreview': todayPreview.toJson(),
      };

  factory RecoveryPlanDayTemplate.fromJson(Map<String, dynamic> json) {
    final steps = <RecoveryPlanStep>[];
    final rawSteps = json['steps'];
    if (rawSteps is List) {
      for (final item in rawSteps) {
        if (item is Map) {
          steps.add(
            RecoveryPlanStep.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return RecoveryPlanDayTemplate(
      dayIndexSeed: (json['dayIndexSeed'] as num?)?.toInt() ?? 0,
      steps: List<RecoveryPlanStep>.unmodifiable(steps),
      todayPreview: TodayAct.fromJson(
        Map<String, dynamic>.from(json['todayPreview'] as Map? ?? const {}),
      ),
    );
  }
}
