/// Remote-write policy for product modules.
///
/// Local-first Hive modules never talk to Supabase. Cloud modules must go
/// through a live JWT ([AuthenticatedSession]) plus an Edge Function that
/// re-verifies the token.
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
  ];

  /// Modules that may write remotely — JWT + Edge Function required.
  static const jwtGatedModules = <String, String>{
    'gamification': 'verify-xp',
    'v2_safa': 'safa-chat',
    'user_progress': 'write-user-state',
    'focus_journey': 'write-user-state',
    'diagnostic': 'write-user-state',
    'detox': 'write-user-state',
    'dashboard': 'write-user-state',
    'emotions': 'write-user-state',
    'cloud_sync': 'write-user-state',
    'recovery_protocol': 'write-user-state',
  };

  static bool isLocalOnly(String module) => localOnlyModules.contains(module);

  static String? requiredFunction(String module) => jwtGatedModules[module];
}
