// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_streak_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeStreakTickerHash() => r'8fd92f69ab10dc330e6598f379925aff8a32eac6';

/// See also [homeStreakTicker].
@ProviderFor(homeStreakTicker)
final homeStreakTickerProvider = AutoDisposeStreamProvider<int>.internal(
  homeStreakTicker,
  name: r'homeStreakTickerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeStreakTickerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HomeStreakTickerRef = AutoDisposeStreamProviderRef<int>;
String _$homeStreakSnapshotHash() =>
    r'40cdfd7d91a955b277ff8d72aa4ae8c2ace0bc95';

/// See also [homeStreakSnapshot].
@ProviderFor(homeStreakSnapshot)
final homeStreakSnapshotProvider =
    AutoDisposeProvider<HomeStreakSnapshot>.internal(
  homeStreakSnapshot,
  name: r'homeStreakSnapshotProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeStreakSnapshotHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HomeStreakSnapshotRef = AutoDisposeProviderRef<HomeStreakSnapshot>;
String _$homeStreakRetrogradeHash() =>
    r'5a0264a9f82943ae05e586f0b4bf732b947f9827';

/// Cumulative retrograde (e.g. −12h distraction penalty).
///
/// Copied from [HomeStreakRetrograde].
@ProviderFor(HomeStreakRetrograde)
final homeStreakRetrogradeProvider =
    NotifierProvider<HomeStreakRetrograde, Duration>.internal(
  HomeStreakRetrograde.new,
  name: r'homeStreakRetrogradeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeStreakRetrogradeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HomeStreakRetrograde = Notifier<Duration>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
