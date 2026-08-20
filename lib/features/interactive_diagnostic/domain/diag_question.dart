import 'diag_metric.dart';

class DiagQuestion {
  const DiagQuestion({
    required this.id,
    required this.metric,
    required this.stemKey,
    required this.order,
  });

  final String id;
  final DiagMetric metric;
  final String stemKey;
  final int order;
}
