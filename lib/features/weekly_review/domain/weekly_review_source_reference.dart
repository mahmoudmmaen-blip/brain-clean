/// Reference stamps for sources — never mutate Plan / Score / Profile.
class WeeklyReviewSourceReference {
  const WeeklyReviewSourceReference({
    required this.progressSnapshotId,
    required this.planId,
    required this.profilePackId,
    required this.recoveryScoreReference,
  });

  final String progressSnapshotId;
  final String planId;
  final String profilePackId;

  /// Model/version stamp only (e.g. recovery_score_v1).
  final String recoveryScoreReference;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'progressSnapshotId': progressSnapshotId,
        'planId': planId,
        'profilePackId': profilePackId,
        'recoveryScoreReference': recoveryScoreReference,
      };

  factory WeeklyReviewSourceReference.fromJson(Map<String, dynamic> json) {
    return WeeklyReviewSourceReference(
      progressSnapshotId: json['progressSnapshotId'] as String,
      planId: json['planId'] as String,
      profilePackId: json['profilePackId'] as String,
      recoveryScoreReference: json['recoveryScoreReference'] as String? ?? '',
    );
  }
}
