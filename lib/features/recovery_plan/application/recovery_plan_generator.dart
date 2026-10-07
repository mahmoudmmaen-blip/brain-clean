import '../../brain_check/domain/brain_check_mode.dart';
import '../../brain_profile/data/brain_profile_repository.dart';
import '../../brain_profile/domain/measurement_confidence.dart';
import '../../brain_profile/domain/measurement_explanation.dart';
import '../../brain_profile/domain/profile_pack.dart';
import '../../brain_profile/domain/profile_source_reference.dart';
import '../../brain_profile/domain/profile_version.dart';
import '../../brain_profile/domain/recovery_score.dart';
import '../data/recovery_plan_repository.dart';
import '../domain/recovery_plan.dart';
import '../domain/recovery_plan_engine.dart';

/// Application service: ProfilePack → generate → idempotent persist.
class RecoveryPlanGenerator {
  RecoveryPlanGenerator({
    required RecoveryPlanRepository planRepository,
    required BrainProfileRepository profileRepository,
  })  : _plans = planRepository,
        _profiles = profileRepository;

  final RecoveryPlanRepository _plans;
  final BrainProfileRepository _profiles;

  Future<ProfilePack?> latestProfile() => _profiles.latest();

  Future<ProfilePack?> profileBySession(String sessionId) =>
      _profiles.findBySourceSessionId(sessionId);

  /// Generate (or return existing) plan for [pack].
  Future<RecoveryPlan> generateFor(
    ProfilePack pack, {
    bool isPremium = false,
    String? requestedEngineVersion,
    String? requestedCatalogVersion,
    DateTime? createdAt,
  }) async {
    final generated = RecoveryPlanEngineV1.generate(
      pack,
      isPremium: isPremium,
      requestedEngineVersion: requestedEngineVersion,
      requestedCatalogVersion: requestedCatalogVersion,
      createdAt: createdAt,
    );
    return _plans.saveIfNew(generated);
  }

  /// Generate from latest profile; throws if missing.
  Future<RecoveryPlan> generateFromLatest({
    bool isPremium = false,
  }) async {
    final pack = await _profiles.latest();
    if (pack == null) {
      throw StateError('missing_profile');
    }
    return generateFor(pack, isPremium: isPremium);
  }

  /// Short onboarding starter plan — does NOT persist a Brain Profile pack
  /// (Brain Check stays incomplete until the user takes it).
  Future<RecoveryPlan> generateStarterForOnboarding({
    DateTime? createdAt,
  }) async {
    final existing = await _plans.active();
    if (existing != null) return existing;

    final now = (createdAt ?? DateTime.now()).toUtc();
    final seed = ProfilePack(
      id: 'pp_onboarding_seed',
      source: const ProfileSourceReference(
        sessionId: 'onboarding_seed',
        mode: BrainCheckMode.lite,
        brainCheckSchemaVersion: ProfileVersion.brainCheckSchema,
        source: 'onboarding',
      ),
      createdAt: now,
      lastRecalculatedAt: now,
      domains: const [],
      recoveryScore: RecoveryScore.unavailable,
      confidence: MeasurementConfidence.provisional,
      explanation: ProfileExplanationCatalog.build(
        strongerTitlesEn: const [],
        strongerTitlesAr: const [],
        supportTitlesEn: const [],
        supportTitlesAr: const [],
        confidence: MeasurementConfidence.provisional,
        scorePending: false,
      ),
      profileSchemaVersion: ProfileVersion.profileSchema,
      domainAggregationModelVersion: ProfileVersion.domainAggregationModel,
    );
    return generateFor(seed, createdAt: now);
  }

  Future<RecoveryPlan?> active() => _plans.active();
}
