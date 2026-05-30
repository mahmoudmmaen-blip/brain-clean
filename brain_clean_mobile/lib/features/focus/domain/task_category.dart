/// Single-task category — affects recovery BCS bonus on completion.
enum TaskCategory {
  mental,
  physical,
  creative,
  educational,
  household,
}

/// Base BCS bonus before difficulty multiplier.
double taskCategoryBaseBonus(TaskCategory category) {
  switch (category) {
    case TaskCategory.mental:
      return 8.0;
    case TaskCategory.educational:
      return 7.0;
    case TaskCategory.creative:
      return 6.0;
    case TaskCategory.physical:
      return 5.0;
    case TaskCategory.household:
      return 3.0;
  }
}

/// Multiplier for difficulty stars (1–3).
double taskDifficultyMultiplier(int stars) {
  switch (stars) {
    case 2:
      return 1.5;
    case 3:
      return 2.0;
    default:
      return 1.0;
  }
}

/// Total bonus for completing a task.
double taskCompletionBonus(TaskCategory category, int difficultyStars) =>
    taskCategoryBaseBonus(category) *
    taskDifficultyMultiplier(difficultyStars);

/// Penalty applied when abandoning an active task.
const double taskAbandonPenalty = 5.0;
