import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../diagnostic/presentation/bc_score_provider.dart';
import '../data/emotion_log_repository.dart';
import '../domain/emotion_log_entry.dart';
import '../domain/emotion_model.dart';
import 'emotion_notification_service.dart';
import '../../../core/services/cloud_sync_service.dart';
import '../../../core/application/app_preferences_provider.dart';

part 'emotion_provider.g.dart';

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

  Future<void> confirmImpact() async {
    final emotion = state.selectedEmotion;
    final impact = state.pendingImpact;
    if (emotion == null) return;

    final sessionBefore = ref.read(bcScoreSessionProvider);
    final previousBcs = sessionBefore?.bcScoreRounded ?? 0;

    ref.read(bcScoreProvider.notifier).applyEmotionImpact(impact);

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
    } catch (_) {
      // Logging is best-effort; BCS update remains authoritative.
    }

    final sessionAfter = ref.read(bcScoreSessionProvider);
    final newBcs = sessionAfter?.bcScoreRounded ?? previousBcs;
    if (sessionAfter != null && newBcs < previousBcs) {
      final notificationsOn =
          ref.read(appPreferencesProvider).emotionNotificationsEnabled;
      if (notificationsOn) {
        await ref
            .read(emotionNotificationServiceProvider)
            .showRecoveryDecline(newBcsRounded: newBcs);
      }
    }

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
