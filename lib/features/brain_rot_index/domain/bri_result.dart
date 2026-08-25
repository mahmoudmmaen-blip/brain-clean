import 'bri_axis.dart';

/// Persisted BRI outcome — higher [overallScore] = more brain rot.
class BriResult {
  const BriResult({
    required this.overallScore,
    required this.axisScores,
    required this.completedAt,
    this.version = BriResult.currentVersion,
  });

  static const currentVersion = 'bri_free_v1';

  final int overallScore;
  final Map<BriAxis, int> axisScores;
  final DateTime completedAt;
  final String version;

  BriBand get band => briBandFor(overallScore);

  /// Clarity for daily-program blend (higher = healthier).
  int get clarityScore => (100 - overallScore).clamp(0, 100);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': version,
        'overallScore': overallScore,
        'axisScores': {
          for (final e in axisScores.entries) e.key.name: e.value,
        },
        'completedAt': completedAt.toUtc().toIso8601String(),
      };

  factory BriResult.fromJson(Map<String, dynamic> json) {
    final rawAxes = json['axisScores'];
    final axes = <BriAxis, int>{};
    if (rawAxes is Map) {
      for (final axis in BriAxis.values) {
        final v = rawAxes[axis.name];
        if (v is num) axes[axis] = v.round().clamp(0, 100);
      }
    }
    for (final axis in BriAxis.values) {
      axes.putIfAbsent(axis, () => 50);
    }
    return BriResult(
      overallScore: (json['overallScore'] as num?)?.round().clamp(0, 100) ?? 50,
      axisScores: axes,
      completedAt: DateTime.parse(json['completedAt'] as String).toUtc(),
      version: json['version'] as String? ?? BriResult.currentVersion,
    );
  }
}
