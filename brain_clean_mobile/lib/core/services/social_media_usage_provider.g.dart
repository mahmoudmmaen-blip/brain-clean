// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_media_usage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$socialMediaUsageServiceHash() =>
    r'4e4733a9a21df7a998f51e9c3eff62840bba8e3a';

/// See also [socialMediaUsageService].
@ProviderFor(socialMediaUsageService)
final socialMediaUsageServiceProvider =
    Provider<SocialMediaUsageService>.internal(
  socialMediaUsageService,
  name: r'socialMediaUsageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$socialMediaUsageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SocialMediaUsageServiceRef = ProviderRef<SocialMediaUsageService>;
String _$socialMediaUsageHash() => r'2278ef619c2f0ab4d97efc73103185b862d10e5b';

/// See also [SocialMediaUsage].
@ProviderFor(SocialMediaUsage)
final socialMediaUsageProvider = AutoDisposeAsyncNotifierProvider<
    SocialMediaUsage, SocialMediaUsageSnapshot>.internal(
  SocialMediaUsage.new,
  name: r'socialMediaUsageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$socialMediaUsageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SocialMediaUsage = AutoDisposeAsyncNotifier<SocialMediaUsageSnapshot>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
