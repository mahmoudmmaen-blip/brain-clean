import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration loaded from `.env` via flutter_dotenv.
abstract final class AppConfig {
  static String get supabaseUrl => _env('SUPABASE_URL');

  static String get supabaseAnonKey => _env('SUPABASE_ANON_KEY');

  static String get xpHmacSecret => _env('XP_HMAC_SECRET');

  static String get nvidiaApiKey => _env('NVIDIA_API_KEY');

  /// Set after anonymous Supabase sign-in (XP sync / Edge Functions).
  static String? supabaseUserId;

  static String _env(String key) {
    try {
      return dotenv.env[key] ?? '';
    } catch (_) {
      return '';
    }
  }
}
