class FocusLog {
  const FocusLog({
    required this.at,
    required this.minutes,
    required this.completed,
  });

  final DateTime at;
  final int minutes;
  final bool completed;

  Map<String, dynamic> toJson() => {
        'at': at.toIso8601String(),
        'minutes': minutes,
        'completed': completed,
      };

  factory FocusLog.fromJson(Map<String, dynamic> json) {
    return FocusLog(
      at: DateTime.parse(json['at'] as String),
      minutes: (json['minutes'] as num).toInt(),
      completed: json['completed'] as bool? ?? false,
    );
  }
}
