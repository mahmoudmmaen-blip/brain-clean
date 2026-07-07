import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Supabase bootstrap — credentials from [AppConfig] (`.env` or dart-define).
abstract final class SupabaseConfig {
  static String get url => AppConfig.supabaseUrl;

  static String get anonKey => AppConfig.supabaseAnonKey;

  static Future<void> initialize() async {
    if (url.isEmpty || anonKey.isEmpty) return;
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
