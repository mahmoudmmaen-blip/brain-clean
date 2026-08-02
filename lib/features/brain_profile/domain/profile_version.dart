/// Schema / calculation version stamps for V2 Brain Profile.
abstract final class ProfileVersion {
  /// Persisted ProfilePack JSON shape.
  static const profileSchema = 'brain_profile_pack_v1';

  /// Brain Check item-bank / MeasurementEvent shape this pack expects.
  static const brainCheckSchema = 'brain_check_measurement_v1';

  /// Overall Recovery Score model (`recovery_score_v1`).
  static const recoveryScoreModel = 'recovery_score_v1';

  /// Domain aggregation companion (equal-weight mean within a section).
  static const domainAggregationModel = 'domain_mean_v1';

  /// Equal domain weight set identifier.
  static const weightSet = 'weight_set_equal_v1';
}
