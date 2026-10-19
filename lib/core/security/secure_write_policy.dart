/// Remote-write policy for product modules.
///
/// V3 is offline-first: Hive modules persist on-device only. Legacy cloud
/// module names are retained here as documentation of what must stay local.
abstract final class SecureWritePolicy {
  SecureWritePolicy._();

  /// Modules that persist only on-device (no network write).
  static const localOnlyModules = <String>[
    'v2_onboarding',
    'brain_check',
    'brain_profile',
    'recovery_plan',
    'daily_session',
    'progress',
    'weekly_review',
    'v2_reports',
    'v2_shell',
    'pomodoro',
    'games',
    'focus',
    'accountability',
    'settings',
    'pro',
    'home',
    'bci',
    'journal',
    'notifications',
    'biometric_lock',
    'v3_state',
  ];

  static bool isLocalOnly(String module) => localOnlyModules.contains(module);
}
