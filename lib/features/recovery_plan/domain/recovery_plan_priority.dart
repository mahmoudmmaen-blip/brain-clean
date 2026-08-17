/// Ordered priority-support domain (lowest scores first).
class RecoveryPlanDomainPriority {
  const RecoveryPlanDomainPriority({
    required this.domainId,
    required this.titleEn,
    required this.titleAr,
    required this.displayScore,
    required this.rank,
  });

  final String domainId;
  final String titleEn;
  final String titleAr;
  final int displayScore;
  final int rank;

  String titleForLocale(String languageCode) =>
      languageCode == 'ar' ? titleAr : titleEn;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'domainId': domainId,
        'titleEn': titleEn,
        'titleAr': titleAr,
        'displayScore': displayScore,
        'rank': rank,
      };

  factory RecoveryPlanDomainPriority.fromJson(Map<String, dynamic> json) {
    return RecoveryPlanDomainPriority(
      domainId: json['domainId'] as String,
      titleEn: json['titleEn'] as String? ?? '',
      titleAr: json['titleAr'] as String? ?? '',
      displayScore: (json['displayScore'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Priority selection result (≤2 priorities, ≤1 stronger).
class RecoveryPlanPriority {
  const RecoveryPlanPriority({
    required this.priorities,
    this.strongerDomainId,
    this.strongerTitleEn,
    this.strongerTitleAr,
  });

  final List<RecoveryPlanDomainPriority> priorities;
  final String? strongerDomainId;
  final String? strongerTitleEn;
  final String? strongerTitleAr;

  String? get primaryDomainId =>
      priorities.isEmpty ? null : priorities.first.domainId;

  String strongerTitleForLocale(String languageCode) {
    if (languageCode == 'ar') {
      return strongerTitleAr ?? '';
    }
    return strongerTitleEn ?? '';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'priorities':
            priorities.map((p) => p.toJson()).toList(growable: false),
        if (strongerDomainId != null) 'strongerDomainId': strongerDomainId,
        if (strongerTitleEn != null) 'strongerTitleEn': strongerTitleEn,
        if (strongerTitleAr != null) 'strongerTitleAr': strongerTitleAr,
      };

  factory RecoveryPlanPriority.fromJson(Map<String, dynamic> json) {
    final list = <RecoveryPlanDomainPriority>[];
    final raw = json['priorities'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          list.add(
            RecoveryPlanDomainPriority.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }
    return RecoveryPlanPriority(
      priorities: List<RecoveryPlanDomainPriority>.unmodifiable(list),
      strongerDomainId: json['strongerDomainId'] as String?,
      strongerTitleEn: json['strongerTitleEn'] as String?,
      strongerTitleAr: json['strongerTitleAr'] as String?,
    );
  }
}
