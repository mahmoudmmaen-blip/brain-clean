import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../daily_session/domain/daily_day_key.dart';
import '../../daily_session/domain/daily_session.dart';
import '../../daily_session/domain/daily_session_path.dart';
import '../../daily_session/domain/daily_session_status.dart';
import '../../daily_session/domain/daily_session_step_state.dart';
import 'progress_snapshot.dart';
import 'progress_statistics.dart';
import 'progress_summary.dart';
import 'progress_timeline.dart';
import 'progress_version.dart';

/// Pure deterministic Progress builder — reads sessions only; invents nothing.
abstract final class ProgressEngine {
  /// Sessions that contribute to progress (full completion marks).
  static List<DailySession> completedSessions(Iterable<DailySession> raw) {
    final out = <DailySession>[];
    for (final s in raw) {
      if (_isProgressSession(s)) out.add(s);
    }
    out.sort((a, b) {
      final byDay = a.dayKey.compareTo(b.dayKey);
      if (byDay != 0) return byDay;
      final aAt = a.completedAt ?? a.updatedAt;
      final bAt = b.completedAt ?? b.updatedAt;
      return aAt.compareTo(bAt);
    });
    return out;
  }

  static bool _isProgressSession(DailySession s) {
    if (s.mark == null) return false;
    if (s.status == DailySessionStatus.completed) return true;
    return s.mark!.fullCompletion;
  }

  /// Builds a snapshot from completed DailySession history only.
  static ProgressSnapshot build({
    required List<DailySession> sessions,
    required DateTime nowUtc,
    required String asOfDayKey,
    String? activePlanId,
    String? profilePackId,
    String? recoveryScoreModelVersion,
  }) {
    final completed = completedSessions(sessions);
    if (completed.isEmpty) {
      final empty = ProgressSnapshot(
        id: _idFor(asOfDayKey, 'empty'),
        createdAt: nowUtc.toUtc(),
        asOfDayKey: asOfDayKey,
        statistics: ProgressStatistics.empty,
        timeline: ProgressTimeline.empty,
        summary: ProgressSummary(
          hasHistory: false,
          firstCompletedSessionId: null,
          lastCompletedSessionId: null,
          firstCompletedDayKey: null,
          lastCompletedDayKey: null,
          activePlanId: activePlanId,
          profilePackId: profilePackId,
          recoveryScoreModelVersion: recoveryScoreModelVersion,
        ),
        schemaVersion: ProgressVersion.schema,
        contentHash: _hashPayload(<String, dynamic>{
          'empty': true,
          'asOfDayKey': asOfDayKey,
          'activePlanId': activePlanId,
          'profilePackId': profilePackId,
        }),
      );
      return empty;
    }

    final byDay = <String, List<DailySession>>{};
    for (final s in completed) {
      byDay.putIfAbsent(s.dayKey, () => <DailySession>[]).add(s);
    }
    final dayKeys = byDay.keys.toList()..sort();

    var minimumPathCount = 0;
    var standardPathCount = 0;
    var skippedOptionalSteps = 0;
    var requiredStepsCompleted = 0;
    final timelineEntries = <ProgressTimelineEntry>[];

    for (final day in dayKeys) {
      final daySessions = byDay[day]!;
      var dayMin = false;
      var dayStd = false;
      var daySkip = 0;
      var dayReq = 0;
      final ids = <String>[];
      var fulls = 0;
      for (final s in daySessions) {
        ids.add(s.id);
        fulls += 1;
        final path = s.mark?.path ?? s.path;
        if (path == DailySessionPath.minimum) {
          minimumPathCount += 1;
          dayMin = true;
        } else {
          standardPathCount += 1;
          dayStd = true;
        }
        for (final step in s.steps) {
          if (step.phase == DailySessionStepPhase.skipped && step.optional) {
            skippedOptionalSteps += 1;
            daySkip += 1;
          }
          if (!step.optional &&
              step.phase == DailySessionStepPhase.completed) {
            requiredStepsCompleted += 1;
            dayReq += 1;
          }
        }
      }
      timelineEntries.add(
        ProgressTimelineEntry(
          dayKey: day,
          sessionIds: List<String>.unmodifiable(ids),
          fullCompletions: fulls,
          usedMinimumPath: dayMin,
          usedStandardPath: dayStd,
          skippedOptionalSteps: daySkip,
          requiredStepsCompleted: dayReq,
        ),
      );
    }

    final first = completed.first;
    final last = completed.last;
    final completedDays = dayKeys.length;
    final spanDays = _inclusiveDaySpan(dayKeys.first, dayKeys.last);
    final completionRate =
        spanDays <= 0 ? 0.0 : (completedDays / spanDays).clamp(0.0, 1.0);

    final longest = _longestStreak(dayKeys);
    final current = _currentStreak(dayKeys, asOfDayKey);

    final stats = ProgressStatistics(
      totalSessions: completed.length,
      minimumPathCount: minimumPathCount,
      standardPathCount: standardPathCount,
      completedDays: completedDays,
      skippedOptionalSteps: skippedOptionalSteps,
      requiredStepsCompleted: requiredStepsCompleted,
      completionRate: completionRate,
      currentStreak: current,
      longestStreak: longest,
    );

    final summary = ProgressSummary(
      hasHistory: true,
      firstCompletedSessionId: first.id,
      lastCompletedSessionId: last.id,
      firstCompletedDayKey: first.dayKey,
      lastCompletedDayKey: last.dayKey,
      activePlanId: activePlanId ?? last.planId,
      profilePackId: profilePackId ?? last.source.profilePackId,
      recoveryScoreModelVersion: recoveryScoreModelVersion,
    );

    final timeline = ProgressTimeline(
      entries: List.unmodifiable(timelineEntries),
    );

    final payload = <String, dynamic>{
      'asOfDayKey': asOfDayKey,
      'statistics': stats.toJson(),
      'timeline': timeline.toJson(),
      'summary': summary.toJson(),
    };
    final hash = _hashPayload(payload);

    return ProgressSnapshot(
      id: _idFor(asOfDayKey, hash),
      createdAt: nowUtc.toUtc(),
      asOfDayKey: asOfDayKey,
      statistics: stats,
      timeline: timeline,
      summary: summary,
      schemaVersion: ProgressVersion.schema,
      contentHash: hash,
    );
  }

