import 'weekly_period.dart';
import 'weekly_review_enums.dart';
import 'weekly_review_response.dart';
import 'weekly_review_source_reference.dart';
import 'weekly_review_summary.dart';
import 'weekly_review_version.dart';

/// Mutable draft or immutable completed weekly review record.
class WeeklyReviewRecord {
  const WeeklyReviewRecord({
    required this.id,
    required this.periodId,
    required this.periodStartDayKey,
    required this.periodEndDayKey,
    required this.timezoneOffsetMinutes,
    required this.status,
    required this.questionIndex,
    required this.responses,
    required this.source,
    required this.completedSessionIds,
    required this.createdAt,
    required this.updatedAt,
    required this.schemaVersion,
    required this.reviewModelVersion,
    this.summary,
    this.artifactId,
    this.signalId,
    this.completedAt,
  });

  final String id;
  final String periodId;
  final String periodStartDayKey;
  final String periodEndDayKey;
  final int timezoneOffsetMinutes;
  final WeeklyReviewStatus status;
  final int questionIndex;
  final List<WeeklyReviewResponse> responses;
  final WeeklyReviewSourceReference source;
  final List<String> completedSessionIds;
  final WeeklyReviewSummary? summary;
  final String? artifactId;
  final String? signalId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String schemaVersion;
  final String reviewModelVersion;

  bool get isCompleted => status == WeeklyReviewStatus.completed;
  bool get isDraft => status == WeeklyReviewStatus.draft;

  Map<String, WeeklyReviewResponse> get responsesById {
    final map = <String, WeeklyReviewResponse>{};
    for (final r in responses) {
      map[r.questionId] = r;
    }
    return map;
  }

  static String draftIdFor(String periodId) => 'wrev_$periodId';

  factory WeeklyReviewRecord.draft({
    required WeeklyPeriod period,
    required WeeklyReviewSourceReference source,
    required List<String> completedSessionIds,
    required DateTime nowUtc,
  }) {
    return WeeklyReviewRecord(
      id: draftIdFor(period.periodId),
      periodId: period.periodId,
      periodStartDayKey: period.startDayKey,
      periodEndDayKey: period.endDayKey,
      timezoneOffsetMinutes: period.timezoneOffsetMinutes,
      status: WeeklyReviewStatus.draft,
      questionIndex: 0,
      responses: const [],
      source: source,
      completedSessionIds: List<String>.from(completedSessionIds),
      createdAt: nowUtc.toUtc(),
      updatedAt: nowUtc.toUtc(),
      schemaVersion: WeeklyReviewVersion.schema,
      reviewModelVersion: WeeklyReviewVersion.reviewModel,
    );
  }

  WeeklyReviewRecord copyWith({
    WeeklyReviewStatus? status,
    int? questionIndex,
    List<WeeklyReviewResponse>? responses,
    WeeklyReviewSourceReference? source,
    List<String>? completedSessionIds,
    WeeklyReviewSummary? summary,
    String? artifactId,
    String? signalId,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearSummary = false,
  }) {
    return WeeklyReviewRecord(
      id: id,
      periodId: periodId,
      periodStartDayKey: periodStartDayKey,
      periodEndDayKey: periodEndDayKey,
      timezoneOffsetMinutes: timezoneOffsetMinutes,
      status: status ?? this.status,
      questionIndex: questionIndex ?? this.questionIndex,
      responses: responses ?? this.responses,
      source: source ?? this.source,
      completedSessionIds: completedSessionIds ?? this.completedSessionIds,
      summary: clearSummary ? null : (summary ?? this.summary),
      artifactId: artifactId ?? this.artifactId,
      signalId: signalId ?? this.signalId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      schemaVersion: schemaVersion,
      reviewModelVersion: reviewModelVersion,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'periodId': periodId,
        'periodStartDayKey': periodStartDayKey,
        'periodEndDayKey': periodEndDayKey,
        'timezoneOffsetMinutes': timezoneOffsetMinutes,
        'status': status.wireName,
        'questionIndex': questionIndex,
        'responses': responses.map((r) => r.toJson()).toList(growable: false),
        'source': source.toJson(),
        'completedSessionIds': completedSessionIds,
        if (summary != null) 'summary': summary!.toJson(),
        if (artifactId != null) 'artifactId': artifactId,
        if (signalId != null) 'signalId': signalId,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        if (completedAt != null)
          'completedAt': completedAt!.toUtc().toIso8601String(),
        'schemaVersion': schemaVersion,
        'reviewModelVersion': reviewModelVersion,
      };

  factory WeeklyReviewRecord.fromJson(Map<String, dynamic> json) {
    final schema = json['schemaVersion'] as String?;
    if (schema != null && schema != WeeklyReviewVersion.schema) {
      throw FormatException('Unsupported weekly review schema: $schema');
    }
    return WeeklyReviewRecord(
      id: json['id'] as String,
      periodId: json['periodId'] as String,
      periodStartDayKey: json['periodStartDayKey'] as String,
      periodEndDayKey: json['periodEndDayKey'] as String,
      timezoneOffsetMinutes: json['timezoneOffsetMinutes'] as int,
      status: WeeklyReviewStatusX.fromWire(json['status'] as String?),
      questionIndex: json['questionIndex'] as int? ?? 0,
      responses: (json['responses'] as List? ?? const [])
          .map((e) => WeeklyReviewResponse.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(growable: false),
      source: WeeklyReviewSourceReference.fromJson(
        Map<String, dynamic>.from(json['source'] as Map),
      ),
      completedSessionIds: (json['completedSessionIds'] as List? ?? const [])
          .map((e) => e as String)
          .toList(growable: false),
      summary: json['summary'] is Map
          ? WeeklyReviewSummary.fromJson(
              Map<String, dynamic>.from(json['summary'] as Map),
            )
          : null,
      artifactId: json['artifactId'] as String?,
      signalId: json['signalId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String).toUtc()
          : null,
      schemaVersion: schema ?? WeeklyReviewVersion.schema,
      reviewModelVersion: json['reviewModelVersion'] as String? ??
          WeeklyReviewVersion.reviewModel,
    );
  }
}
