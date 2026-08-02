import '../../brain_check/domain/brain_check_item_bank.dart';
import '../../brain_check/domain/brain_check_mode.dart';
import '../../brain_check/domain/brain_check_question.dart';
import '../../brain_check/domain/brain_check_scale.dart';
import '../../brain_check/domain/measurement_event.dart';
import 'brain_profile_domain_result.dart';
import 'measurement_confidence.dart';
import 'profile_version.dart';

/// Equal-weight within-domain aggregation only.
///
/// Does **not** compute an overall Recovery Score (weights/bands unapproved).
abstract final class DomainAggregator {
  static const modelVersion = ProfileVersion.domainAggregationModel;

  /// Maps a raw answer onto 0–100 using the question scale bounds.
  static double normalizeAnswer(BrainCheckQuestion question, int value) {
    final min = question.scale.minValue;
    final max = question.scale.maxValue;
    if (max <= min) return 0;
    final clamped = value.clamp(min, max);
    return ((clamped - min) / (max - min)) * 100.0;
  }

  static List<BrainProfileDomainResult> aggregate(MeasurementEvent event) {
    final sections = BrainCheckItemBank.sectionsFor(event.mode);
    final results = <BrainProfileDomainResult>[];
    for (final section in sections) {
      final norms = <double>[];
      final missing = <String>[];
      for (final question in section.questions) {
        final raw = event.answers[question.id];
        if (raw == null) {
          missing.add(question.id);
          continue;
        }
        norms.add(normalizeAnswer(question, raw));
      }
      double? mean;
      if (norms.isNotEmpty) {
        final sum = norms.fold<double>(0, (a, b) => a + b);
        // One decimal max — no fake precision.
        mean = double.parse((sum / norms.length).toStringAsFixed(1));
      }
      results.add(
        BrainProfileDomainResult(
          domainId: section.id,
          titleEn: section.titleEn,
          titleAr: section.titleAr,
          answeredCount: norms.length,
          expectedCount: section.questions.length,
          missingQuestionIds: List<String>.unmodifiable(missing),
          normalizedMean: mean,
        ),
      );
    }
    return List<BrainProfileDomainResult>.unmodifiable(results);
  }

  static MeasurementConfidence confidenceFor({
    required BrainCheckMode mode,
    required List<BrainProfileDomainResult> domains,
  }) {
    final expected =
        domains.fold<int>(0, (sum, d) => sum + d.expectedCount);
    final answered =
        domains.fold<int>(0, (sum, d) => sum + d.answeredCount);
    if (expected == 0 || answered == 0) {
      return MeasurementConfidence.provisional;
    }
    final coverage = answered / expected;
    // CHK-03: Lite confidence flag — Lite stays provisional/moderate.
    if (mode == BrainCheckMode.lite) {
      return coverage >= 1.0
          ? MeasurementConfidence.moderate
          : MeasurementConfidence.provisional;
    }
    if (mode == BrainCheckMode.pulse) {
      return coverage >= 1.0
          ? MeasurementConfidence.moderate
          : MeasurementConfidence.provisional;
    }
    if (coverage >= 1.0) return MeasurementConfidence.solid;
    if (coverage >= 0.7) return MeasurementConfidence.moderate;
    return MeasurementConfidence.provisional;
  }

  static List<BrainProfileDomainResult> rankedStronger(
    List<BrainProfileDomainResult> domains, {
    int limit = 2,
  }) {
    final withData = domains.where((d) => d.hasData).toList()
      ..sort(
        (a, b) => (b.normalizedMean ?? 0).compareTo(a.normalizedMean ?? 0),
      );
    return withData.take(limit).toList(growable: false);
  }

  static List<BrainProfileDomainResult> rankedSupport(
    List<BrainProfileDomainResult> domains, {
    int limit = 2,
  }) {
    final withData = domains.where((d) => d.hasData).toList()
      ..sort(
        (a, b) => (a.normalizedMean ?? 0).compareTo(b.normalizedMean ?? 0),
      );
    return withData.take(limit).toList(growable: false);
  }
}
