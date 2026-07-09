import 'package:brain_clean_mobile/features/anxiety/domain/anxiety_level.dart';
import 'package:brain_clean_mobile/features/anxiety/domain/anxiety_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnxietyScoring', () {
    test('computes score as percentage of max sum (24)', () {
      expect(
        AnxietyScoring.computeScore(List<int>.filled(8, 0)),
        closeTo(0, 0.01),
      );
      expect(
        AnxietyScoring.computeScore(List<int>.filled(8, 3)),
        closeTo(100, 0.01),
      );
      expect(
        AnxietyScoring.computeScore(const [3, 3, 3, 3, 3, 3, 3, 0]),
        closeTo(87.5, 0.01),
      );
    });

    test('maps score bands to anxiety levels', () {
      expect(AnxietyLevelScoring.fromScore(0), AnxietyLevel.calm);
      expect(AnxietyLevelScoring.fromScore(25), AnxietyLevel.calm);
      expect(AnxietyLevelScoring.fromScore(26), AnxietyLevel.moderate);
      expect(AnxietyLevelScoring.fromScore(50), AnxietyLevel.moderate);
      expect(AnxietyLevelScoring.fromScore(51), AnxietyLevel.high);
      expect(AnxietyLevelScoring.fromScore(75), AnxietyLevel.high);
      expect(AnxietyLevelScoring.fromScore(76), AnxietyLevel.severe);
      expect(AnxietyLevelScoring.fromScore(100), AnxietyLevel.severe);
    });

    test('buildResult packages answers, score, and level', () {
      final result = AnxietyScoring.buildResult(const [2, 2, 2, 2, 2, 2, 2, 2]);
      expect(result.score, closeTo(66.67, 0.1));
      expect(result.level, AnxietyLevel.high);
      expect(result.answers.length, 8);
    });
  });
}
