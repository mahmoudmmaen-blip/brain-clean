/// Free / Premium archive depth (Reports Contract §9 / §14).
///
/// Free: indices 0 and 1 (latest + previous).
/// Premium: full history.
/// Newly created current evidence is never hidden.
abstract final class ReportsArchiveGate {
  static const freeArtifactDepth = 2;
  static const freeMeasurementDepth = 2;

  static bool canAccessArtifactIndex(int index, {required bool isPremium}) {
    if (index < 0) return false;
    if (isPremium) return true;
    return index < freeArtifactDepth;
  }

  static bool canAccessMeasurementIndex(int index, {required bool isPremium}) {
    if (index < 0) return false;
    if (isPremium) return true;
    return index < freeMeasurementDepth;
  }

  static int visibleArtifactCount(int total, {required bool isPremium}) {
    if (total <= 0) return 0;
    if (isPremium) return total;
    return total < freeArtifactDepth ? total : freeArtifactDepth;
  }

  static int visibleMeasurementCount(int total, {required bool isPremium}) {
    if (total <= 0) return 0;
    if (isPremium) return total;
    return total < freeMeasurementDepth ? total : freeMeasurementDepth;
  }
}
