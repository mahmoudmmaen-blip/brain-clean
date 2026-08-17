import '../../brain_profile/data/brain_profile_repository.dart';
import '../../brain_profile/domain/profile_pack.dart';
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

  Future<RecoveryPlan?> active() => _plans.active();
}
