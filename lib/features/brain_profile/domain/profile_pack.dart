import 'brain_profile_domain_result.dart';
import 'measurement_confidence.dart';
import 'measurement_explanation.dart';
import 'profile_source_reference.dart';
import 'profile_version.dart';
import 'recovery_score.dart';
import 'score_calculation_result.dart';

/// Immutable V2 Brain Profile pack (Build Spec: ProfilePack).
class ProfilePack {
  const ProfilePack({
    required this.id,
    required this.source,
    required this.createdAt,
    required this.lastRecalculatedAt,
    required this.domains,
    required this.recoveryScore,
    required this.confidence,
    required this.explanation,
    required this.profileSchemaVersion,
    required this.domainAggregationModelVersion,
    this.strongerDomainIds = const [],
    this.supportDomainIds = const [],
    this.contributions = const [],
    this.explanationFlags = const [],
  });

  final String id;
  final ProfileSourceReference source;
  final DateTime createdAt;
  final DateTime lastRecalculatedAt;
  final List<BrainProfileDomainResult> domains;
  final RecoveryScore recoveryScore;
  final MeasurementConfidence confidence;
  final MeasurementExplanation explanation;
  final String profileSchemaVersion;
  final String domainAggregationModelVersion;
  final List<String> strongerDomainIds;
  final List<String> supportDomainIds;
  final List<DomainContribution> contributions;
  final List<String> explanationFlags;

  bool get hasPendingRecoveryScore => recoveryScore.isPending;
  bool get hasValidRecoveryScore => recoveryScore.isValid;

  List<String> get missingDataIndicators {
    final missing = <String>[];
    for (final d in domains) {
      if (d.missingQuestionIds.isNotEmpty) {
        missing.add('${d.domainId}:${d.missingQuestionIds.length}');
      }
    }
    if (recoveryScore.isPending) {
      missing.add('recovery_score_pending');
    }
    if (recoveryScore.isUnavailable) {
      missing.add('recovery_score_unavailable');
    }
    return List<String>.unmodifiable(missing);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'source': source.toJson(),
        'createdAt': createdAt.toUtc().toIso8601String(),
        'lastRecalculatedAt': lastRecalculatedAt.toUtc().toIso8601String(),
        'domains': domains.map((d) => d.toJson()).toList(growable: false),
        'recoveryScore': recoveryScore.toJson(),
        'confidence': confidence.wireName,
        'explanation': explanation.toJson(),
        'profileSchemaVersion': profileSchemaVersion,
        'domainAggregationModelVersion': domainAggregationModelVersion,
        'strongerDomainIds': strongerDomainIds,
        'supportDomainIds': supportDomainIds,
        'contributions':
            contributions.map((c) => c.toJson()).toList(growable: false),
        'explanationFlags': explanationFlags,
        'calculationModelVersion': recoveryScore.modelVersion,
      };

  factory ProfilePack.fromJson(Map<String, dynamic> json) {
    final rawDomains = json['domains'];
    final domains = <BrainProfileDomainResult>[];
    if (rawDomains is List) {
      for (final item in rawDomains) {
        if (item is Map) {
          domains.add(
            BrainProfileDomainResult.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }
    final stronger = <String>[];
    final rawStronger = json['strongerDomainIds'];
    if (rawStronger is List) {
      for (final item in rawStronger) {
        stronger.add(item.toString());
      }
    }
    final support = <String>[];
    final rawSupport = json['supportDomainIds'];
    if (rawSupport is List) {
      for (final item in rawSupport) {
        support.add(item.toString());
      }
    }
    final contributions = <DomainContribution>[];
    final rawContrib = json['contributions'];
    if (rawContrib is List) {
      for (final item in rawContrib) {
        if (item is Map) {
          contributions.add(
            DomainContribution.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    final flags = <String>[];
    final rawFlags = json['explanationFlags'];
    if (rawFlags is List) {
      for (final item in rawFlags) {
        flags.add(item.toString());
      }
    }

    return ProfilePack(
      id: json['id'] as String,
      source: ProfileSourceReference.fromJson(
        Map<String, dynamic>.from(json['source'] as Map? ?? const {}),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      lastRecalculatedAt:
          DateTime.parse(json['lastRecalculatedAt'] as String).toUtc(),
      domains: List<BrainProfileDomainResult>.unmodifiable(domains),
      recoveryScore: RecoveryScore.fromJson(
        Map<String, dynamic>.from(
          json['recoveryScore'] as Map? ?? const <String, dynamic>{},
        ),
      ),
      confidence: MeasurementConfidenceX.fromWire(json['confidence'] as String?),
      explanation: MeasurementExplanation.fromJson(
        Map<String, dynamic>.from(
          json['explanation'] as Map? ?? const <String, dynamic>{},
        ),
      ),
      profileSchemaVersion:
          json['profileSchemaVersion'] as String? ?? ProfileVersion.profileSchema,
      domainAggregationModelVersion:
          json['domainAggregationModelVersion'] as String? ??
              ProfileVersion.domainAggregationModel,
      strongerDomainIds: List<String>.unmodifiable(stronger),
      supportDomainIds: List<String>.unmodifiable(support),
      contributions: List<DomainContribution>.unmodifiable(contributions),
      explanationFlags: List<String>.unmodifiable(flags),
    );
  }
}

/// Alias matching Build Spec naming in application code.
typedef BrainProfile = ProfilePack;
