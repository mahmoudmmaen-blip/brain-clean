import 'recovery_plan_intensity.dart';
import 'recovery_plan_priority.dart';
import 'recovery_plan_step.dart';
import 'recovery_practice_catalog.dart';

/// Maps priorities → practice steps (contract §11).
abstract final class PracticeMapper {
  static List<RecoveryPlanStep> map({
    required RecoveryPlanPriority priority,
    required RecoveryPlanIntensity intensity,
    required bool omitOptionals,
  }) {
    if (priority.priorities.isEmpty) {
      return const [];
    }

    final used = <String>{};
    final required = <RecoveryPlanStep>[];
    final optional = <RecoveryPlanStep>[];

    // 1) First unused primary per priority domain (in order).
    for (final p in priority.priorities) {
      final primaries = RecoveryPracticeCatalog.primaryForDomain(p.domainId);
      for (final practiceId in primaries) {
        if (used.contains(practiceId)) continue;
        used.add(practiceId);
        required.add(
          RecoveryPlanStep.fromPractice(
            practiceId: practiceId,
            targetDomainId: p.domainId,
            optional: false,
          ),
        );
        break;
      }
    }

    // 2) Fill required up to intensity count.
    final needRequired = intensity.requiredStepCount;
    if (required.length < needRequired) {
      final candidates = _remainingCandidates(priority, used);
      for (final c in candidates) {
        if (required.length >= needRequired) break;
        used.add(c.practiceId);
        required.add(
          RecoveryPlanStep.fromPractice(
            practiceId: c.practiceId,
            targetDomainId: c.domainId,
            optional: false,
          ),
        );
      }
    }

    // Cap required if somehow over.
    while (required.length > needRequired) {
      required.removeLast();
    }

    // 3) Optionals from unused secondaries (prefer stronger overlap).
    if (!omitOptionals) {
      final maxOpt = intensity.maxOptionalSteps;
      final maxTotal = intensity.maxTotalSteps;
      final candidates = _remainingCandidates(
        priority,
        used,
        preferStrongerOverlap: priority.strongerDomainId,
      );
      for (final c in candidates) {
        if (optional.length >= maxOpt) break;
        if (required.length + optional.length >= maxTotal) break;
        used.add(c.practiceId);
        optional.add(
          RecoveryPlanStep.fromPractice(
            practiceId: c.practiceId,
            targetDomainId: c.domainId,
            optional: true,
          ),
        );
      }
    }

    // Hard total cap.
    final all = <RecoveryPlanStep>[...required, ...optional];
    if (all.length > intensity.maxTotalSteps) {
      return all.take(intensity.maxTotalSteps).toList(growable: false);
    }

    // Ensure standard path time estimate ≤ 20 by trimming trailing optionals.
    var trimmed = List<RecoveryPlanStep>.from(all);
    while (_standardMinutes(trimmed) > 20 &&
        trimmed.any((s) => s.optional)) {
      final idx = trimmed.lastIndexWhere((s) => s.optional);
      if (idx < 0) break;
      trimmed.removeAt(idx);
    }

    return List<RecoveryPlanStep>.unmodifiable(trimmed);
  }

  static int _standardMinutes(List<RecoveryPlanStep> steps) {
    var sum = 0;
    for (final s in steps) {
      sum += s.durationMinutesMax;
    }
    return sum;
  }

  static List<_Candidate> _remainingCandidates(
    RecoveryPlanPriority priority,
    Set<String> used, {
    String? preferStrongerOverlap,
  }) {
    final candidates = <_Candidate>[];
    for (final p in priority.priorities) {
      for (final id in RecoveryPracticeCatalog.primaryForDomain(p.domainId)) {
        if (!used.contains(id)) {
          candidates.add(_Candidate(id, p.domainId, primary: true));
        }
      }
      for (final id in RecoveryPracticeCatalog.secondaryForDomain(p.domainId)) {
        if (!used.contains(id)) {
          candidates.add(_Candidate(id, p.domainId, primary: false));
        }
      }
    }

    // Prefer secondaries that also map to stronger domain tags via catalog.
    candidates.sort((a, b) {
      final aPref = _strongerPref(a, preferStrongerOverlap);
      final bPref = _strongerPref(b, preferStrongerOverlap);
      if (aPref != bPref) return bPref.compareTo(aPref);
      if (a.primary != b.primary) return a.primary ? -1 : 1;
      return a.practiceId.compareTo(b.practiceId);
    });
    return candidates;
  }

  static int _strongerPref(_Candidate c, String? strongerDomainId) {
    if (strongerDomainId == null) return 0;
    final secondaries =
        RecoveryPracticeCatalog.secondaryForDomain(strongerDomainId);
    final primaries =
        RecoveryPracticeCatalog.primaryForDomain(strongerDomainId);
    if (secondaries.contains(c.practiceId) ||
        primaries.contains(c.practiceId)) {
      return 1;
    }
    return 0;
  }
}

class _Candidate {
  const _Candidate(this.practiceId, this.domainId, {required this.primary});
  final String practiceId;
  final String domainId;
  final bool primary;
}
