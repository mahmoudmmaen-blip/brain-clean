import 'safa_session_origin.dart';

/// Entry eligibility — explicit only; never auto (Contract §5).
abstract final class SafaEligibility {
  /// Forbidden automatic interruption sources.
  static const forbiddenAutoSources = <String>{
    'app_launch',
    'onboarding',
    'brain_check',
    'score_reveal',
    'profile_reveal',
    'setback',
    'purchase',
    'restore',
    'premium',
    'score_band',
    'streak',
    'missing_days',
  };

  static bool allowsExplicitOrigin(SafaSessionOrigin origin) {
    return origin.allowsExplicitEntry;
  }

  /// Automatic interruption must never open Safa.
  static bool allowsAutomaticEntry(String? source) {
    final s = (source ?? '').trim().toLowerCase();
    if (s.isEmpty) return false;
    if (forbiddenAutoSources.contains(s)) return false;
    return false; // Never allow automatic entry in V1.
  }

  /// Soft post-proof / score-based entry is forbidden.
  static bool allowsScoreBandEntry(Object? _) => false;

  static bool allowsPremiumStatusEntry(Object? _) => false;
}
