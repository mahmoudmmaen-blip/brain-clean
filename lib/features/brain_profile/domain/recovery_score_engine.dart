import '../../brain_check/domain/brain_check_item_bank.dart';
import '../../brain_check/domain/brain_check_mode.dart';
import '../../brain_check/domain/brain_check_question.dart';
import '../../brain_check/domain/brain_check_scale.dart';
import '../../brain_check/domain/measurement_event.dart';
import 'brain_profile_domain_result.dart';
import 'domain_weight_set.dart';
import 'item_polarity.dart';
import 'measurement_confidence.dart';
import 'profile_version.dart';
import 'recovery_score.dart';
import 'score_calculation_result.dart';

/// Pure, deterministic Recovery Score V1 engine (contract `recovery_score_v1`).
///
/// No AI, network, or randomness.
abstract final class RecoveryScoreEngine {
  static const modelVersion = ProfileVersion.recoveryScoreModel;
  static const weightSetVersion = DomainWeightSet.version;

  /// Half-up toward +∞ for non-negative values (contract §9).
  static int roundHalfUp(double value) {
    return (value + 0.5).floor();
  }

  static RecoveryScoreBand bandForDisplay(int display) {
    if (display < 0 || display > 100) {
      return RecoveryScoreBand.unavailable;
    }
    if (display <= 24) return RecoveryScoreBand.gatheringFooting;
    if (display <= 49) return RecoveryScoreBand.buildingRhythm;
    if (display <= 74) return RecoveryScoreBand.findingSteadiness;
    return RecoveryScoreBand.growingFoundation;
  }

  /// Normalize one answer; reject OOR — never silent-clamp.
  static double? normalizeItemOrNull({
    required BrainCheckQuestion question,
    required int rawValue,
  }) {
    final min = question.scale.minValue;
    final max = question.scale.maxValue;
    if (rawValue < min || rawValue > max) return null;
    if (max <= min) return null;
    final forward100 = ((rawValue - min) / (max - min)) * 100.0;
    final polarity = ItemPolarityTable.forQuestionId(question.id);
    return polarity == ItemPolarity.reverse ? 100.0 - forward100 : forward100;
  }

