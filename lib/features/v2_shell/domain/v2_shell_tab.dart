/// Canonical V2 shell tabs (Slice 9.1) — navigation composition only.
enum V2ShellTab {
  home,
  check,
  plan,
  progress,
  reports,
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
        V2ShellTab.home => '/v2/home',
        V2ShellTab.check => '/v2/check',
        V2ShellTab.plan => '/v2/plan',
        V2ShellTab.progress => '/v2/progress',
        V2ShellTab.reports => '/v2/reports',
        V2ShellTab.profile => '/v2/profile',
      };

  static V2ShellTab? fromLocation(String location) {
    final path = Uri.tryParse(location)?.path ?? location;
    if (path == '/v2/home' || path == '/v2/today') return V2ShellTab.home;
    if (path == '/v2/check') return V2ShellTab.check;
    if (path == '/v2/plan' || path.startsWith('/v2/plan/')) {
      // Building / preview / ready stay outside the shell tab.
      if (path == '/v2/plan') return V2ShellTab.plan;
      return null;
    }
    if (path == '/v2/progress') return V2ShellTab.progress;
    if (path == '/v2/reports' || path.startsWith('/v2/reports/')) {
      return V2ShellTab.reports;
    }
    if (path == '/v2/profile' || path == '/v2/brain-profile') {
      return V2ShellTab.profile;
    }
    return null;
  }
}

/// Paths composed into the V2 shell (deep-link roots).
abstract final class V2ShellPaths {
  static const home = '/v2/home';
  static const check = '/v2/check';
  static const plan = '/v2/plan';
  static const progress = '/v2/progress';
  static const reports = '/v2/reports';
  static const profile = '/v2/profile';

  static const roots = <String>[
    home,
    check,
    plan,
    progress,
    reports,
    profile,
  ];

  /// Known `/v2/*` prefixes that are valid product surfaces (shell + flows).
  static bool isKnownV2Location(String location) {
    final path = Uri.tryParse(location)?.path ?? location;
    if (!path.startsWith('/v2/')) return false;
    const known = <String>[
      home,
      check,
      plan,
      progress,
      reports,
      profile,
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
    ];
    for (final prefix in known) {
      if (path == prefix || path.startsWith('$prefix/')) return true;
    }
    // Exact shell roots already covered; also allow exact matches above.
    return roots.contains(path);
  }
}
