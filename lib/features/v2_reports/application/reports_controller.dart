import 'package:flutter/foundation.dart';

import '../../brain_profile/data/brain_profile_repository.dart';
import '../../brain_profile/domain/profile_pack.dart';
import '../../daily_session/data/daily_session_repository.dart';
import '../../daily_session/domain/daily_day_key.dart';
import '../../progress/data/progress_repository.dart';
import '../../progress/domain/progress_engine.dart';
import '../../weekly_review/data/weekly_review_repository.dart';
import '../../weekly_review/domain/weekly_artifact.dart';
import '../domain/domain_history_point.dart';
import '../domain/measurement_history_engine.dart';
import '../domain/reports_archive_gate.dart';
import '../domain/reports_overview.dart';
import '../domain/reports_overview_builder.dart';

enum ReportsPhase {
  loading,
  ready,
  empty,
  snapshotMissing,
  unsupported,
  persistenceFailed,
}

enum ArtifactDetailPhase {
  loading,
  ready,
  missing,
  unsupported,
  corrupt,
  premiumGated,
  invalidAccess,
}

enum MeasurementHistoryPhase {
  loading,
  ready,
  none,
  baselineOnly,
  unsupported,
  persistenceFailed,
}

/// Read-only Reports assembler for RPT-01 / RPT-02 / RPT-03.
class ReportsController extends ChangeNotifier {
  ReportsController({
    required DailySessionRepository sessions,
    required ProgressRepository progress,
    required WeeklyReviewRepository reviews,
    required BrainProfileRepository profiles,
    required bool Function() isPremium,
    SessionClock clock = systemSessionClock,
    Duration? timeZoneOffset,
  })  : _sessions = sessions,
        _progress = progress,
        _reviews = reviews,
        _profiles = profiles,
        _isPremium = isPremium,
        _clock = clock,
        _timeZoneOffset = timeZoneOffset;

  final DailySessionRepository _sessions;
  final ProgressRepository _progress;
  final WeeklyReviewRepository _reviews;
  final BrainProfileRepository _profiles;
  final bool Function() _isPremium;
  final SessionClock _clock;
  final Duration? _timeZoneOffset;

  ReportsPhase phase = ReportsPhase.loading;
  ReportsOverview overview = ReportsOverview.empty(
    dayKey: '1970-01-01',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );

  List<WeeklyArtifact> allArtifactsNewestFirst = const [];
  List<WeeklyArtifact> visibleArtifacts = const [];
  int premiumLockedArtifactCount = 0;

  List<MeasurementHistoryItem> allMeasurements = const [];
  List<MeasurementHistoryItem> visibleMeasurements = const [];
  int premiumLockedMeasurementCount = 0;
  MeasurementComparison comparison = MeasurementComparison.insufficient;
  List<DomainHistoryPoint> domainHistory = const [];
  bool showDomainHistory = false;

  ArtifactDetailPhase artifactPhase = ArtifactDetailPhase.loading;
  WeeklyArtifact? selectedArtifact;

  MeasurementHistoryPhase measurementPhase = MeasurementHistoryPhase.loading;

  String? errorKey;

  bool get isPremium => _isPremium();

  Duration get _offset {
    if (_timeZoneOffset != null) return _timeZoneOffset!;
    return _clock().timeZoneOffset;
  }

  DateTime get _nowLocal {
    final now = _clock();
    if (_timeZoneOffset != null) {
      return now.toUtc().add(_timeZoneOffset!);
    }
    return now.toLocal();
  }

  DateTime get _nowUtc => _clock().toUtc();

  String _dayKeyOfUtc(DateTime utc) =>
      DailyDayKey.fromUtc(utc, timeZoneOffset: _offset);