  static ScoreCalculationResult compute(
    MeasurementEvent event, {
    bool recoveredFromCorrupt = false,
    bool schemaMismatch = false,
    bool optionalDeepenersOmitted = false,
  }) {
    final flags = <String>[];
    if (event.answers.isEmpty) {
      return const ScoreCalculationUnavailable(
        reason: ScoreUnavailableReason.emptyAnswers,
        flags: ['empty_answers'],
      );
    }

    final questions = BrainCheckItemBank.questionsFor(event.mode);
    final knownIds = {for (final q in questions) q.id};

    for (final key in event.answers.keys) {
      if (!knownIds.contains(key)) {
        return ScoreCalculationUnavailable(
          reason: ScoreUnavailableReason.unknownQuestion,
          flags: ['unknown_question', key],
        );
      }
    }

    final missing = <String>[];
    for (final q in questions) {
      if (!event.answers.containsKey(q.id)) {
        missing.add(q.id);
      }
    }
    if (missing.isNotEmpty) {
      return ScoreCalculationUnavailable(
        reason: ScoreUnavailableReason.missingRequired,
        flags: ['missing_required', ...missing],
      );
    }

    final sections = BrainCheckItemBank.sectionsFor(event.mode);
    final weights = DomainWeightSet.forMode(event.mode);
    final domains = <BrainProfileDomainResult>[];
    final contributions = <DomainContribution>[];
    var weightedSum = 0.0;
    var weightTotal = 0.0;

    for (final section in sections) {
      final itemScores = <double>[];
      final missingInDomain = <String>[];
      for (final question in section.questions) {
        final raw = event.answers[question.id];
        if (raw == null) {
          missingInDomain.add(question.id);
          continue;
        }
        final norm = normalizeItemOrNull(question: question, rawValue: raw);
        if (norm == null) {
          return ScoreCalculationUnavailable(
            reason: ScoreUnavailableReason.invalidRange,
            flags: ['invalid_range', question.id, '$raw'],
          );
        }
        itemScores.add(norm);
        if (ItemPolarityTable.forQuestionId(question.id) ==
            ItemPolarity.reverse) {
          if (!flags.contains('reverse_applied')) {
            flags.add('reverse_applied');
          }
        }
      }
      if (missingInDomain.isNotEmpty ||
          itemScores.length != section.questions.length) {
        return ScoreCalculationUnavailable(
          reason: ScoreUnavailableReason.incompleteDomains,
          flags: ['missing_required', ...missingInDomain],
        );
      }
      final mean =
          itemScores.fold<double>(0, (a, b) => a + b) / itemScores.length;
      final weight = weights[section.id];
      if (weight == null || weight <= 0) {
        return const ScoreCalculationUnavailable(
          reason: ScoreUnavailableReason.zeroWeight,
          flags: ['zero_weight'],
        );
      }
      domains.add(
        BrainProfileDomainResult(
          domainId: section.id,
          titleEn: section.titleEn,
          titleAr: section.titleAr,
          answeredCount: itemScores.length,
          expectedCount: section.questions.length,
          missingQuestionIds: const [],
          normalizedMean: mean,
          displayScore: roundHalfUp(mean).clamp(0, 100),
        ),
      );
      final contribution = mean * weight;
      contributions.add(
        DomainContribution(
          domainId: section.id,
          domainScoreInternal: mean,
          weight: weight,
          contribution: contribution,
        ),
      );
      weightedSum += contribution;
      weightTotal += weight;
    }

    if (weightTotal <= 0) {
      return const ScoreCalculationUnavailable(
        reason: ScoreUnavailableReason.zeroWeight,
        flags: ['zero_weight'],
      );
    }

    final overallInternal = weightedSum / weightTotal;
    final display = roundHalfUp(overallInternal).clamp(0, 100);
    final band = bandForDisplay(display);
    final confidence = confidenceFor(
      mode: event.mode,
      recoveredFromCorrupt: recoveredFromCorrupt,
      schemaMismatch: schemaMismatch,
      optionalDeepenersOmitted: optionalDeepenersOmitted,
    );

    if (optionalDeepenersOmitted) {
      flags.add('optional_omitted');
    }
    if (event.mode == BrainCheckMode.lite ||
        event.mode == BrainCheckMode.pulse) {
      flags.add('first_or_short_path');
    }
    flags.add('display_integer_only');

    final stronger = _rank(domains, ascending: false);
    final support = _rank(domains, ascending: true);

    return ScoreCalculationValid(
      recoveryScore: RecoveryScore(
        modelVersion: modelVersion,
        weightSetVersion: weightSetVersion,
        value: display,
        valueInternal: overallInternal,
        band: band,
      ),
      domains: List<BrainProfileDomainResult>.unmodifiable(domains),
      contributions: List<DomainContribution>.unmodifiable(contributions),
      confidence: confidence,
      strongerDomainIds:
          stronger.map((d) => d.domainId).toList(growable: false),
      supportDomainIds: support.map((d) => d.domainId).toList(growable: false),
      flags: List<String>.unmodifiable(flags),
      overallInternal: overallInternal,
    );
  }

  static MeasurementConfidence confidenceFor({
    required BrainCheckMode mode,
    bool recoveredFromCorrupt = false,
    bool schemaMismatch = false,
    bool optionalDeepenersOmitted = false,
  }) {
    if (recoveredFromCorrupt || schemaMismatch) {
      return MeasurementConfidence.provisional;
    }
    if (mode == BrainCheckMode.lite || mode == BrainCheckMode.pulse) {
      return MeasurementConfidence.moderate;
    }
    if (mode == BrainCheckMode.full) {
      if (optionalDeepenersOmitted) {
        return MeasurementConfidence.moderate;
      }
      return MeasurementConfidence.strong;
    }
    return MeasurementConfidence.provisional;
  }

  static List<BrainProfileDomainResult> _rank(
    List<BrainProfileDomainResult> domains, {
    required bool ascending,
    int limit = 2,
  }) {
    final copy = List<BrainProfileDomainResult>.from(domains)
      ..sort((a, b) {
        final av = a.normalizedMean ?? 0;
        final bv = b.normalizedMean ?? 0;
        return ascending ? av.compareTo(bv) : bv.compareTo(av);
      });
    return copy.take(limit).toList(growable: false);
  }
}
