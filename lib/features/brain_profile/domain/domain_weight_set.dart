import '../../brain_check/domain/brain_check_mode.dart';

/// Equal domain weights — `weight_set_equal_v1` (contract §7).
abstract final class DomainWeightSet {
  static const version = 'weight_set_equal_v1';

  static Map<String, double> forMode(BrainCheckMode mode) {
    switch (mode) {
      case BrainCheckMode.lite:
        return const {
          'lite_attention': 0.50,
          'lite_recovery': 0.50,
        };
      case BrainCheckMode.pulse:
        return const {
          'pulse_check': 1.00,
        };
      case BrainCheckMode.full:
        return const {
          'full_attention': 0.25,
          'full_mood': 0.25,
          'full_habits': 0.25,
          'full_intention': 0.25,
        };
    }
  }
}
