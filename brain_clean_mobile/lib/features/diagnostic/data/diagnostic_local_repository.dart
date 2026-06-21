import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/brain_rot_questionnaire_snapshot.dart';
import '../domain/bhi_pillar_json_keys.dart';
import '../domain/diagnostic_metrics.dart';
import '../domain/diagnostic_session.dart';

/// Local-first bundle restored on every cold start.
class DiagnosticLocalBundle {
  const DiagnosticLocalBundle({
    this.committedSession,
    this.metrics,
    this.questionnaire,
  });

  final DiagnosticSession? committedSession;
  final DiagnosticMetrics? metrics;
  final BrainRotQuestionnaireSnapshot? questionnaire;

  bool get hasDraftProgress =>
      metrics != null ||
      (questionnaire != null && questionnaire!.answeredCount > 0);
}

/// Hive persistence for committed sessions and live diagnostic drafts.
class DiagnosticLocalRepository {
  DiagnosticLocalRepository({Box<dynamic>? box}) : _boxOverride = box;

  static const _committedKey = 'committed_session';
  static const _metricsKey = 'draft_metrics';
  static const _questionnaireKey = 'draft_questionnaire';

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.diagnosticPersistence);
  }

  Future<DiagnosticLocalBundle> loadBundle() async {
    try {
      final box = await _openBox();
      return DiagnosticLocalBundle(
        committedSession: _parseSession(box.get(_committedKey)),
        metrics: _parseMetrics(box.get(_metricsKey)),
        questionnaire: _parseQuestionnaire(box.get(_questionnaireKey)),
      );
    } catch (e) {
      debugPrint('DiagnosticLocalRepository: load failed: $e');
      return const DiagnosticLocalBundle();
    }
  }

  Future<void> saveCommittedSession(DiagnosticSession session) async {
    try {
      session.ensureDiagnosticCoherence();
      final box = await _openBox();
      await box.put(_committedKey, session.toJson());
    } catch (e) {
      debugPrint('DiagnosticLocalRepository: save session failed: $e');
    }
  }

  Future<void> clearCommittedSession() async {
    try {
      final box = await _openBox();
      await box.delete(_committedKey);
    } catch (e) {
      debugPrint('DiagnosticLocalRepository: clear session failed: $e');
    }
  }

  Future<void> saveDraft({
    DiagnosticMetrics? metrics,
    BrainRotQuestionnaireSnapshot? questionnaire,
  }) async {
    try {
      final box = await _openBox();
      if (metrics != null) {
        await box.put(_metricsKey, metrics.toJson());
      }
      if (questionnaire != null) {
        await box.put(_questionnaireKey, questionnaire.toJson());
      }
    } catch (e) {
      debugPrint('DiagnosticLocalRepository: save draft failed: $e');
    }
  }

  Future<void> clearDraft() async {
    try {
      final box = await _openBox();
      await box.delete(_metricsKey);
      await box.delete(_questionnaireKey);
    } catch (e) {
      debugPrint('DiagnosticLocalRepository: clear draft failed: $e');
    }
  }

  DiagnosticSession? _parseSession(Object? raw) {
    if (raw is! Map) return null;
    try {
      return DiagnosticSession.fromJson(
        BhiPillarJsonKeys.normalizeIncoming(
          BhiPillarJsonKeys.decodeHiveMap(Map<dynamic, dynamic>.from(raw)),
        ),
      );
    } catch (e) {
      debugPrint('DiagnosticLocalRepository: corrupt session: $e');
      return null;
    }
  }

  DiagnosticMetrics? _parseMetrics(Object? raw) {
    if (raw is! Map) return null;
    try {
      return DiagnosticMetrics.fromJson(
        BhiPillarJsonKeys.normalizeIncoming(
          BhiPillarJsonKeys.decodeHiveMap(Map<dynamic, dynamic>.from(raw)),
        ),
      );
    } catch (e) {
      debugPrint('DiagnosticLocalRepository: corrupt metrics: $e');
      return null;
    }
  }

  BrainRotQuestionnaireSnapshot? _parseQuestionnaire(Object? raw) {
    if (raw is! Map) return null;
    try {
      return BrainRotQuestionnaireSnapshot.fromJson(
        BhiPillarJsonKeys.normalizeIncoming(
          BhiPillarJsonKeys.decodeHiveMap(Map<dynamic, dynamic>.from(raw)),
        ),
      );
    } catch (e) {
      debugPrint('DiagnosticLocalRepository: corrupt questionnaire: $e');
      return null;
    }
  }
}
