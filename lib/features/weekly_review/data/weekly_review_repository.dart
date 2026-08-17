import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/weekly_artifact.dart';
import '../domain/weekly_review_enums.dart';
import '../domain/weekly_review_record.dart';
import '../domain/weekly_review_signal.dart';
import '../domain/weekly_review_version.dart';

abstract class WeeklyReviewRepository {
  Future<WeeklyReviewRecord?> findByPeriod(String periodId);
  Future<WeeklyReviewRecord?> findById(String id);
  Future<WeeklyReviewRecord?> latestCompleted();
  Future<List<WeeklyReviewRecord>> history();
  Future<WeeklyArtifact?> artifactByReviewId(String reviewId);
  Future<WeeklyArtifact?> artifactById(String artifactId);

  /// Completed WeeklyArtifacts, newest first (createdAt desc, periodId desc).
  Future<List<WeeklyArtifact>> listArtifacts();

  Future<WeeklyReviewSignal?> signalByArtifactId(String artifactId);
  Future<WeeklyReviewSignal?> signalById(String signalId);

  /// Upsert draft (or overwrite draft fields) by period — never mutates completed.
  Future<WeeklyReviewRecord> saveDraft(WeeklyReviewRecord draft);

  /// Idempotent completion — returns existing completed if present.
  Future<({WeeklyReviewRecord record, WeeklyArtifact artifact, WeeklyReviewSignal signal})>
      complete({
    required WeeklyReviewRecord record,
    required WeeklyArtifact artifact,
    required WeeklyReviewSignal signal,
  });
}

class WeeklyReviewLocalRepository implements WeeklyReviewRepository {
  WeeklyReviewLocalRepository({Box<dynamic>? box}) : _boxOverride = box;

