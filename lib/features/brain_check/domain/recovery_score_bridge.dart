import 'measurement_event.dart';
import '../../brain_profile/domain/recovery_score_engine.dart';
import '../../brain_profile/domain/score_calculation_result.dart';

/// Placeholder Recovery Score until / when ProfilePack is built.
class RecoveryScorePlaceholder {
  const RecoveryScorePlaceholder({
    this.recoveryScore,
    this.status = pendingStatus,
  });

  static const pendingStatus = 'pending_recovery_score';
  static const v1Status = 'recovery_score_v1';
  static const unavailableStatus = 'recovery_score_unavailable';

  /// Null until Recovery Score is wired or when unavailable.
  final double? recoveryScore;
  final String status;

  bool get isPending =>
      recoveryScore == null && status == pendingStatus;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'status': status,
        if (recoveryScore != null) 'recoveryScore': recoveryScore,
      };

  factory RecoveryScorePlaceholder.fromJson(Map<String, dynamic> json) {
    return RecoveryScorePlaceholder(
      recoveryScore: (json['recoveryScore'] as num?)?.toDouble(),
      status: json['status'] as String? ?? pendingStatus,
    );
  }

  static const pending = RecoveryScorePlaceholder();
}

/// Extension point for Recovery Score mathematics.
abstract class RecoveryScoreBridge {
  RecoveryScorePlaceholder compute(MeasurementEvent event);
}

/// Deterministic V1 bridge — pure local [RecoveryScoreEngine].
class V1RecoveryScoreBridge implements RecoveryScoreBridge {
  const V1RecoveryScoreBridge();

  @override
  RecoveryScorePlaceholder compute(MeasurementEvent event) {
    final result = RecoveryScoreEngine.compute(event);
    return switch (result) {
      ScoreCalculationValid(:final recoveryScore) => RecoveryScorePlaceholder(
          recoveryScore: recoveryScore.value?.toDouble(),
          status: RecoveryScorePlaceholder.v1Status,
        ),
      ScoreCalculationUnavailable() => const RecoveryScorePlaceholder(
          status: RecoveryScorePlaceholder.unavailableStatus,
        ),
    };
  }
}

/// Legacy no-op placeholder retained for tests that assert pending behavior.
class PendingRecoveryScoreBridge implements RecoveryScoreBridge {
  const PendingRecoveryScoreBridge();

  @override
  RecoveryScorePlaceholder compute(MeasurementEvent event) {
    return RecoveryScorePlaceholder.pending;
  }
}
