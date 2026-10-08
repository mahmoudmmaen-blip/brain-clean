import 'dart:convert';
import 'dart:io';

import 'package:brain_clean_mobile/v3/content/content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ContentBundle bundle;
  late Map<String, dynamic> programJson;
  late Map<String, dynamic> exercisesJson;
  late Map<String, dynamic> clarityJson;
  late Map<String, dynamic> sosJson;

  setUpAll(() async {
    Future<String> loadFile(String assetPath) async {
      final file = File(assetPath);
      expect(file.existsSync(), isTrue, reason: 'Missing $assetPath');
      return file.readAsString();
    }

    final repo = ContentRepository(assetLoader: loadFile);
    bundle = await repo.load();

    programJson = jsonDecode(await loadFile(V3ContentAssets.program))
        as Map<String, dynamic>;
    exercisesJson = jsonDecode(await loadFile(V3ContentAssets.exercises))
        as Map<String, dynamic>;
    clarityJson = jsonDecode(await loadFile(V3ContentAssets.clarityCheck))
        as Map<String, dynamic>;
    sosJson =
        jsonDecode(await loadFile(V3ContentAssets.sos)) as Map<String, dynamic>;
  });

  test('days are exactly 1..30', () {
    final days = bundle.program.days.map((d) => d.day).toList()..sort();
    expect(days, List<int>.generate(30, (i) => i + 1));
    expect(bundle.program.days, hasLength(30));
  });

  test('every bilingual text/list object has ar and en', () {
    final missing = <String>[];
    void walk(Object? node, String path) {
      if (node is Map) {
        final map = Map<String, dynamic>.from(node);
        final hasAr = map.containsKey('ar');
        final hasEn = map.containsKey('en');
        if (hasAr || hasEn) {
          if (!hasAr || !hasEn) {
            missing.add(path);
          } else {
            final ar = map['ar'];
            final en = map['en'];
            final bothStrings = ar is String && en is String;
            final bothLists = ar is List && en is List;
            if (!bothStrings && !bothLists) {
              missing.add('$path (ar/en type mismatch)');
            }
          }
        }
        for (final entry in map.entries) {
          if (entry.key == 'ar' || entry.key == 'en') continue;
          walk(entry.value, '$path.${entry.key}');
        }
      } else if (node is List) {
        for (var i = 0; i < node.length; i++) {
          walk(node[i], '$path[$i]');
        }
      }
    }

    walk(programJson, 'program');
    walk(exercisesJson, 'exercises');
    walk(clarityJson, 'clarity_check');
    walk(sosJson, 'sos');
    expect(missing, isEmpty, reason: missing.join('\n'));
  });

  test('every practiceId and bonusId exists in exercises', () {
    final ids = bundle.exercises.ids;
    for (final day in bundle.program.days) {
      expect(
        ids.contains(day.practiceId),
        isTrue,
        reason: 'day ${day.day} practiceId ${day.practiceId}',
      );
      final bonus = day.bonusId;
      if (bonus != null) {
        expect(
          ids.contains(bonus),
          isTrue,
          reason: 'day ${day.day} bonusId $bonus',
        );
      }
    }
  });

  test('days 1-7 only use tier free exercises', () {
    for (final day in bundle.program.days.where((d) => d.day <= 7)) {
      final practice = bundle.exercises.byId(day.practiceId);
      expect(practice, isNotNull, reason: day.practiceId);
      expect(
        practice!.tier,
        ExerciseTier.free,
        reason: 'day ${day.day} practice ${day.practiceId}',
      );
      final bonusId = day.bonusId;
      if (bonusId != null) {
        final bonus = bundle.exercises.byId(bonusId);
        expect(bonus, isNotNull);
        expect(
          bonus!.tier,
          ExerciseTier.free,
          reason: 'day ${day.day} bonus $bonusId',
        );
      }
    }
  });

  test('exercise steps ar/en lengths match', () {
    for (final exercise in bundle.exercises.exercises) {
      expect(
        exercise.steps.lengthsMatch,
        isTrue,
        reason: '${exercise.id} steps ar=${exercise.steps.values['ar']?.length} '
            'en=${exercise.steps.values['en']?.length}',
      );
    }
    for (final day in bundle.program.days) {
      expect(
        day.lesson.body.lengthsMatch,
        isTrue,
        reason: 'day ${day.day} lesson body lengths',
      );
    }
  });

  test('clarity check has 8 questions and scale of 5', () {
    expect(bundle.clarityCheck.questions, hasLength(8));
    expect(bundle.clarityCheck.scale, hasLength(5));
  });

  test('locale resolve falls back to en', () {
    final title = bundle.program.name;
    expect(title.resolve('ar'), isNotEmpty);
    expect(title.resolve('en'), isNotEmpty);
    expect(title.resolve('fr'), title.resolve('en'));
  });

  test('repository caches after first load', () async {
    Future<String> loadFile(String assetPath) => File(assetPath).readAsString();
    final repo = ContentRepository(assetLoader: loadFile);
    final a = await repo.load();
    final b = await repo.load();
    expect(identical(a, b), isTrue);
  });
}
