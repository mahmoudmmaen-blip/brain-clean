// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safa_anxiety_program_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$safaAnxietyProgramHash() =>
    r'62bade796502e720f97be4b5a3bd82c4f16c539f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [safaAnxietyProgram].
@ProviderFor(safaAnxietyProgram)
const safaAnxietyProgramProvider = SafaAnxietyProgramFamily();

/// See also [safaAnxietyProgram].
class SafaAnxietyProgramFamily extends Family<AsyncValue<String>> {
  /// See also [safaAnxietyProgram].
  const SafaAnxietyProgramFamily();

  /// See also [safaAnxietyProgram].
  SafaAnxietyProgramProvider call(
    AnxietyResult result,
  ) {
    return SafaAnxietyProgramProvider(
      result,
    );
  }

  @override
  SafaAnxietyProgramProvider getProviderOverride(
    covariant SafaAnxietyProgramProvider provider,
  ) {
    return call(
      provider.result,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'safaAnxietyProgramProvider';
}

/// See also [safaAnxietyProgram].
class SafaAnxietyProgramProvider extends AutoDisposeFutureProvider<String> {
  /// See also [safaAnxietyProgram].
  SafaAnxietyProgramProvider(
    AnxietyResult result,
  ) : this._internal(
          (ref) => safaAnxietyProgram(
            ref as SafaAnxietyProgramRef,
            result,
          ),
          from: safaAnxietyProgramProvider,
          name: r'safaAnxietyProgramProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$safaAnxietyProgramHash,
          dependencies: SafaAnxietyProgramFamily._dependencies,
          allTransitiveDependencies:
              SafaAnxietyProgramFamily._allTransitiveDependencies,
          result: result,
        );

  SafaAnxietyProgramProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.result,
  }) : super.internal();

  final AnxietyResult result;

  @override
  Override overrideWith(
    FutureOr<String> Function(SafaAnxietyProgramRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SafaAnxietyProgramProvider._internal(
        (ref) => create(ref as SafaAnxietyProgramRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        result: result,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _SafaAnxietyProgramProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SafaAnxietyProgramProvider && other.result == result;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, result.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SafaAnxietyProgramRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `result` of this provider.
  AnxietyResult get result;
}

class _SafaAnxietyProgramProviderElement
    extends AutoDisposeFutureProviderElement<String>
    with SafaAnxietyProgramRef {
  _SafaAnxietyProgramProviderElement(super.provider);

  @override
  AnxietyResult get result => (origin as SafaAnxietyProgramProvider).result;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
