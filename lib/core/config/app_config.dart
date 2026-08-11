import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration.
///
/// Preference order for secrets/config:
/// 1. `--dart-define` / `String.fromEnvironment` (release-safe)
/// 2. dotenv fallback (local docs / optional `.env.example` values)
///
/// Placeholder values from `.env.example` are treated as **missing**.
abstract final class AppConfig {
  /// Displayed app version for Settings / More.
  ///
  /// MUST be bumped together with `pubspec.yaml` `version:` (name before `+`).
  /// Example: pubspec `2.0.1+19` → `appVersion = '2.0.1'`.
  /// Do not add `package_info` — keep this constant as the single UI source.
  static const String appVersion = '2.0.1';

  static String get supabaseUrl => _resolve(
        defineValue: const String.fromEnvironment('SUPABASE_URL'),
        envKey: 'SUPABASE_URL',
      );

  static String get supabaseAnonKey => _resolve(
        defineValue: const String.fromEnvironment('SUPABASE_ANON_KEY'),
        envKey: 'SUPABASE_ANON_KEY',
      );

  /// Transitional single-slot key (current platform only when Android/iOS unset).
  static String get revenueCatApiKey => _resolve(
        defineValue: const String.fromEnvironment('REVENUECAT_API_KEY'),
        envKey: 'REVENUECAT_API_KEY',
      );

  /// Preferred Android public SDK key (Production Monetization Contract §5).
  static String get revenueCatAndroidApiKey => _resolve(
        defineValue: const String.fromEnvironment('REVENUECAT_ANDROID_API_KEY'),
        envKey: 'REVENUECAT_ANDROID_API_KEY',
      );

  /// Preferred iOS public SDK key (Production Monetization Contract §5).
  static String get revenueCatIosApiKey => _resolve(
        defineValue: const String.fromEnvironment('REVENUECAT_IOS_API_KEY'),
        envKey: 'REVENUECAT_IOS_API_KEY',
      );

  static String get xpHmacSecret => _resolve(
        defineValue: const String.fromEnvironment('XP_HMAC_SECRET'),
        envKey: 'XP_HMAC_SECRET',
      );

  /// True when both Supabase URL and anon key are non-empty and not placeholders.
  static bool get hasValidSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// True when a usable RevenueCat public SDK key is present for this build.
  ///
  /// Prefer calling [revenueCatPublicSdkKey] with an explicit platform in
  /// production selection code.
  static bool get hasValidRevenueCatApiKey =>
      revenueCatAndroidApiKey.isNotEmpty ||
      revenueCatIosApiKey.isNotEmpty ||
      revenueCatApiKey.isNotEmpty;

  /// Platform-appropriate public SDK key (never log the returned value).
  ///
  /// Prefers Android/iOS-specific defines; falls back to transitional
  /// [revenueCatApiKey] when platform-specific keys are absent.
  static String revenueCatPublicSdkKey({required bool isIOS}) {
    final platformKey = isIOS ? revenueCatIosApiKey : revenueCatAndroidApiKey;
    if (platformKey.isNotEmpty) return platformKey;
    return revenueCatApiKey;
  }

  /// Set after anonymous Supabase sign-in (XP sync / Edge Functions).
  static String? supabaseUserId;

  /// Returns [defineValue] when set; otherwise dotenv; placeholders â†’ `''`.
  static String _resolve({
    required String defineValue,
    required String envKey,
  }) {
    final raw =
        defineValue.trim().isNotEmpty ? defineValue.trim() : _env(envKey);
    if (raw.isEmpty || isPlaceholderConfigValue(raw)) return '';
    return raw;
  }

  static String _env(String key) {
    try {
      return dotenv.env[key]?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Detects documentation / example placeholder credentials.
  ///
  /// Does not log or return the original secret â€” callers only see a bool.
  static bool isPlaceholderConfigValue(String value) {
    final v = value.trim().toLowerCase();
    if (v.isEmpty) return false;

    const markers = <String>[
      'your-project-ref',
      'your-anon-key',
      'your_anon_key',
      'your-revenuecat-key',
      'your_revenuecat',
      'your_key_here',
      'your-key-here',
      'sb_publishable_your_key',
      'example.com',
      'changeme',
      'replace_me',
      'todo_replace',
    ];

    for (final marker in markers) {
      if (v.contains(marker)) return true;
    }
    return false;
  }

  /// Non-secret configuration state for logs.
  ///
  /// Never includes value, length, or prefix metadata.
  static String configPresenceLabel(String value) {
    if (value.isEmpty || isPlaceholderConfigValue(value)) {
      return 'unavailable';
    }
    return 'configured';
  }

  /// Human-safe RevenueCat initialization log line (never includes key metadata).
  static String revenueCatInitLogLine({required bool configured}) {
    return configured
        ? 'RevenueCat initialization succeeded'
        : 'RevenueCat configuration unavailable';
  }
}
