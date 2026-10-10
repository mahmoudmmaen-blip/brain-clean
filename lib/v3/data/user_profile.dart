class UserProfile {
  const UserProfile({
    this.name,
    required this.goal,
    required this.reminderTime,
    required this.eveningCheckIn,
    required this.onboardingDone,
    required this.createdAt,
    required this.locale,
  });

  final String? name;
  final String goal;
  /// Local time as `HH:mm` (24h).
  final String reminderTime;
  final bool eveningCheckIn;
  final bool onboardingDone;
  final DateTime createdAt;
  /// BCP-47 language code, e.g. `ar` or `en`.
  final String locale;

  UserProfile copyWith({
    String? name,
    String? goal,
    String? reminderTime,
    bool? eveningCheckIn,
    bool? onboardingDone,
    DateTime? createdAt,
    String? locale,
  }) {
    return UserProfile(
      name: name ?? this.name,
      goal: goal ?? this.goal,
      reminderTime: reminderTime ?? this.reminderTime,
      eveningCheckIn: eveningCheckIn ?? this.eveningCheckIn,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      createdAt: createdAt ?? this.createdAt,
      locale: locale ?? this.locale,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'goal': goal,
        'reminderTime': reminderTime,
        'eveningCheckIn': eveningCheckIn,
        'onboardingDone': onboardingDone,
        'createdAt': createdAt.toIso8601String(),
        'locale': locale,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String?,
      goal: json['goal'] as String? ?? '',
      reminderTime: json['reminderTime'] as String? ?? '20:00',
      eveningCheckIn: json['eveningCheckIn'] as bool? ?? true,
      onboardingDone: json['onboardingDone'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      locale: json['locale'] as String? ?? 'ar',
    );
  }
}