  Future<void> loadOverview() async {
    phase = ReportsPhase.loading;
    errorKey = null;
    notifyListeners();
    try {
      final history = await _sessions.history();
      final snapshot = await _progress.latest();
      final artifacts = await _reviews.listArtifacts();
      final packs = await _profiles.history();

      final asOf = DailyDayKey.fromLocal(_nowLocal);
      final derived = ProgressEngine.build(
        sessions: history,
        nowUtc: _nowUtc,
        asOfDayKey: asOf,
      );

      // Prefer persisted snapshot stats when present; else in-memory derive (no persist).
      final stats = snapshot?.statistics ?? derived.statistics;
      final summary = snapshot?.summary ?? derived.summary;
      final firstDay = summary.firstCompletedDayKey;
      final lastDay = summary.lastCompletedDayKey;

      final valid = MeasurementHistoryEngine.validNewestFirst(packs);
      final comparable = valid.length >= 2 &&
          MeasurementHistoryEngine.areOverallCompatible(valid[0], valid[1]);
      final incompatibleOnly = valid.length >= 2 && !comparable;

      overview = ReportsOverviewBuilder.build(
        asOfDayKey: asOf,
        nowUtc: _nowUtc,
        snapshot: snapshot,
        stats: stats,
        firstDay: firstDay,
        lastDay: lastDay,
        artifactsNewestFirst: artifacts,
        validMeasurementsNewestFirst: valid,
        hasComparablePair: comparable,
        hasIncompatibleOnly: incompatibleOnly,
      );

      allArtifactsNewestFirst = artifacts;
      final premium = isPremium;
      final visibleCount = ReportsArchiveGate.visibleArtifactCount(
        artifacts.length,
        isPremium: premium,
      );
      visibleArtifacts = artifacts.take(visibleCount).toList(growable: false);
      premiumLockedArtifactCount = artifacts.length - visibleCount;

      allMeasurements = [
        for (final p in valid)
          MeasurementHistoryEngine.toItem(
            p,
            measurementDayKey: _dayKeyOfUtc(p.createdAt),
          ),
      ];
      final visibleM = ReportsArchiveGate.visibleMeasurementCount(
        allMeasurements.length,
        isPremium: premium,
      );
      visibleMeasurements =
          allMeasurements.take(visibleM).toList(growable: false);
      premiumLockedMeasurementCount = allMeasurements.length - visibleM;

      ProfilePack? latest;
      ProfilePack? earlier;
      if (valid.isNotEmpty) latest = valid[0];
      if (valid.length >= 2) earlier = valid[1];
      comparison = MeasurementHistoryEngine.compareOverall(
        latest: latest,
        earlier: earlier,
      );

      if (comparable && valid.length >= 2) {
        final pair = valid.take(2).toList(growable: false);
        showDomainHistory =
            MeasurementHistoryEngine.areDomainSchemasCompatible(
          pair[0],
          pair[1],
        );
        domainHistory = showDomainHistory
            ? MeasurementHistoryEngine.domainHistoryPoints(
                compatibleNewestFirst: pair,
                dayKeyOf: _dayKeyOfUtc,
              )
            : const [];
      } else {
        showDomainHistory = false;
        domainHistory = const [];
      }

      if (overview.completedSessionCount <= 0 &&
          overview.weeklyArtifactCount <= 0 &&
          overview.validMeasurementCount <= 0) {
        phase = ReportsPhase.empty;
      } else if (overview.snapshotMissing) {
        phase = ReportsPhase.snapshotMissing;
      } else {
        phase = ReportsPhase.ready;
      }
      notifyListeners();
    } on FormatException catch (e) {
      debugPrint('ReportsController.loadOverview unsupported: $e');
      phase = ReportsPhase.unsupported;
      errorKey = 'unsupported';
      notifyListeners();
    } catch (e) {
      debugPrint('ReportsController.loadOverview failed: $e');
      phase = ReportsPhase.persistenceFailed;
      errorKey = 'persist';
      notifyListeners();
    }
  }

  Future<void> loadArtifact(String? artifactId) async {
    artifactPhase = ArtifactDetailPhase.loading;
    selectedArtifact = null;
    errorKey = null;
    notifyListeners();

    if (artifactId == null || artifactId.isEmpty) {
      artifactPhase = ArtifactDetailPhase.invalidAccess;
      notifyListeners();
      return;
    }

    try {
      if (allArtifactsNewestFirst.isEmpty) {
        allArtifactsNewestFirst = await _reviews.listArtifacts();
      }
      final index =
          allArtifactsNewestFirst.indexWhere((a) => a.artifactId == artifactId);
      if (index < 0) {
        // May still exist but not in list — try direct fetch
        try {
          final art = await _reviews.artifactById(artifactId);
          if (art == null) {
            artifactPhase = ArtifactDetailPhase.missing;
            notifyListeners();
            return;
          }
          // Rebuild list index for gate using full list
          allArtifactsNewestFirst = await _reviews.listArtifacts();
          final idx = allArtifactsNewestFirst
              .indexWhere((a) => a.artifactId == artifactId);
          if (idx >= 0 &&
              !ReportsArchiveGate.canAccessArtifactIndex(
                idx,
                isPremium: isPremium,
              )) {
            artifactPhase = ArtifactDetailPhase.premiumGated;
            notifyListeners();
            return;
          }
          selectedArtifact = art;
          artifactPhase = ArtifactDetailPhase.ready;
          notifyListeners();
          return;
        } on FormatException {
          artifactPhase = ArtifactDetailPhase.unsupported;
          notifyListeners();
          return;
        }
      }

      if (!ReportsArchiveGate.canAccessArtifactIndex(
        index,
        isPremium: isPremium,
      )) {
        artifactPhase = ArtifactDetailPhase.premiumGated;
        notifyListeners();
        return;
      }

      selectedArtifact = allArtifactsNewestFirst[index];
      artifactPhase = ArtifactDetailPhase.ready;
      notifyListeners();
    } on FormatException catch (e) {
      debugPrint('ReportsController.loadArtifact unsupported: $e');
      artifactPhase = ArtifactDetailPhase.unsupported;
      errorKey = 'unsupported';
      notifyListeners();
    } catch (e) {
      debugPrint('ReportsController.loadArtifact failed: $e');
      artifactPhase = ArtifactDetailPhase.corrupt;
      errorKey = 'corrupt';
      notifyListeners();
    }
  }

  Future<void> loadMeasurements() async {
    measurementPhase = MeasurementHistoryPhase.loading;
    errorKey = null;
    notifyListeners();
    try {
      if (allMeasurements.isEmpty) {
        await loadOverview();
      }
      if (allMeasurements.isEmpty) {
        measurementPhase = MeasurementHistoryPhase.none;
      } else if (allMeasurements.length == 1) {
        measurementPhase = MeasurementHistoryPhase.baselineOnly;
      } else {
        measurementPhase = MeasurementHistoryPhase.ready;
      }
      notifyListeners();
    } on FormatException catch (e) {
      debugPrint('ReportsController.loadMeasurements unsupported: $e');
      measurementPhase = MeasurementHistoryPhase.unsupported;
      errorKey = 'unsupported';
      notifyListeners();
    } catch (e) {
      debugPrint('ReportsController.loadMeasurements failed: $e');
      measurementPhase = MeasurementHistoryPhase.persistenceFailed;
      errorKey = 'persist';
      notifyListeners();
    }
  }
}
