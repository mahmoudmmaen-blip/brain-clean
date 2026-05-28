// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diagnosticControllerHash() =>
    r'585d9bdbd62c41665dafae4d63b5eaa05323e566';

/// Slider metrics — keepAlive + Hive draft sync so cold start never wipes answers.
///
/// Copied from [DiagnosticController].
@ProviderFor(DiagnosticController)
final diagnosticControllerProvider =
    AsyncNotifierProvider<DiagnosticController, DiagnosticMetrics>.internal(
  DiagnosticController.new,
  name: r'diagnosticControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$diagnosticControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DiagnosticController = AsyncNotifier<DiagnosticMetrics>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
