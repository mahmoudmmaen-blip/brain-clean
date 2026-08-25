import '../../brain_profile/domain/profile_pack.dart';
import 'structured_daily_activity.dart';

/// Derives program scores from a [ProfilePack] when available.
abstract final class StructuredDailyProgramScoresResolver {
  static StructuredDailyProgramScores fromProfile(ProfilePack? pack) {
    if (pack == null) return StructuredDailyProgramScores.neutral;

    final attention = _firstDomainScore(
      pack,
      const ['lite_attention', 'full_attention'],
      fallback: StructuredDailyProgramScores.neutral.attention,
    );
    // Memory domain is not always present; keep neutral until tests feed it.
    final memory = _firstDomainScore(
      pack,
      const ['memory', 'working_memory', 'full_mood'],
      fallback: StructuredDailyProgramScores.neutral.memory,
    );
    final habitsHealth = _firstDomainScore(
      pack,
      const ['full_habits', 'lite_recovery'],
      fallback: 60,
    );
    // Higher habits health → lower digital-addiction pressure.
    final digitalAddiction = (100 - habitsHealth).clamp(0, 100);

    return StructuredDailyProgramScores(
      attention: attention,
      memory: memory,
      digitalAddiction: digitalAddiction,
      iq: StructuredDailyProgramScores.neutral.iq,
    );
  }

  static int _firstDomainScore(
    ProfilePack pack,
    List<String> domainIds, {
    required int fallback,
  }) {
    for (final id in domainIds) {
      for (final domain in pack.domains) {
        if (domain.domainId != id) continue;
        final score = domain.displayScore;
        if (score != null) return score.clamp(0, 100);
      }
    }
    return fallback;
  }
}
