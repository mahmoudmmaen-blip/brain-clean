import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/cloud_sync_service.dart';
import '../../daily_program/application/daily_program_provider.dart';
import '../../daily_program/domain/daily_step.dart';
import '../../daily_program/domain/daily_step_status.dart';
import '../data/emotion_log_repository.dart';
import '../domain/emotion_log_entry.dart';
import '../domain/emotion_model.dart';

part 'emotion_provider.g.dart';

/// Mood gate selection before category chips.
enum EmotionMoodGate { negative, neutral, positive }

/// Armed only when Emotion Wheel is opened from Daily Program mood step.
@Riverpod(keepAlive: true)
class EmotionWheelDailyProgramGate extends _$EmotionWheelDailyProgramGate {
  @override
  bool build() => false;

  void arm() => state = true;

  void disarm() => state = false;

  /// Returns whether the gate was armed, then clears it.
  bool consume() {
    final armed = state;
    state = false;
    return armed;
  }
}

class EmotionState {
  const EmotionState({
    this.moodGate,
    this.selectedCategory,
    this.selectedEmotion,
    this.pendingImpact = 0,
    this.isAwaitingConfirmation = false,
  });

  final EmotionMoodGate? moodGate;
  final EmotionCategory? selectedCategory;
  final EmotionModel? selectedEmotion;

  /// Legacy field kept for state shape; emotions no longer modify recovery %.
  final double pendingImpact;
  final bool isAwaitingConfirmation;

  EmotionState copyWith({
    EmotionMoodGate? moodGate,
    EmotionCategory? selectedCategory,
    EmotionModel? selectedEmotion,
    double? pendingImpact,
    bool? isAwaitingConfirmation,
    bool clearCategory = false,
    bool clearEmotion = false,
    bool clearMoodGate = false,
  }) {
    return EmotionState(
      moodGate: clearMoodGate ? null : (moodGate ?? this.moodGate),
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedEmotion:
          clearEmotion ? null : (selectedEmotion ?? this.selectedEmotion),
      pendingImpact: pendingImpact ?? this.pendingImpact,
      isAwaitingConfirmation:
          isAwaitingConfirmation ?? this.isAwaitingConfirmation,
    );
  }

  static const initial = EmotionState();
}

@Riverpod(keepAlive: true)
class EmotionNotifier extends _$EmotionNotifier {
  @override
  EmotionState build() => EmotionState.initial;

  void selectMoodGate(EmotionMoodGate gate) {
    state = EmotionState.initial.copyWith(
      moodGate: gate,
      clearCategory: true,
      clearEmotion: true,
    );
  }

  void selectCategory(EmotionCategory category) {
    state = state.copyWith(
      selectedCategory: category,
      clearEmotion: true,
      pendingImpact: 0,
      isAwaitingConfirmation: false,
    );
  }

  void selectEmotion(EmotionModel emotion) {
    state = state.copyWith(
      selectedEmotion: emotion,
      pendingImpact: 0,
      isAwaitingConfirmation: true,
    );
  }

  /// Logs the selected emotion as a check-in (no recovery % change).
  Future<void> confirmImpact() async {
    final emotion = state.selectedEmotion;
    if (emotion == null) return;

    try {
      final timestamp = DateTime.now();
      await ref.read(emotionLogRepositoryProvider).append(
            emotion: emotion,
            appliedImpact: 0,
            timestamp: timestamp,
          );
      await ref.read(cloudSyncServiceProvider).syncEmotionLog(
            EmotionLogEntry.fromEmotion(
              emotion: emotion,
              appliedImpact: 0,
              timestamp: timestamp,
            ),
          );
    } catch (_) {
      // Logging is best-effort.
    }

    await _completeDailyMoodStepIfOpenedFromDailyProgram();

    state = EmotionState.initial;
  }

  Future<void> _completeDailyMoodStepIfOpenedFromDailyProgram() async {
    try {
      final fromDailyProgram =
          ref.read(emotionWheelDailyProgramGateProvider.notifier).consume();
      if (!fromDailyProgram) return;

      final program = ref.read(dailyProgramProvider).valueOrNull;
      final current = program?.currentStep;
      if (current == null || current.step != DailyStep.mood) return;
      if (current.status != DailyStepStatus.current) return;
      await ref.read(dailyProgramProvider.notifier).completeStep(DailyStep.mood);
    } catch (_) {
      // Daily Program sync is best-effort.
    }
  }

  void rejectImpact() {
    ref.read(emotionWheelDailyProgramGateProvider.notifier).disarm();
    state = EmotionState.initial;
  }

  void resetMoodGate() {
    state = EmotionState.initial;
  }

  void backToCategories() {
    state = state.copyWith(
      clearCategory: true,
      clearEmotion: true,
      pendingImpact: 0,
      isAwaitingConfirmation: false,
    );
  }
}

/// Filtered categories for the current mood gate.
@riverpod
List<EmotionCategory> filteredEmotionCategories(
  FilteredEmotionCategoriesRef ref,
) {
  final mood = ref.watch(emotionNotifierProvider).moodGate;
  return switch (mood) {
    EmotionMoodGate.negative => EmotionModel.negativeMoodCategories,
    EmotionMoodGate.neutral => EmotionModel.neutralMoodCategories,
    EmotionMoodGate.positive => EmotionModel.positiveMoodCategories,
    null => const [],
  };
}
