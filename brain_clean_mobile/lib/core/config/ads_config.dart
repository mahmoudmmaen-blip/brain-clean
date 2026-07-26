import 'package:flutter/foundation.dart';

/// AdMob / local monetization config.
///
/// Defaults to Google **test** IDs. Override with dart-define for Play release:
/// `--dart-define=ADMOB_ANDROID_APP_ID=ca-app-pub-xxx~yyy`
/// `--dart-define=ADMOB_ANDROID_BANNER_UNIT_ID=ca-app-pub-xxx/yyy`
/// `--dart-define=ADMOB_IOS_APP_ID=ca-app-pub-xxx~yyy`
/// `--dart-define=ADMOB_IOS_BANNER_UNIT_ID=ca-app-pub-xxx/yyy`
///
/// Never commit real production ad unit IDs as source defaults.
abstract final class AdsConfig {
  AdsConfig._();

  /// Google sample Android App ID (test).
  static const androidTestAppId = 'ca-app-pub-3940256099942544~3347511713';

  /// Google sample Android banner unit (test).
  static const androidTestBannerUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  /// Google sample iOS App ID (test).
  static const iosTestAppId = 'ca-app-pub-3940256099942544~1458002511';

  /// Google sample iOS banner unit (test).
  static const iosTestBannerUnitId = 'ca-app-pub-3940256099942544/2934735716';

  static const String _androidAppIdDefine =
      String.fromEnvironment('ADMOB_ANDROID_APP_ID');
  static const String _androidBannerDefine =
      String.fromEnvironment('ADMOB_ANDROID_BANNER_UNIT_ID');
  static const String _iosAppIdDefine =
      String.fromEnvironment('ADMOB_IOS_APP_ID');
  static const String _iosBannerDefine =
      String.fromEnvironment('ADMOB_IOS_BANNER_UNIT_ID');

  static String get androidAppId =>
      _nonEmpty(_androidAppIdDefine) ?? androidTestAppId;

  static String get iosAppId => _nonEmpty(_iosAppIdDefine) ?? iosTestAppId;

  static String get androidBannerUnitId =>
      _nonEmpty(_androidBannerDefine) ?? androidTestBannerUnitId;

  static String get iosBannerUnitId =>
      _nonEmpty(_iosBannerDefine) ?? iosTestBannerUnitId;

  /// Banner unit for the current platform (test IDs by default).
  static String get bannerAdUnitId {
    if (kIsWeb) return androidTestBannerUnitId;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return iosBannerUnitId;
      default:
        return androidBannerUnitId;
    }
  }

  static String? _nonEmpty(String value) {
    final v = value.trim();
    if (v.isEmpty) return null;
    return v;
  }
}
