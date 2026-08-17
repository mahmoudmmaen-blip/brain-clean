import '../../brain_check/domain/brain_check_item_bank.dart';
import '../../brain_check/domain/brain_check_mode.dart';
import '../../brain_profile/domain/brain_profile_domain_result.dart';
import '../../brain_profile/domain/profile_pack.dart';
import 'recovery_plan_priority.dart';

/// Deterministic priority selection (contract §5–§6).
abstract final class PrioritySelector {
  static const maxPriorities = 2;
  static const maxStronger = 1;
  static const allCloseThreshold = 5;
  static const solePriorityGap = 10;

  static List<String> canonicalOrderForMode(BrainCheckMode mode) {
    return BrainCheckItemBank.sectionsFor(mode)
        .map((s) => s.id)
        .toList(growable: false);
  }

  static RecoveryPlanPriority select(ProfilePack pack) {
    final mode = pack.source.mode;
    final order = canonicalOrderForMode(mode);
    final orderIndex = <String, int>{
      for (var i = 0; i < order.length; i++) order[i]: i,
    };

    final valid = <BrainProfileDomainResult>[];
    for (final d in pack.domains) {
      if (!d.hasData || d.displayScore == null) continue;
      if (!orderIndex.containsKey(d.domainId)) continue;
      valid.add(d);
    }

    if (valid.isEmpty) {
      return const RecoveryPlanPriority(priorities: []);
    }

    // Lowest score first; tie → earlier canonical order.
    valid.sort((a, b) {
      final scoreCmp = a.displayScore!.compareTo(b.displayScore!);
      if (scoreCmp != 0) return scoreCmp;
      return orderIndex[a.domainId]!.compareTo(orderIndex[b.domainId]!);
    });

    var takeCount = maxPriorities;
    if (mode == BrainCheckMode.pulse) {
      takeCount = 1;
    } else if (valid.length >= 2) {
      final scores = valid.map((d) => d.displayScore!).toList();
      final minS = scores.first;
      final maxS = scores.reduce((a, b) => a > b ? a : b);
      if (maxS - minS <= allCloseThreshold) {
        takeCount = 1;
      } else if (valid.length >= 2 &&
          valid[1].displayScore! - valid[0].displayScore! >= solePriorityGap) {
        takeCount = 1;
      }
    }
    takeCount = takeCount.clamp(1, valid.length);

    final priorities = <RecoveryPlanDomainPriority>[];
    for (var i = 0; i < takeCount; i++) {
      final d = valid[i];
      priorities.add(
        RecoveryPlanDomainPriority(
          domainId: d.domainId,
          titleEn: d.titleEn,
          titleAr: d.titleAr,
          displayScore: d.displayScore!,
          rank: i,
        ),
      );
    }

    // Stronger = highest score; ties → later canonical order.
    final byHigh = List<BrainProfileDomainResult>.from(valid)
      ..sort((a, b) {
        final scoreCmp = b.displayScore!.compareTo(a.displayScore!);
        if (scoreCmp != 0) return scoreCmp;
        return orderIndex[b.domainId]!.compareTo(orderIndex[a.domainId]!);
      });

    final priorityIds = priorities.map((p) => p.domainId).toSet();
    BrainProfileDomainResult? stronger;
    for (final d in byHigh) {
      if (!priorityIds.contains(d.domainId)) {
        stronger = d;
        break;
      }
    }

    return RecoveryPlanPriority(
      priorities: List<RecoveryPlanDomainPriority>.unmodifiable(priorities),
      strongerDomainId: stronger?.domainId,
      strongerTitleEn: stronger?.titleEn,
      strongerTitleAr: stronger?.titleAr,
    );
  }
}
