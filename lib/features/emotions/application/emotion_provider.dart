import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../gamification/application/verified_xp_provider.dart';
import '../../gamification/domain/xp_source.dart';
import '../data/emotion_log_repository.dart';
import '../domain/emotion_log_entry.dart';
import '../domain/emotion_model.dart';
import 'emotion_notification_service.dart';
import '../../../core/services/cloud_sync_service.dart';
import '../../../core/application/app_preferences_provider.dart';

part 'emotion_provider.g.dart';

/// XP credited when the user logs any emotion (self-awareness).
const emotionLogSelfAwarenessXp = 5;

/// Mood gate selection before category chips.
enum EmotionMoodGate { negative, neutral, positive }

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
      pendingImpact: emotion.recoveryImpact,
      isAwaitingConfirmation: true,
    );
  }

  Future<void> confirmImpact({
    void Function()? onLogged,
  }) async {
    final emotion = state.selectedEmotion;
    if (emotion == null) return;

    const impact = 0.0;

    try {
      final timestamp = DateTime.now();
      await ref.read(emotionLogRepositoryProvider).append(
            emotion: emotion,
            appliedImpact: impact,
            timestamp: timestamp,
          );
      await ref.read(cloudSyncServiceProvider).syncEmotionLog(
            EmotionLogEntry.fromEmotion(
              emotion: emotion,
              appliedImpact: impact,
              timestamp: timestamp,
            ),
          );
      ref.read(verifiedTotalXpProvider.notifier).award(
            source: XpSource.other,
            amount: emotionLogSelfAwarenessXp,
            refId: 'emotion_${timestamp.millisecondsSinceEpoch}',
          );
    } catch (_) {
      // Logging is best-effort.
    }

    onLogged?.call();
    state = EmotionState.initial;
  }

  void rejectImpact() {
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
