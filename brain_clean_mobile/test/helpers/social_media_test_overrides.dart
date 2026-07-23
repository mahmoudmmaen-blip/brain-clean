import 'package:brain_clean_mobile/core/services/social_media_usage_provider.dart';
import 'package:brain_clean_mobile/core/services/social_media_usage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Disables the Android-only usage card in widget tests.
///
/// Flutter widget tests default to [TargetPlatform.android], so without this
/// override [SocialMediaUsage] stays in [AsyncLoading] while the MethodChannel
/// Future never completes — leaving an indeterminate
/// [CircularProgressIndicator] that makes [WidgetTester.pumpAndSettle] hang.
Override socialMediaUnsupportedTestOverride() {
  return socialMediaUsageServiceProvider.overrideWithValue(
    SocialMediaUsageService(platformIsAndroid: false),
  );
}
