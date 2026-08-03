import '../../brain_check/domain/brain_check_mode.dart';
import '../../brain_profile/domain/measurement_confidence.dart';
import '../../brain_profile/domain/profile_pack.dart';
import '../../brain_profile/domain/profile_version.dart';
import '../../brain_profile/domain/recovery_score.dart';
import 'domain_history_point.dart';
import 'reports_comparison_result.dart';

/// Result of comparing two historical ProfilePacks (never recalculates scores).
class MeasurementComparison {
  const MeasurementComparison({
    required this.result,
    required this.tooEarlyToInterpret,
    required this.lowConfidence,
    required this.latestDisplay,
    required this.earlierDisplay,
    required this.absoluteDelta,
    required this.elapsedDays,
  });

  final ReportsComparisonResult result;
  final bool tooEarlyToInterpret;
  final bool lowConfidence;
  final int? latestDisplay;
  final int? earlierDisplay;
  final int? absoluteDelta;
  final int? elapsedDays;

  static const insufficient = MeasurementComparison(
    result: ReportsComparisonResult.insufficientHistory,
    tooEarlyToInterpret: false,
    lowConfidence: false,
    latestDisplay: null,
    earlierDisplay: null,
    absoluteDelta: null,
    elapsedDays: null,
  );
}

/// Read-only measurement history helpers (Reports Contract §10–§12).
abstract final class MeasurementHistoryEngine {
  static bool isValidForHistory(ProfilePack pack) {
    if (!pack.hasValidRecoveryScore) return false;
    if (pack.profileSchemaVersion != ProfileVersion.profileSchema) {
      return false;
    }
    return pack.recoveryScore.value != null;
  }

  /// Newest first.
  static List<ProfilePack> validNewestFirst(Iterable<ProfilePack> packs) {
    final out = packs.where(isValidForHistory).toList(growable: false);
    final sorted = List<ProfilePack>.from(out)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<ProfilePack>.unmodifiable(sorted);
  }

  static bool areOverallCompatible(ProfilePack a, ProfilePack b) {
    if (!isValidForHistory(a) || !isValidForHistory(b)) return false;
    if (a.recoveryScore.modelVersion != b.recoveryScore.modelVersion) {
      return false;
    }
    if (a.source.mode != b.source.mode) return false;
    if (a.profileSchemaVersion != b.profileSchemaVersion) return false;
    return true;
  }

  static bool areDomainSchemasCompatible(ProfilePack a, ProfilePack b) {
    if (!areOverallCompatible(a, b)) return false;
    return a.domainAggregationModelVersion ==
        b.domainAggregationModelVersion;
  }

  static MeasurementComparison compareOverall({
    required ProfilePack? latest,
    required ProfilePack? earlier,
  }) {
    if (latest == null || earlier == null) {
      return MeasurementComparison.insufficient;
    }
    if (!areOverallCompatible(latest, earlier)) {
      return MeasurementComparison(
        result: ReportsComparisonResult.notComparable,
        tooEarlyToInterpret: false,
        lowConfidence: _lowConfidence(latest) || _lowConfidence(earlier),
        latestDisplay: latest.recoveryScore.value,
        earlierDisplay: earlier.recoveryScore.value,
        absoluteDelta: null,
        elapsedDays: _elapsedDays(latest, earlier),
      );
    }

    final lv = latest.recoveryScore.value!;
    final ev = earlier.recoveryScore.value!;
    final delta = lv - ev;
    final elapsed = _elapsedDays(latest, earlier) ?? 0;
    final tooEarly = delta.abs() < 3 || elapsed < 7;

    final ReportsComparisonResult result;
    if (delta > 0) {
      result = ReportsComparisonResult.higher;
    } else if (delta < 0) {
      result = ReportsComparisonResult.lower;
    } else {
      result = ReportsComparisonResult.unchangedWithinRounding;
    }

    return MeasurementComparison(
      result: result,
      tooEarlyToInterpret: tooEarly && result != ReportsComparisonResult.unchangedWithinRounding,
      lowConfidence: _lowConfidence(latest) || _lowConfidence(earlier),
      latestDisplay: lv,
      earlierDisplay: ev,
      absoluteDelta: delta.abs(),
      elapsedDays: elapsed,
    );
  }

  static List<DomainHistoryPoint> domainHistoryPoints({
    required List<ProfilePack> compatibleNewestFirst,
    required String Function(DateTime) dayKeyOf,
  }) {
    if (compatibleNewestFirst.length < 2) return const [];
    final first = compatibleNewestFirst.first;
    if (!compatibleNewestFirst.every((p) => areDomainSchemasCompatible(first, p))) {
      return const [];
    }

    final points = <DomainHistoryPoint>[];
    for (final pack in compatibleNewestFirst) {
      for (final d in pack.domains) {
        points.add(
          DomainHistoryPoint(
            profilePackId: pack.id,
            measurementDayKey: dayKeyOf(pack.createdAt),
            domainId: d.domainId,
            titleEn: d.titleEn,
            titleAr: d.titleAr,
            displayedEstimate: d.displayScore,
            scoreModelVersion: pack.recoveryScore.modelVersion,
            profileSchemaVersion: pack.profileSchemaVersion,
            confidenceWire: pack.confidence.wireName,
          ),
        );
      }
    }
    return List<DomainHistoryPoint>.unmodifiable(points);
  }

  /// User-facing snapshot for one valid pack (no internal ids in UI layer).
  static MeasurementHistoryItem toItem(
    ProfilePack pack, {
    required String measurementDayKey,
  }) {
    final domains = pack.domains
        .map(
          (d) => MeasurementDomainSummary(
            titleEn: d.titleEn,
            titleAr: d.titleAr,
            displayedEstimate: d.displayScore,
          ),
        )
        .toList(growable: false);
    return MeasurementHistoryItem(
      profilePackId: pack.id,
      measurementDayKey: measurementDayKey,
      scoreDisplay: pack.recoveryScore.value!,
      bandWire: pack.recoveryScore.band.wireName,
      confidenceWire: pack.confidence.wireName,
      scoreModelVersion: pack.recoveryScore.modelVersion,
      mode: pack.source.mode,
      domains: domains,
    );
  }

  static bool _lowConfidence(ProfilePack pack) =>
      pack.confidence.wireName == 'provisional';

  static int? _elapsedDays(ProfilePack latest, ProfilePack earlier) {
    final ms = latest.createdAt.difference(earlier.createdAt).inDays;
    return ms.abs();
  }
}

class MeasurementDomainSummary {
  const MeasurementDomainSummary({
    required this.titleEn,
    required this.titleAr,
    required this.displayedEstimate,
  });

  final String titleEn;
  final String titleAr;
  final int? displayedEstimate;

  String titleForLocale(String languageCode) =>
      languageCode == 'ar' ? titleAr : titleEn;
}

class MeasurementHistoryItem {
  const MeasurementHistoryItem({
    required this.profilePackId,
    required this.measurementDayKey,
    required this.scoreDisplay,
    required this.bandWire,
    required this.confidenceWire,
    required this.scoreModelVersion,
    required this.mode,
    required this.domains,
  });

  final String profilePackId;
  final String measurementDayKey;
  final int scoreDisplay;
  final String bandWire;
  final String confidenceWire;
  final String scoreModelVersion;
  final BrainCheckMode mode;
  final List<MeasurementDomainSummary> domains;
}
