import 'measurement_event.dart';

/// Placeholder Recovery Score until the Recovery Score engine connects.
class RecoveryScorePlaceholder {
  const RecoveryScorePlaceholder({
    this.recoveryScore,
    this.status = pendingStatus,
  });

  static const pendingStatus = 'pending_recovery_score';

  /// Null until Recovery Score is wired.
  final double? recoveryScore;
  final String status;

  bool get isPending => recoveryScore == null;

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

/// Extension point for future Recovery Score mathematics.
///
/// Slice 2 keeps the default implementation as a no-op placeholder.
abstract class RecoveryScoreBridge {
  RecoveryScorePlaceholder compute(MeasurementEvent event);
}

/// Approved placeholder — does not invent scoring math.
class PendingRecoveryScoreBridge implements RecoveryScoreBridge {
  const PendingRecoveryScoreBridge();

  @override
  RecoveryScorePlaceholder compute(MeasurementEvent event) {
    // Intentionally empty: Recovery Score connects in a later slice.
    return RecoveryScorePlaceholder.pending;
  }
}
