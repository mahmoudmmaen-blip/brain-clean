import 'diagnostic_model.dart';

/// Committed diagnostic snapshot shown on the dashboard.
class DiagnosticSession {
  const DiagnosticSession({
    required this.model,
    required this.committedAt,
  });

  final DiagnosticModel model;
  final DateTime committedAt;

  double get bcScore => model.calculateBcScore();

  int get bcScoreRounded => bcScore.round();
}
