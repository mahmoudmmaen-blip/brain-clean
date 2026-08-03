/// Post-proof Soft Appreciation eligibility (Premium Contract §6).
///
/// Slice 9.2B does not invent automatic launch interruption. Soft auto-offer
/// is only allowed when an external approved trigger supplies [hasCompletedWeeklyArtifact]
/// and cooldown flags. Explicit Profile/Settings and Reports archive remain allowed.
abstract final class PremiumEligibility {
  /// Forbidden surfaces — Soft auto offer must never interrupt these.
  static const forbiddenAutoSources = <String>{
    'onboarding',
    'brain_check',
    'profile_reveal',
    'first_today',
    'session',
    'weekly_review',
    'sos',
    'setback',
    'app_launch',
  };

  /// Explicit user entry is always allowed (Profile / Settings / deep link).
  static bool allowsExplicitEntry(String? source) {
    final s = (source ?? '').toLowerCase();
    if (s.isEmpty) return true;
    // Explicit named entries.
    if (s == 'profile' ||
        s == 'settings' ||
        s == 'reports' ||
        s == 'reports_archive' ||
        s == 'restore' ||
        s == 'deep_link' ||
        s == 'manage') {
      return true;
    }
    // Soft post-proof (artifact) — only when not a forbidden window.
    if (s == 'weekly_artifact' || s == 'artifact') {
      return !forbiddenAutoSources.contains(s);
    }
    return !forbiddenAutoSources.contains(s);
  }

  /// Soft auto appreciation after completed WeeklyArtifact.
  static bool allowsSoftAppreciation({
    required bool hasCompletedWeeklyArtifact,
    required bool cooldownClear,
    required bool underWeeklyCap,
    String? source,
  }) {
    if (!hasCompletedWeeklyArtifact) return false;
    if (!cooldownClear || !underWeeklyCap) return false;
    final s = (source ?? 'weekly_artifact').toLowerCase();
    if (forbiddenAutoSources.contains(s)) return false;
    return true;
  }
}
