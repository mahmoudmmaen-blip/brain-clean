/// Ordered steps of the daily hybrid journey.
enum DailyStep {
  dayStart,
  water,
  movement,
  sukoon,
  mood,
  journal,
  dayEnd,
}

extension DailyStepX on DailyStep {
  bool get isOptional => this == DailyStep.journal;

  int get indexInJourney => DailyStep.values.indexOf(this);
}
