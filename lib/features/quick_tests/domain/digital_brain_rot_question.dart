/// Self-report item for digital brain-rot / screen-habit screening.
class DigitalBrainRotQuestion {
  const DigitalBrainRotQuestion({
    required this.id,
    required this.stemKey,
    required this.order,
    this.higherMeansWorse = true,
  });

  final String id;
  final String stemKey;
  final int order;

  /// When true, Likert 5 = more rot (score inverted toward wellness).
  final bool higherMeansWorse;
}
