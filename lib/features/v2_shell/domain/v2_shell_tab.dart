/// Canonical V2 shell tabs — Pro mock five-tab navbar.
enum V2ShellTab {
  today,
  exercises,
  progress,
  pro,
  profile,
}

extension V2ShellTabX on V2ShellTab {
  int get index => V2ShellTab.values.indexOf(this);

  static V2ShellTab? fromIndex(int index) {
    if (index < 0 || index >= V2ShellTab.values.length) return null;
    return V2ShellTab.values[index];
  }

  /// Path prefix that owns this tab.
  String get pathPrefix => switch (this) {
        V2ShellTab.today => '/v2/home',
        V2ShellTab.exercises => '/v2/exercises',
        V2ShellTab.progress => '/v2/progress',
        V2ShellTab.pro => '/v2/pro',
        V2ShellTab.profile => '/v2/profile',
      };

  /// Maps a location to a **primary tab**, or null when the route is contextual.
  static V2ShellTab? fromLocation(String location) {
    final path = Uri.tryParse(location)?.path ?? location;
    if (path == '/v2/home' || path == '/v2/today') return V2ShellTab.today;
    if (path == '/v2/exercises') return V2ShellTab.exercises;
    if (path == '/v2/progress') return V2ShellTab.progress;
    if (path == '/v2/pro') return V2ShellTab.pro;
    if (path == '/v2/profile') return V2ShellTab.profile;
    // Contextual destinations — not primary tabs.
    if (path == '/v2/check' ||
        path.startsWith('/v2/brain-check') ||
        path == '/v2/brain-profile' ||
        path.startsWith('/v2/brain-profile/') ||
        path == '/v2/plan' ||
        path.startsWith('/v2/plan/') ||
        path == '/v2/reports' ||
        path.startsWith('/v2/reports/') ||
        path == '/v2/safa' ||
        path.startsWith('/v2/safa/') ||
        path == '/v2/premium' ||
        path.startsWith('/v2/premium/')) {
      return null;
    }
    return null;
  }
}

/// Paths used by the V2 shell and preserved contextual surfaces.
abstract final class V2ShellPaths {
  static const today = '/v2/home';
  static const home = today; // alias
  static const exercises = '/v2/exercises';
  static const progress = '/v2/progress';
  static const pro = '/v2/pro';
  static const profile = '/v2/profile';

  /// Contextual (not primary tabs).
  static const plan = '/v2/plan';
  static const check = '/v2/check';
  static const reports = '/v2/reports';
  static const premium = '/v2/premium';

  /// Five primary shell roots — Pro mock order.
  static const roots = <String>[
    today,
    exercises,
    progress,
    pro,
    profile,
  ];

  static const primaryTabCount = 5;

  /// Known `/v2/*` prefixes that are valid product surfaces (shell + flows).
  static bool isKnownV2Location(String location) {
    final path = Uri.tryParse(location)?.path ?? location;
    if (!path.startsWith('/v2/')) return false;
    const known = <String>[
      today,
      exercises,
      check,
      plan,
      progress,
      pro,
      reports,
      profile,
      premium,
      '/v2/today',
      '/v2/brain-profile',
      '/v2/brain-profile/ready',
      '/v2/brain-check',
      '/v2/plan/building',
      '/v2/plan/today-ready',
      '/v2/plan/today-preview',
      '/v2/session',
      '/v2/weekly-review',
      '/v2/onboarding',
      '/v2/reports/artifact',
      '/v2/reports/measurements',
      '/v2/premium/plans',
      '/v2/premium/success',
      '/v2/premium/status',
      '/v2/premium/restore',
      '/v2/safa',
      '/v2/diagnostic',
    ];
    for (final prefix in known) {
      if (path == prefix || path.startsWith('$prefix/')) return true;
    }
    return roots.contains(path);
  }
}
