import '../domain/brain_profile_domain_result.dart';
import '../domain/profile_pack.dart';

/// Threshold below which mood/stress domain indicates elevated anxiety.
const int brainCheckHighAnxietyThreshold = 40;

/// Mood-related domain ids used as anxiety proxy in Brain Check results.
const _anxietyDomainIds = <String>{
  'full_mood',
  'lite_recovery',
  'pulse_check',
};

/// True when Brain Check mood/stress scores suggest high anxiety.
bool brainCheckShowsAnxietyWarning(ProfilePack pack) {
  for (final domain in pack.domains) {
    if (!_anxietyDomainIds.contains(domain.domainId) || !domain.hasData) {
      continue;
    }
    final score = domain.displayScore ??
        (domain.normalizedMean == null
            ? null
            : (domain.normalizedMean! + 0.5).floor());
    if (score != null && score < brainCheckHighAnxietyThreshold) {
      return true;
    }
  }
  return false;
}

/// Returns the lowest-scoring anxiety-proxy domain for display context.
BrainProfileDomainResult? brainCheckAnxietyDomain(ProfilePack pack) {
  BrainProfileDomainResult? worst;
  int? worstScore;
  for (final domain in pack.domains) {
    if (!_anxietyDomainIds.contains(domain.domainId) || !domain.hasData) {
      continue;
    }
    final score = domain.displayScore ??
        (domain.normalizedMean == null
            ? null
            : (domain.normalizedMean! + 0.5).floor());
    if (score == null) continue;
    if (worstScore == null || score < worstScore) {
      worstScore = score;
      worst = domain;
    }
  }
  return worst;
}
