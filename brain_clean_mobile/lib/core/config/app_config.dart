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
  /// Example: pubspec `1.2.1+13` → `appVersion = '1.2.1'`.
  /// Do not add `package_info` — keep this constant as the single UI source.
  static const String appVersion = '1.2.1';

  static String get supabaseUrl => _resolve(
        defineValue: const String.fromEnvironment('SUPABASE_URL'),
        envKey: 'SUPABASE_URL',
      );

  static String get supabaseAnonKey => _resolve(
        defineValue: const String.fromEnvironment('SUPABASE_ANON_KEY'),
        envKey: 'SUPABASE_ANON_KEY',
      );

  static String get revenueCatApiKey => _resolve(
        defineValue: const String.fromEnvironment('REVENUECAT_API_KEY'),
        envKey: 'REVENUECAT_API_KEY',
      );

  static String get xpHmacSecret => _resolve(
        defineValue: const String.fromEnvironment('XP_HMAC_SECRET'),
        envKey: 'XP_HMAC_SECRET',
      );

  static String get nvidiaApiKey => _resolve(
        defineValue: const String.fromEnvironment('NVIDIA_API_KEY'),
        envKey: 'NVIDIA_API_KEY',
      );

  /// True when both Supabase URL and anon key are non-empty and not placeholders.
  static bool get hasValidSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// True when RevenueCat public SDK key is non-empty and not a placeholder.
  static bool get hasValidRevenueCatApiKey => revenueCatApiKey.isNotEmpty;

  /// Set after anonymous Supabase sign-in (XP sync / Edge Functions).
  static String? supabaseUserId;

  /// Returns [defineValue] when set; otherwise dotenv; placeholders → `''`.
  static String _resolve({
    required String defineValue,
    required String envKey,
  }) {
    final raw = defineValue.trim().isNotEmpty ? defineValue.trim() : _env(envKey);
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
  /// Does not log or return the original secret — callers only see a bool.
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

  /// Short, non-secret hint for logs (never the full key).
  static String configPresenceLabel(String value) {
    if (value.isEmpty) return 'missing';
    if (value.length <= 4) return 'set(len=${value.length})';
    return 'set(len=${value.length},prefix=${value.substring(0, 4)}…)';
  }
}
