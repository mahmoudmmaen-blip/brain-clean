/// Approved suggested destinations only (Contract §9.4 / §16).
enum SafaSuggestedDestination {
  origin,
  today,
  plan,
  progress,
  sessionPrepare,
  urgentHelp,
  profile,
}

extension SafaSuggestedDestinationX on SafaSuggestedDestination {
  String get wireId => switch (this) {
        SafaSuggestedDestination.origin => 'origin',
        SafaSuggestedDestination.today => 'today',
        SafaSuggestedDestination.plan => 'plan',
        SafaSuggestedDestination.progress => 'progress',
        SafaSuggestedDestination.sessionPrepare => 'session_prepare',
        SafaSuggestedDestination.urgentHelp => 'urgent_help',
        SafaSuggestedDestination.profile => 'profile',
      };

  static SafaSuggestedDestination? tryParse(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'origin':
        return SafaSuggestedDestination.origin;
      case 'today':
      case 'home':
        return SafaSuggestedDestination.today;
      case 'plan':
        return SafaSuggestedDestination.plan;
      case 'progress':
        return SafaSuggestedDestination.progress;
      case 'session_prepare':
      case 'session':
        return SafaSuggestedDestination.sessionPrepare;
      case 'urgent_help':
      case 'sos':
        return SafaSuggestedDestination.urgentHelp;
      case 'profile':
        return SafaSuggestedDestination.profile;
      default:
        return null;
    }
  }

  /// Resolve navigation path — never purchase / reports mutation / external URL.
  String resolvePath({required String originReturnPath}) {
    return switch (this) {
      SafaSuggestedDestination.origin => originReturnPath,
      SafaSuggestedDestination.today => '/v2/home',
      SafaSuggestedDestination.plan => '/v2/plan',
      SafaSuggestedDestination.progress => '/v2/progress',
      SafaSuggestedDestination.sessionPrepare => '/v2/session/prepare',
      // Urgent help stays inside SAF-01 safety subsurface (no SOS screen ID).
      SafaSuggestedDestination.urgentHelp => '/v2/safa?view=urgent',
      SafaSuggestedDestination.profile => '/v2/profile',
    };
  }
}
