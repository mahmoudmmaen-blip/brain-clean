/// Recovery Score communication bands (contract §11) + legacy/unavailable.
enum RecoveryScoreBand {
  /// Calculation not valid — never treat as numeric 0.
  unavailable,

  /// Historical Slice 3 pending packs only.
  pendingApproval,

  gatheringFooting,
  buildingRhythm,
  findingSteadiness,
  growingFoundation,
}

extension RecoveryScoreBandX on RecoveryScoreBand {
  String get wireName => switch (this) {
        RecoveryScoreBand.unavailable => 'unavailable',
        RecoveryScoreBand.pendingApproval => 'pendingApproval',
        RecoveryScoreBand.gatheringFooting => 'gathering_footing',
        RecoveryScoreBand.buildingRhythm => 'building_rhythm',
        RecoveryScoreBand.findingSteadiness => 'finding_steadiness',
        RecoveryScoreBand.growingFoundation => 'growing_foundation',
      };

  String get labelEn => switch (this) {
        RecoveryScoreBand.unavailable => 'Unavailable',
        RecoveryScoreBand.pendingApproval => 'Estimate pending',
        RecoveryScoreBand.gatheringFooting => 'Gathering footing',
        RecoveryScoreBand.buildingRhythm => 'Building rhythm',
        RecoveryScoreBand.findingSteadiness => 'Finding steadiness',
        RecoveryScoreBand.growingFoundation => 'Growing foundation',
      };

  String get labelAr => switch (this) {
        RecoveryScoreBand.unavailable => 'غير متاح',
        RecoveryScoreBand.pendingApproval => 'التقدير قيد الانتظار',
        RecoveryScoreBand.gatheringFooting => 'جمع القوة للبداية',
        RecoveryScoreBand.buildingRhythm => 'بناء الإيقاع',
        RecoveryScoreBand.findingSteadiness => 'إيجاد الثبات',
        RecoveryScoreBand.growingFoundation => 'تنمية الأساس',
      };

  static RecoveryScoreBand fromWire(String? raw) {
    switch (raw) {
      case 'gathering_footing':
        return RecoveryScoreBand.gatheringFooting;
      case 'building_rhythm':
        return RecoveryScoreBand.buildingRhythm;
      case 'finding_steadiness':
        return RecoveryScoreBand.findingSteadiness;
      case 'growing_foundation':
        return RecoveryScoreBand.growingFoundation;
      case 'unavailable':
        return RecoveryScoreBand.unavailable;
      case 'pendingApproval':
      default:
        return RecoveryScoreBand.pendingApproval;
    }
  }
}

/// Overall Recovery Score estimate (`recovery_score_v1`).
class RecoveryScore {
  const RecoveryScore({
    required this.modelVersion,
    required this.band,
    this.value,
    this.valueInternal,
    this.weightSetVersion,
  });

  /// Display integer 0–100 when valid; null when unavailable/pending.
  final int? value;

  /// Internal precision (not shown to users).
  final double? valueInternal;
  final RecoveryScoreBand band;
  final String modelVersion;
  final String? weightSetVersion;

  bool get isPending =>
      value == null && band == RecoveryScoreBand.pendingApproval;

  bool get isUnavailable =>
      value == null && band == RecoveryScoreBand.unavailable;

  bool get isValid => value != null && !isPending && !isUnavailable;

  static const pending = RecoveryScore(
    modelVersion: 'recovery_score_pending_v0',
    band: RecoveryScoreBand.pendingApproval,
  );

  static const unavailable = RecoveryScore(
    modelVersion: 'recovery_score_v1',
    band: RecoveryScoreBand.unavailable,
    weightSetVersion: 'weight_set_equal_v1',
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'modelVersion': modelVersion,
        'band': band.wireName,
        if (value != null) 'value': value,
        if (valueInternal != null) 'valueInternal': valueInternal,
        if (weightSetVersion != null) 'weightSetVersion': weightSetVersion,
      };

  factory RecoveryScore.fromJson(Map<String, dynamic> json) {
    final rawValue = json['value'];
    int? value;
    if (rawValue is int) {
      value = rawValue;
    } else if (rawValue is num) {
      value = rawValue.round();
    }
    return RecoveryScore(
      modelVersion:
          json['modelVersion'] as String? ?? 'recovery_score_pending_v0',
      band: RecoveryScoreBandX.fromWire(json['band'] as String?),
      value: value,
      valueInternal: (json['valueInternal'] as num?)?.toDouble(),
      weightSetVersion: json['weightSetVersion'] as String?,
    );
  }
}
