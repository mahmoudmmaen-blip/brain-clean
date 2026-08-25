import 'bri_axis.dart';

/// One BRI Likert item (answer 1–5).
class BriQuestion {
  const BriQuestion({
    required this.id,
    required this.stemKey,
    required this.axis,
    required this.order,
    this.higherMeansWorse = true,
  });

  final String id;
  final String stemKey;
  final BriAxis axis;
  final int order;

  /// When true, higher Likert = more rot. When false, reverse-scored.
  final bool higherMeansWorse;
}
