/// Links a DailySession to Plan / Profile / TodayAct identities.
class DailySessionSourceReference {
  const DailySessionSourceReference({
    required this.planId,
    required this.todayActId,
    required this.profilePackId,
    required this.planEngineVersion,
    required this.practiceCatalogVersion,
    required this.todayActVersion,
  });

  final String planId;
  final String todayActId;
  final String profilePackId;
  final String planEngineVersion;
  final String practiceCatalogVersion;
  final String todayActVersion;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'planId': planId,
        'todayActId': todayActId,
        'profilePackId': profilePackId,
        'planEngineVersion': planEngineVersion,
        'practiceCatalogVersion': practiceCatalogVersion,
        'todayActVersion': todayActVersion,
      };

  factory DailySessionSourceReference.fromJson(Map<String, dynamic> json) {
    return DailySessionSourceReference(
      planId: json['planId'] as String? ?? '',
      todayActId: json['todayActId'] as String? ?? '',
      profilePackId: json['profilePackId'] as String? ?? '',
      planEngineVersion: json['planEngineVersion'] as String? ?? '',
      practiceCatalogVersion: json['practiceCatalogVersion'] as String? ?? '',
      todayActVersion: json['todayActVersion'] as String? ?? '',
    );
  }
}
