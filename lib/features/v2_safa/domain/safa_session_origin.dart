/// Categorical origin for contextual entry (Contract §5 / §7).
enum SafaSessionOrigin {
  today,
  plan,
  session,
  progress,
  weeklySummary,
  profile,
  support,
  deepLink,
  unknown,
}

extension SafaSessionOriginX on SafaSessionOrigin {
  String get wireId => switch (this) {
        SafaSessionOrigin.today => 'today',
        SafaSessionOrigin.plan => 'plan',
        SafaSessionOrigin.session => 'session',
        SafaSessionOrigin.progress => 'progress',
        SafaSessionOrigin.weeklySummary => 'weekly_summary',
        SafaSessionOrigin.profile => 'profile',
        SafaSessionOrigin.support => 'support',
        SafaSessionOrigin.deepLink => 'deep_link',
        SafaSessionOrigin.unknown => 'unknown',
      };

  /// Default return path for exit / origin destination.
  String get defaultReturnPath => switch (this) {
        SafaSessionOrigin.today => '/v2/home',
        SafaSessionOrigin.plan => '/v2/plan',
        SafaSessionOrigin.session => '/v2/home',
        SafaSessionOrigin.progress => '/v2/progress',
        SafaSessionOrigin.weeklySummary => '/v2/progress',
        SafaSessionOrigin.profile => '/v2/profile',
        SafaSessionOrigin.support => '/v2/home',
        SafaSessionOrigin.deepLink => '/v2/home',
        SafaSessionOrigin.unknown => '/v2/home',
      };

  static SafaSessionOrigin parse(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'today':
      case 'home':
      case 'hom-01':
        return SafaSessionOrigin.today;
      case 'plan':
      case 'pln-01':
        return SafaSessionOrigin.plan;
      case 'session':
      case 'ses':
        return SafaSessionOrigin.session;
      case 'progress':
      case 'prg-01':
        return SafaSessionOrigin.progress;
      case 'weekly_summary':
      case 'weekly':
      case 'wrv':
        return SafaSessionOrigin.weeklySummary;
      case 'profile':
      case 'prf-01':
        return SafaSessionOrigin.profile;
      case 'support':
      case 'difficult_moment':
        return SafaSessionOrigin.support;
      case 'deep_link':
      case 'deeplink':
        return SafaSessionOrigin.deepLink;
      default:
        return SafaSessionOrigin.unknown;
    }
  }

  /// Explicit contextual entry is allowed for these origins.
  bool get allowsExplicitEntry => this != SafaSessionOrigin.unknown;
}
