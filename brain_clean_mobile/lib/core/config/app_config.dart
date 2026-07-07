import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration loaded from `.env` via flutter_dotenv.
abstract final class AppConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static String get xpHmacSecret => dotenv.env['XP_HMAC_SECRET'] ?? '';

  static String get nvidiaApiKey => dotenv.env['NVIDIA_API_KEY'] ?? '';
}
