import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiagnosticModel.calculateBcScore', () {
    test('applies weighted pillars correctly at maximum', () {
      const model = DiagnosticModel(
        brainPerformance: 100,
        digitalDiscipline: 100,
        healthyHabits: 100,
        consistency: 100,
      );
      expect(model.calculateBcScore(), 100);
    });

    test('enforces 26.8 floor for low scores', () {
      const model = DiagnosticModel(
        brainPerformance: 0,
        digitalDiscipline: 0,
        healthyHabits: 0,
        consistency: 0,
      );
      expect(model.calculateBcScore(), 26.8);
    });

    test('json round-trip', () {
      const model = DiagnosticModel(
        brainPerformance: 72,
        digitalDiscipline: 65,
        healthyHabits: 80,
        consistency: 55,
      );
      final restored = DiagnosticModel.fromJson(model.toJson());
      expect(restored.calculateBcScore(), model.calculateBcScore());
    });
  });
}
