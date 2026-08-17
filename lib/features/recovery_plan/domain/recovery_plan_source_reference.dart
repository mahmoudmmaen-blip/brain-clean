/// Source ProfilePack + Brain Check session linkage.
class RecoveryPlanSourceReference {
  const RecoveryPlanSourceReference({
    required this.profilePackId,
    required this.brainCheckSessionId,
    required this.scoreModelVersion,
    required this.profileSchemaVersion,
  });

  final String profilePackId;
  final String brainCheckSessionId;
  final String scoreModelVersion;
  final String profileSchemaVersion;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'profilePackId': profilePackId,
        'brainCheckSessionId': brainCheckSessionId,
        'scoreModelVersion': scoreModelVersion,
        'profileSchemaVersion': profileSchemaVersion,
      };

  factory RecoveryPlanSourceReference.fromJson(Map<String, dynamic> json) {
    return RecoveryPlanSourceReference(
      profilePackId: json['profilePackId'] as String? ?? '',
      brainCheckSessionId: json['brainCheckSessionId'] as String? ?? '',
      scoreModelVersion: json['scoreModelVersion'] as String? ?? '',
      profileSchemaVersion: json['profileSchemaVersion'] as String? ?? '',
    );
  }
}
