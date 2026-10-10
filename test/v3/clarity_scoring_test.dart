import 'dart:convert';
import 'dart:io';

import 'package:brain_clean_mobile/v3/content/content.dart';
import 'package:brain_clean_mobile/v3/domain/clarity_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ClarityCheckContent content;

  setUpAll(() async {
    final raw = await File('assets/content/clarity_check.json').readAsString();
    content = ClarityCheckContent.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  });

  Map<String, int> allAnswers(int value) {
    return {
      for (final q in content.questions) q.id: value,
    };
  }

  test('all-best answers yield clarity score 100', () {
    final best = <String, int>{};
    for (final q in content.questions) {
      best[q.id] = q.reverse ? 0 : 4;
    }
    final outcome = ClarityScoring.compute(
      content: content,
      answers: best,
      hoursEstimate: 3,
    );
    expect(outcome.score, 100);
  });

  test('all-worst answers yield clarity score 0', () {
    final worst = <String, int>{};
    for (final q in content.questions) {
      worst[q.id] = q.reverse ? 4 : 0;
    }
    final outcome = ClarityScoring.compute(
      content: content,
      answers: worst,
      hoursEstimate: 9,
    );
    expect(outcome.score, 0);
  });

  test('reverse items flip contribution', () {
    expect(ClarityScoring.itemScore(4, reverse: true), 0);
    expect(ClarityScoring.itemScore(0, reverse: true), 4);
    expect(ClarityScoring.itemScore(4, reverse: false), 4);
    expect(ClarityScoring.itemScore(0, reverse: false), 0);
  });

  test('area scores follow per-area formula', () {
    final answers = allAnswers(2);
    final outcome = ClarityScoring.compute(
      content: content,
      answers: answers,
      hoursEstimate: 5,
    );
    expect(outcome.areas.focus, 50);
    expect(outcome.areas.control, 50);
    expect(outcome.areas.sleep, 50);
    expect(outcome.areas.calm, 50);
  });

  test('band lookup matches score ranges', () {
    expect(ClarityScoring.bandForScore(content, 39).min, 0);
    expect(ClarityScoring.bandForScore(content, 40).min, 40);
    expect(ClarityScoring.bandForScore(content, 100).max, 100);
    expect(ClarityScoring.bandForScore(content, 0).label.resolve('en'), isNotEmpty);
  });
}
