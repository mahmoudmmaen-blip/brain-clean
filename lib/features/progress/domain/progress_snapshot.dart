import 'progress_statistics.dart';
import 'progress_summary.dart';
import 'progress_timeline.dart';
import 'progress_version.dart';

/// Immutable computed progress snapshot (append-only history).
class ProgressSnapshot {
  const ProgressSnapshot({
    required this.id,
    required this.createdAt,
    required this.asOfDayKey,
    required this.statistics,
    required this.timeline,
    required this.summary,
    required this.schemaVersion,
    required this.contentHash,
  });

  final String id;
  final DateTime createdAt;
  final String asOfDayKey;
  final ProgressStatistics statistics;
  final ProgressTimeline timeline;
  final ProgressSummary summary;
  final String schemaVersion;
  final String contentHash;

  bool get isEmpty => !summary.hasHistory;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'asOfDayKey': asOfDayKey,
        'statistics': statistics.toJson(),
        'timeline': timeline.toJson(),
        'summary': summary.toJson(),
        'schemaVersion': schemaVersion,
        'contentHash': contentHash,
      };

  factory ProgressSnapshot.fromJson(Map<String, dynamic> json) {
    final schema = json['schemaVersion'] as String?;
    if (schema != null && schema != ProgressVersion.schema) {
      throw FormatException('unsupported_progress_schema:$schema');
    }
    final id = json['id'] as String? ?? '';
    final contentHash = json['contentHash'] as String? ?? '';
    final asOfDayKey = json['asOfDayKey'] as String? ?? '';
    if (id.isEmpty || contentHash.isEmpty || asOfDayKey.isEmpty) {
      throw const FormatException('corrupt_progress_snapshot');
    }
    if (json['statistics'] is! Map ||
        json['timeline'] is! Map ||
        json['summary'] is! Map) {
      throw const FormatException('corrupt_progress_snapshot_shape');
    }
    return ProgressSnapshot(
      id: id,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')
              ?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      asOfDayKey: asOfDayKey,
      statistics: ProgressStatistics.fromJson(
        Map<String, dynamic>.from(json['statistics'] as Map),
      ),
      timeline: ProgressTimeline.fromJson(
        Map<String, dynamic>.from(json['timeline'] as Map),
      ),
      summary: ProgressSummary.fromJson(
        Map<String, dynamic>.from(json['summary'] as Map),
      ),
      schemaVersion: schema ?? ProgressVersion.schema,
      contentHash: contentHash,
    );
  }
}
