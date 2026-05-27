import 'ai_coach_history_turn.dart';

/// Per-request context injected into the Dynamic Layer.
class AiCoachDynamicContext {
  const AiCoachDynamicContext({
    required this.userMessage,
    this.locale = 'ar',
    this.bcScore,
    this.streakDays,
    this.history = const [],
    this.variables = const {},
    this.timestamp,
  });

  final String userMessage;
  final String locale;
  final double? bcScore;
  final int? streakDays;
  final List<AiCoachHistoryTurn> history;
  final Map<String, Object?> variables;
  final DateTime? timestamp;

  Map<String, Object?> toJson() => {
        'userMessage': userMessage,
        'locale': locale,
        'bcScore': bcScore,
        'streakDays': streakDays,
        'history': history.map((h) => h.toJson()).toList(),
        'variables': variables,
        'timestamp': (timestamp ?? DateTime.now().toUtc()).toIso8601String(),
      };
}