  static String _idFor(String dayKey, String hashPrefix) {
    final short =
        hashPrefix.length > 12 ? hashPrefix.substring(0, 12) : hashPrefix;
    return 'psnap_${dayKey}_$short';
  }

  static String _hashPayload(Map<String, dynamic> payload) {
    final encoded = jsonEncode(payload);
    return sha256.convert(utf8.encode(encoded)).toString();
  }

  static int _inclusiveDaySpan(String first, String last) {
    final a = _parseDay(first);
    final b = _parseDay(last);
    if (a == null || b == null) return 0;
    return b.difference(a).inDays + 1;
  }

  static DateTime? _parseDay(String dayKey) {
    final parts = dayKey.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime.utc(y, m, d);
  }

  static String? _shiftDay(String dayKey, int deltaDays) {
    final d = _parseDay(dayKey);
    if (d == null) return null;
    return DailyDayKey.fromLocal(d.add(Duration(days: deltaDays)));
  }

  static int _longestStreak(List<String> sortedAscending) {
    if (sortedAscending.isEmpty) return 0;
    var best = 1;
    var run = 1;
    for (var i = 1; i < sortedAscending.length; i++) {
      final prev = sortedAscending[i - 1];
      final cur = sortedAscending[i];
      final expected = _shiftDay(prev, 1);
      if (expected == cur) {
        run += 1;
        if (run > best) best = run;
      } else if (cur != prev) {
        run = 1;
      }
    }
    return best;
  }

  /// Streak counts consecutive completed days ending at [asOfDayKey]
  /// or the previous day (grace if today not yet completed).
  static int _currentStreak(List<String> sortedAscending, String asOfDayKey) {
    if (sortedAscending.isEmpty) return 0;
    final set = sortedAscending.toSet();
    String? cursor = asOfDayKey;
    if (!set.contains(cursor)) {
      cursor = _shiftDay(asOfDayKey, -1);
    }
    if (cursor == null || !set.contains(cursor)) return 0;
    var streak = 0;
    while (cursor != null && set.contains(cursor)) {
      streak += 1;
      cursor = _shiftDay(cursor, -1);
    }
    return streak;
  }
}
