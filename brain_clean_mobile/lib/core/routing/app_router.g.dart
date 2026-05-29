// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$goRouterHash() => r'6f97a8636bf22fce188e1120308cabcca1503460';

/// App shell — splash hydrates Hive, then routes to home or **live session** resume.
///
/// Live session routing ([AppRoutes.diagnostic]): when Hive holds draft metrics or
/// questionnaire state without a committed BC_score, [SplashScreen] opens
/// [DiagnosticScreen], which reads [diagnosticLiveSessionProvider] (not a stale
/// in-memory draft). Committed sessions land on [HomeScreen] / dashboard.
///
/// Copied from [goRouter].
@ProviderFor(goRouter)
final goRouterProvider = AutoDisposeProvider<GoRouter>.internal(
  goRouter,
  name: r'goRouterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$goRouterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GoRouterRef = AutoDisposeProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
