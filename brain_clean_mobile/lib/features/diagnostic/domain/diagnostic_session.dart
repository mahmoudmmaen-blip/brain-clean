import 'diagnostic_model.dart';

/// Committed diagnostic snapshot shown on the dashboard.
class DiagnosticSession {
  const DiagnosticSession({
    required this.model,
    required this.committedAt,
    this.brainRot,
  });

  final DiagnosticModel model;
  final DateTime committedAt;
  final BrainRotInterpretation? brainRot;

  double get bcScore => model.calculateBcScore();

  int get bcScoreRounded => bcScore.round();
}
