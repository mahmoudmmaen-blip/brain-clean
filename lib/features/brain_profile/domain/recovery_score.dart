/// Recovery Score band map.
///
/// Build Spec does not approve band thresholds. Only [pendingApproval] exists
/// until mathematics docs are present.
enum RecoveryScoreBand {
  pendingApproval,
}

extension RecoveryScoreBandX on RecoveryScoreBand {
  String get wireName => name;

  static RecoveryScoreBand fromWire(String? raw) {
    return RecoveryScoreBand.pendingApproval;
  }
}

/// Overall Recovery Score estimate.
///
/// [value] stays null while [modelVersion] is pending — never invent weights.
class RecoveryScore {
  const RecoveryScore({
    required this.modelVersion,
    required this.band,
    this.value,
  });

  /// Null until an approved calculation model is wired.
  final double? value;
  final RecoveryScoreBand band;
  final String modelVersion;

  bool get isPending => value == null;

  static const pending = RecoveryScore(
    modelVersion: 'recovery_score_pending_v0',
    band: RecoveryScoreBand.pendingApproval,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'modelVersion': modelVersion,
        'band': band.wireName,
        if (value != null) 'value': value,
      };

  factory RecoveryScore.fromJson(Map<String, dynamic> json) {
    return RecoveryScore(
      modelVersion: json['modelVersion'] as String? ?? 'recovery_score_pending_v0',
      band: RecoveryScoreBandX.fromWire(json['band'] as String?),
      value: (json['value'] as num?)?.toDouble(),
    );
  }
}
