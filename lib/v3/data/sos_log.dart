class SosLog {
  const SosLog({
    required this.at,
    required this.flowId,
    this.before,
    this.after,
  });

  final DateTime at;
  final String flowId;
  final int? before;
  final int? after;

  Map<String, dynamic> toJson() => {
        'at': at.toIso8601String(),
        'flowId': flowId,
        'before': before,
        'after': after,
      };

  factory SosLog.fromJson(Map<String, dynamic> json) {
    return SosLog(
      at: DateTime.parse(json['at'] as String),
      flowId: json['flowId'] as String,
      before: (json['before'] as num?)?.toInt(),
      after: (json['after'] as num?)?.toInt(),
    );
  }
}
