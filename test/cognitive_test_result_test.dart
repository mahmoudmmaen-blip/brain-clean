import 'package:brain_clean_mobile/features/cognitive_tests/domain/cognitive_test_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CognitiveTestResult.toJson', () {
    test('omits absent optional telemetry keys', () {
      final json = CognitiveTestResult(
        testId: 'memory',
        normalizedScore: 72.5,
        completedAt: DateTime.utc(2026, 6, 24, 10, 30),
      ).toJson();

      expect(json[CognitiveTestResult.testIdKey], 'memory');
      expect(json[CognitiveTestResult.normalizedScoreKey], 72.5);
      expect(
        json[CognitiveTestResult.completedAtKey],
        DateTime.utc(2026, 6, 24, 10, 30).toIso8601String(),
      );
      expect(json.containsKey(CognitiveTestResult.longestSuccessfulSpanKey), isFalse);
      expect(json.containsKey(CognitiveTestResult.visualTotalPointsKey), isFalse);
      expect(json.containsKey(CognitiveTestResult.visualRoundsPlayedKey), isFalse);
    });

    test('includes telemetry when provided', () {
      final json = CognitiveTestResult(
        testId: 'visual',
        normalizedScore: 88,
        completedAt: DateTime.utc(2026, 6, 24),
        longestSuccessfulSpan: 7,
        visualTotalPoints: 140,
        visualRoundsPlayed: 10,
      ).toJson();

      expect(json[CognitiveTestResult.longestSuccessfulSpanKey], 7);
      expect(json[CognitiveTestResult.visualTotalPointsKey], 140);
      expect(json[CognitiveTestResult.visualRoundsPlayedKey], 10);
    });
  });

  group('CognitiveTestResult.fromJson', () {
    test('round-trips a fully populated result', () {
      final original = CognitiveTestResult(
        testId: 'visual',
        normalizedScore: 61.25,
        completedAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
        longestSuccessfulSpan: 5,
        visualTotalPoints: 90,
        visualRoundsPlayed: 8,
      );

      final restored = CognitiveTestResult.fromJson(original.toJson());

      expect(restored.testId, original.testId);
      expect(restored.normalizedScore, original.normalizedScore);
      expect(restored.completedAt, original.completedAt);
      expect(restored.longestSuccessfulSpan, 5);
      expect(restored.visualTotalPoints, 90);
      expect(restored.visualRoundsPlayed, 8);
    });

    test('falls back to unknown id and zero score for missing fields', () {
      final restored = CognitiveTestResult.fromJson({
        CognitiveTestResult.completedAtKey: '2026-03-01T00:00:00.000Z',
      });

      expect(restored.testId, 'unknown');
      expect(restored.normalizedScore, 0);
      expect(restored.completedAt, DateTime.utc(2026, 3, 1));
      expect(restored.longestSuccessfulSpan, isNull);
    });

    test('coerces integer score to double', () {
      final restored = CognitiveTestResult.fromJson({
        CognitiveTestResult.testIdKey: 'memory',
        CognitiveTestResult.normalizedScoreKey: 80,
        CognitiveTestResult.completedAtKey: '2026-03-01T00:00:00.000Z',
      });

      expect(restored.normalizedScore, 80.0);
    });

    test('throws when completedAt is missing', () {
      expect(
        () => CognitiveTestResult.fromJson({
          CognitiveTestResult.testIdKey: 'memory',
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
