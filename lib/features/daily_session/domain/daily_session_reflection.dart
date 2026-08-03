/// Structured SES-03 reflection — chips only (no free text in Slice 6).
class DailySessionReflection {
  const DailySessionReflection({
    required this.promptId,
    this.manageableChip,
    this.helpedPauseChip,
    this.obstacleChip,
    this.skippedChips = false,
  });

  static const promptIdV1 = 'reflect_session_feel_v1';

  final String promptId;

  /// manageable | ok | hard
  final String? manageableChip;

  /// yes | somewhat | not_yet
  final String? helpedPauseChip;

  /// none | distraction | low_energy | time | other
  final String? obstacleChip;

  final bool skippedChips;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'promptId': promptId,
        if (manageableChip != null) 'manageableChip': manageableChip,
        if (helpedPauseChip != null) 'helpedPauseChip': helpedPauseChip,
        if (obstacleChip != null) 'obstacleChip': obstacleChip,
        'skippedChips': skippedChips,
      };

  factory DailySessionReflection.fromJson(Map<String, dynamic> json) {
    return DailySessionReflection(
      promptId: json['promptId'] as String? ?? promptIdV1,
      manageableChip: json['manageableChip'] as String?,
      helpedPauseChip: json['helpedPauseChip'] as String?,
      obstacleChip: json['obstacleChip'] as String?,
      skippedChips: json['skippedChips'] as bool? ?? false,
    );
  }
}
