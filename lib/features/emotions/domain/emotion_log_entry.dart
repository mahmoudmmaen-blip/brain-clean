import 'emotion_model.dart';

/// Emotion log row for Hive + cloud sync.
class EmotionLogEntry {
  const EmotionLogEntry({
    required this.label,
    required this.category,
    required this.recoveryImpact,
    required this.timestamp,
  });

  final String label;
  final String category;
  final double recoveryImpact;
  final DateTime timestamp;

  factory EmotionLogEntry.fromEmotion({
    required EmotionModel emotion,
    required double appliedImpact,
    required DateTime timestamp,
  }) =>
      EmotionLogEntry(
        label: emotion.label,
        category: emotion.category.name,
        recoveryImpact: appliedImpact,
        timestamp: timestamp,
      );
}
