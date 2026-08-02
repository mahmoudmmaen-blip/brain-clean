/// Plan lifecycle / generation status.
enum RecoveryPlanStatus {
  /// Fully personalized from valid score + mapping.
  ready,

  /// Contract starter fallback (not fabricated personalization).
  starterFallback,

  /// Active pointer target.
  active,

  /// Superseded by a newer active plan (immutable history row).
  historical,
}

extension RecoveryPlanStatusX on RecoveryPlanStatus {
  String get wireName => switch (this) {
        RecoveryPlanStatus.ready => 'ready',
        RecoveryPlanStatus.starterFallback => 'starter_fallback',
        RecoveryPlanStatus.active => 'active',
        RecoveryPlanStatus.historical => 'historical',
      };

  static RecoveryPlanStatus fromWire(String? raw) {
    switch (raw) {
      case 'starter_fallback':
        return RecoveryPlanStatus.starterFallback;
      case 'active':
        return RecoveryPlanStatus.active;
      case 'historical':
        return RecoveryPlanStatus.historical;
      case 'ready':
      default:
        return RecoveryPlanStatus.ready;
    }
  }
}
