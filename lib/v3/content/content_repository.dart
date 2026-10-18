import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clarity_check_content.dart';
import 'content_bundle.dart';
import 'exercises_content.dart';
import 'goal_tips_content.dart';
import 'program_content.dart';
import 'sos_content.dart';

/// Asset paths for V3 JSON content.
abstract final class V3ContentAssets {
  static const program = 'assets/content/program.json';
  static const exercises = 'assets/content/exercises.json';
  static const clarityCheck = 'assets/content/clarity_check.json';
  static const sos = 'assets/content/sos.json';
  static const goalTips = 'assets/content/goal_tips.json';
}

/// Loads program / exercises / clarity check / SOS / goal tips JSON once.
class ContentRepository {
  ContentRepository({
    Future<String> Function(String assetPath)? assetLoader,
  }) : _assetLoader = assetLoader ?? rootBundle.loadString;

  final Future<String> Function(String assetPath) _assetLoader;

  ContentBundle? _cache;
  Future<ContentBundle>? _loading;

  /// Loads all JSON files (cached after first success).
  Future<ContentBundle> load() {
    if (_cache != null) return Future.value(_cache);
    return _loading ??= _loadOnce();
  }

  Future<ContentBundle> _loadOnce() async {
    try {
      final results = await Future.wait([
        _assetLoader(V3ContentAssets.program),
        _assetLoader(V3ContentAssets.exercises),
        _assetLoader(V3ContentAssets.clarityCheck),
        _assetLoader(V3ContentAssets.sos),
        _assetLoader(V3ContentAssets.goalTips),
      ]);
      final bundle = ContentBundle(
        program: ProgramContent.fromJson(
          Map<String, dynamic>.from(jsonDecode(results[0]) as Map),
        ),
        exercises: ExercisesContent.fromJson(
          Map<String, dynamic>.from(jsonDecode(results[1]) as Map),
        ),
        clarityCheck: ClarityCheckContent.fromJson(
          Map<String, dynamic>.from(jsonDecode(results[2]) as Map),
        ),
        sos: SosContent.fromJson(
          Map<String, dynamic>.from(jsonDecode(results[3]) as Map),
        ),
        goalTips: GoalTipsContent.fromJson(
          Map<String, dynamic>.from(jsonDecode(results[4]) as Map),
        ),
      );
      _cache = bundle;
      return bundle;
    } catch (e) {
      _loading = null;
      rethrow;
    }
  }

  /// Tip text for [goal] and [week]. Loads content if needed.
  ///
  /// Falls back to goal `less_scroll` and locale `en`.
  Future<String> goalTip(
    String goal,
    int week, {
    String locale = 'en',
  }) async {
    final bundle = await load();
    return bundle.goalTips.tip(goal: goal, week: week, locale: locale);
  }

  /// Test helper — clears in-memory cache.
  void resetForTesting() {
    _cache = null;
    _loading = null;
  }
}

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository();
});

/// Cached content bundle for the app session.
final v3ContentProvider = FutureProvider<ContentBundle>((ref) async {
  return ref.watch(contentRepositoryProvider).load();
});
