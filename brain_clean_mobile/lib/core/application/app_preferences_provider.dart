import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/hive_meta_keys.dart';
import '../../core/data/app_meta_box_provider.dart';

part 'app_preferences_provider.g.dart';

class AppPreferencesState {
  const AppPreferencesState({
    required this.hasSeenOnboarding,
    required this.isProUser,
    required this.emotionNotificationsEnabled,
    required this.dailyFocusReminderEnabled,
    required this.profileDisplayName,
    required this.silenceWinsCount,
    required this.singleTasksCompletedCount,
  });

  final bool hasSeenOnboarding;
  final bool isProUser;
  final bool emotionNotificationsEnabled;
  final bool dailyFocusReminderEnabled;
  final String profileDisplayName;
  final int silenceWinsCount;
  final int singleTasksCompletedCount;

  static const firstLaunch = AppPreferencesState(
    hasSeenOnboarding: false,
    isProUser: false,
    emotionNotificationsEnabled: true,
    dailyFocusReminderEnabled: true,
    profileDisplayName: '',
    silenceWinsCount: 0,
    singleTasksCompletedCount: 0,
  );

  /// Used when Hive is unavailable (widget tests).
  static const testDefaults = AppPreferencesState(
    hasSeenOnboarding: true,
    isProUser: true,
    emotionNotificationsEnabled: true,
    dailyFocusReminderEnabled: true,
    profileDisplayName: '',
    silenceWinsCount: 0,
    singleTasksCompletedCount: 0,
  );

  AppPreferencesState copyWith({
    bool? hasSeenOnboarding,
    bool? isProUser,
    bool? emotionNotificationsEnabled,
    bool? dailyFocusReminderEnabled,
    String? profileDisplayName,
    int? silenceWinsCount,
    int? singleTasksCompletedCount,
  }) {
    return AppPreferencesState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      isProUser: isProUser ?? this.isProUser,
      emotionNotificationsEnabled:
          emotionNotificationsEnabled ?? this.emotionNotificationsEnabled,
      dailyFocusReminderEnabled:
          dailyFocusReminderEnabled ?? this.dailyFocusReminderEnabled,
      profileDisplayName: profileDisplayName ?? this.profileDisplayName,
      silenceWinsCount: silenceWinsCount ?? this.silenceWinsCount,
      singleTasksCompletedCount:
          singleTasksCompletedCount ?? this.singleTasksCompletedCount,
    );
  }
}

@Riverpod(keepAlive: true)
class AppPreferences extends _$AppPreferences {
  @override
  AppPreferencesState build() {
    try {
      final box = ref.watch(appMetaBoxProvider);
      return AppPreferencesState(
        hasSeenOnboarding:
            box.get(HiveMetaKeys.hasSeenOnboarding, defaultValue: false)
                as bool,
        isProUser:
            box.get(HiveMetaKeys.isProUser, defaultValue: false) as bool,
        emotionNotificationsEnabled: box.get(
              HiveMetaKeys.emotionNotificationsEnabled,
              defaultValue: true,
            )
            as bool,
        dailyFocusReminderEnabled: box.get(
              HiveMetaKeys.dailyFocusReminderEnabled,
              defaultValue: true,
            )
            as bool,
        profileDisplayName: box.get(
              HiveMetaKeys.profileDisplayName,
              defaultValue: '',
            )
            as String,
        silenceWinsCount:
            box.get(HiveMetaKeys.silenceWinsCount, defaultValue: 0) as int,
        singleTasksCompletedCount: box.get(
              HiveMetaKeys.singleTasksCompletedCount,
              defaultValue: 0,
            )
            as int,
      );
    } catch (_) {
      return AppPreferencesState.testDefaults;
    }
  }

  Future<void> _persist(String key, dynamic value) async {
    try {
      final box = ref.read(appMetaBoxProvider);
      await box.put(key, value);
      ref.invalidateSelf();
    } catch (_) {
      state = _patchFromKey(key, value);
    }
  }

  AppPreferencesState _patchFromKey(String key, dynamic value) {
    return switch (key) {
      HiveMetaKeys.hasSeenOnboarding =>
        state.copyWith(hasSeenOnboarding: value as bool),
      HiveMetaKeys.isProUser => state.copyWith(isProUser: value as bool),
      HiveMetaKeys.emotionNotificationsEnabled =>
        state.copyWith(emotionNotificationsEnabled: value as bool),
      HiveMetaKeys.dailyFocusReminderEnabled =>
        state.copyWith(dailyFocusReminderEnabled: value as bool),
      HiveMetaKeys.profileDisplayName =>
        state.copyWith(profileDisplayName: value as String),
      HiveMetaKeys.silenceWinsCount =>
        state.copyWith(silenceWinsCount: value as int),
      HiveMetaKeys.singleTasksCompletedCount =>
        state.copyWith(singleTasksCompletedCount: value as int),
      _ => state,
    };
  }

  Future<void> completeOnboarding() =>
      _persist(HiveMetaKeys.hasSeenOnboarding, true);

  Future<void> setProUser(bool value) =>
      _persist(HiveMetaKeys.isProUser, value);

  Future<void> setEmotionNotifications(bool value) =>
      _persist(HiveMetaKeys.emotionNotificationsEnabled, value);

  Future<void> setDailyFocusReminder(bool value) =>
      _persist(HiveMetaKeys.dailyFocusReminderEnabled, value);

  Future<void> setProfileDisplayName(String name) =>
      _persist(HiveMetaKeys.profileDisplayName, name.trim());

  Future<void> incrementSilenceWin() =>
      _persist(HiveMetaKeys.silenceWinsCount, state.silenceWinsCount + 1);

  Future<void> incrementSingleTaskComplete() => _persist(
        HiveMetaKeys.singleTasksCompletedCount,
        state.singleTasksCompletedCount + 1,
      );
}

/// Convenience read-only aliases for pro/onboarding gates.
@riverpod
bool isProUser(IsProUserRef ref) =>
    ref.watch(appPreferencesProvider).isProUser;

@riverpod
bool hasSeenOnboarding(HasSeenOnboardingRef ref) =>
    ref.watch(appPreferencesProvider).hasSeenOnboarding;
