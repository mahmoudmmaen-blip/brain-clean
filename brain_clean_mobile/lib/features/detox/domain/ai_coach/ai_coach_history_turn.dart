/// A single turn in the AI coach conversation history (Dynamic Layer).
class AiCoachHistoryTurn {
  const AiCoachHistoryTurn({
    required this.role,
    required this.content,
  });

  final String role;
  final String content;

  Map<String, String> toJson() => {
        'role': role,
        'content': content,
      };
}