  static const reviewsKey = 'review_history';
  static const artifactsKey = 'artifact_history';
  static const signalsKey = 'signal_history';
  static const latestCompletedKey = 'latest_completed_id';
  static const schemaKey = 'schema_version';

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.weeklyReview);
  }

  Future<void> _ensureSchema(Box<dynamic> box) async {
    final existing = box.get(schemaKey);
    if (existing == null) {
      await box.put(schemaKey, WeeklyReviewVersion.schema);
    }
  }

  List<WeeklyReviewRecord> _decodeReviews(dynamic raw) {
    final out = <WeeklyReviewRecord>[];
    if (raw is! List) return out;
    for (final item in raw) {
      if (item is! Map) continue;
      try {
        out.add(
          WeeklyReviewRecord.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (e) {
        debugPrint('WeeklyReviewLocalRepository: skip corrupt review: $e');
      }
    }
    return out;
  }

  List<WeeklyArtifact> _decodeArtifacts(dynamic raw) {
    final out = <WeeklyArtifact>[];
    if (raw is! List) return out;
    for (final item in raw) {
      if (item is! Map) continue;
      try {
        out.add(WeeklyArtifact.fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        debugPrint('WeeklyReviewLocalRepository: skip corrupt artifact: $e');
      }
    }
    return out;
  }

  List<WeeklyReviewSignal> _decodeSignals(dynamic raw) {
    final out = <WeeklyReviewSignal>[];
    if (raw is! List) return out;
    for (final item in raw) {
      if (item is! Map) continue;
      try {
        out.add(
          WeeklyReviewSignal.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (e) {
        debugPrint('WeeklyReviewLocalRepository: skip corrupt signal: $e');
      }
    }
    return out;
  }

  @override
  Future<List<WeeklyReviewRecord>> history() async {
    try {
      final box = await _openBox();
      await _ensureSchema(box);
      return List.unmodifiable(_decodeReviews(box.get(reviewsKey)));
    } catch (e) {
      debugPrint('WeeklyReviewLocalRepository.history failed: $e');
      return const [];
    }
  }

  @override
  Future<WeeklyReviewRecord?> findById(String id) async {
    if (id.isEmpty) return null;
    final all = await history();
    for (final r in all) {
      if (r.id == id) return r;
    }
    return null;
  }

  @override
  Future<WeeklyReviewRecord?> findByPeriod(String periodId) async {
    if (periodId.isEmpty) return null;
    final all = await history();
    WeeklyReviewRecord? draft;
    for (final r in all) {
      if (r.periodId != periodId) continue;
      if (r.isCompleted) return r;
      draft = r;
    }
    return draft;
  }

  @override
  Future<WeeklyReviewRecord?> latestCompleted() async {
    try {
      final box = await _openBox();
      await _ensureSchema(box);
      final id = box.get(latestCompletedKey) as String?;
      if (id != null && id.isNotEmpty) {
        final found = await findById(id);
        if (found != null && found.isCompleted) return found;
      }
      final all = await history();
      WeeklyReviewRecord? latest;
      for (final r in all) {
        if (!r.isCompleted) continue;
        if (latest == null ||
            (r.completedAt ?? r.updatedAt)
                .isAfter(latest.completedAt ?? latest.updatedAt)) {
          latest = r;
        }
      }
      return latest;
    } catch (e) {
      debugPrint('WeeklyReviewLocalRepository.latestCompleted failed: $e');
      return null;
    }
  }

  @override
  Future<WeeklyArtifact?> artifactByReviewId(String reviewId) async {
    final box = await _openBox();
    await _ensureSchema(box);
    for (final a in _decodeArtifacts(box.get(artifactsKey))) {
      if (a.weeklyReviewRecordId == reviewId) return a;
    }
    return null;
  }

  @override
  Future<WeeklyArtifact?> artifactById(String artifactId) async {
    final box = await _openBox();
    await _ensureSchema(box);
    for (final a in _decodeArtifacts(box.get(artifactsKey))) {
      if (a.artifactId == artifactId) return a;
    }
    return null;
  }

  @override
  Future<List<WeeklyArtifact>> listArtifacts() async {
    try {
      final box = await _openBox();
      await _ensureSchema(box);
      final list = _decodeArtifacts(box.get(artifactsKey));
      list.sort((a, b) {
        final byCreated = b.createdAt.compareTo(a.createdAt);
        if (byCreated != 0) return byCreated;
        return b.periodId.compareTo(a.periodId);
      });
      return List<WeeklyArtifact>.unmodifiable(list);
    } catch (e) {
      debugPrint('WeeklyReviewLocalRepository.listArtifacts failed: $e');
      return const [];
    }
  }

  @override
  Future<WeeklyReviewSignal?> signalByArtifactId(String artifactId) async {
    final box = await _openBox();
    await _ensureSchema(box);
    for (final s in _decodeSignals(box.get(signalsKey))) {
      if (s.sourceArtifactId == artifactId) return s;
    }
    return null;
  }

  @override
  Future<WeeklyReviewSignal?> signalById(String signalId) async {
    final box = await _openBox();
    await _ensureSchema(box);
    for (final s in _decodeSignals(box.get(signalsKey))) {
      if (s.signalId == signalId) return s;
    }
    return null;
  }

  @override
  Future<WeeklyReviewRecord> saveDraft(WeeklyReviewRecord draft) async {
    if (draft.status != WeeklyReviewStatus.draft) {
      throw StateError('saveDraft requires draft status');
    }
    final box = await _openBox();
    await _ensureSchema(box);
    final list = _decodeReviews(box.get(reviewsKey));

    for (final existing in list) {
      if (existing.periodId == draft.periodId && existing.isCompleted) {
        return existing;
      }
    }

    var replaced = false;
    for (var i = 0; i < list.length; i++) {
      if (list[i].periodId == draft.periodId && list[i].isDraft) {
        list[i] = draft;
        replaced = true;
        break;
      }
    }
    if (!replaced) {
      list.add(draft);
    }

    await box.put(
      reviewsKey,
      list.map((r) => r.toJson()).toList(growable: false),
    );
    return draft;
  }

  @override
  Future<
      ({
        WeeklyReviewRecord record,
        WeeklyArtifact artifact,
        WeeklyReviewSignal signal
      })> complete({
    required WeeklyReviewRecord record,
    required WeeklyArtifact artifact,
    required WeeklyReviewSignal signal,
  }) async {
    final box = await _openBox();
    await _ensureSchema(box);

    final reviews = _decodeReviews(box.get(reviewsKey));
    for (final existing in reviews) {
      if (existing.periodId == record.periodId && existing.isCompleted) {
        final existingArtifact =
            await artifactByReviewId(existing.id) ?? artifact;
        final existingSignal =
            await signalByArtifactId(existingArtifact.artifactId) ?? signal;
        return (
          record: existing,
          artifact: existingArtifact,
          signal: existingSignal,
        );
      }
    }

    final completed = record.copyWith(
      status: WeeklyReviewStatus.completed,
      summary: artifact.summary,
      artifactId: artifact.artifactId,
      signalId: signal.signalId,
      completedAt: record.completedAt ?? artifact.createdAt,
      updatedAt: artifact.createdAt,
    );

    var replacedDraft = false;
    for (var i = 0; i < reviews.length; i++) {
      if (reviews[i].periodId == completed.periodId) {
        reviews[i] = completed;
        replacedDraft = true;
        break;
      }
    }
    if (!replacedDraft) {
      reviews.add(completed);
    }

    final artifacts = _decodeArtifacts(box.get(artifactsKey));
    if (!artifacts.any((a) => a.artifactId == artifact.artifactId)) {
      artifacts.add(artifact);
    }

    final signals = _decodeSignals(box.get(signalsKey));
    if (!signals.any((s) => s.signalId == signal.signalId)) {
      signals.add(signal);
    }

    await box.put(
      reviewsKey,
      reviews.map((r) => r.toJson()).toList(growable: false),
    );
    await box.put(
      artifactsKey,
      artifacts.map((a) => a.toJson()).toList(growable: false),
    );
    await box.put(
      signalsKey,
      signals.map((s) => s.toJson()).toList(growable: false),
    );
    await box.put(latestCompletedKey, completed.id);

    return (record: completed, artifact: artifact, signal: signal);
  }
}
