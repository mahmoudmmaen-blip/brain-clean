/// Schema / calculation version stamps for V2 Brain Profile.
abstract final class ProfileVersion {
  /// Persisted ProfilePack JSON shape.
  static const profileSchema = 'brain_profile_pack_v1';

  /// Brain Check item-bank / MeasurementEvent shape this pack expects.
  static const brainCheckSchema = 'brain_check_measurement_v1';

  /// Overall Recovery Score model. Remains pending until mathematics
  /// authority is present in-repo (Build Spec is silent on weights/bands).
  static const recoveryScoreModel = 'recovery_score_pending_v0';

  /// Domain aggregation only (equal-weight mean within a section).
  static const domainAggregationModel = 'domain_mean_v1';
}
