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
String _$emotionNotifierHash() => r'b5adef74e932c27d87f7a682386a147be4122a6f';

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
