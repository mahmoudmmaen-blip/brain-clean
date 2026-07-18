// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emotion_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredEmotionCategoriesHash() =>
    r'06b89a19088ed5fd36ef81a0d09ca2e01c3bb943';

/// Filtered categories for the current mood gate.
///
/// Copied from [filteredEmotionCategories].
@ProviderFor(filteredEmotionCategories)
final filteredEmotionCategoriesProvider =
    AutoDisposeProvider<List<EmotionCategory>>.internal(
  filteredEmotionCategories,
  name: r'filteredEmotionCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredEmotionCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredEmotionCategoriesRef
    = AutoDisposeProviderRef<List<EmotionCategory>>;
String _$emotionWheelDailyProgramGateHash() =>
    r'8b6d49da82375060e5f705c917d968d03bf4abab';

/// Armed only when Emotion Wheel is opened from Daily Program mood step.
///
/// Copied from [EmotionWheelDailyProgramGate].
@ProviderFor(EmotionWheelDailyProgramGate)
final emotionWheelDailyProgramGateProvider =
    NotifierProvider<EmotionWheelDailyProgramGate, bool>.internal(
  EmotionWheelDailyProgramGate.new,
  name: r'emotionWheelDailyProgramGateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$emotionWheelDailyProgramGateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EmotionWheelDailyProgramGate = Notifier<bool>;
String _$emotionNotifierHash() => r'73717aaecb1822ba1abfebf7363759c25cebe8f2';

/// See also [EmotionNotifier].
@ProviderFor(EmotionNotifier)
final emotionNotifierProvider =
    NotifierProvider<EmotionNotifier, EmotionState>.internal(
  EmotionNotifier.new,
  name: r'emotionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$emotionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EmotionNotifier = Notifier<EmotionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
