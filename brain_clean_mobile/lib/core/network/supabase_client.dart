import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Supabase bootstrap — credentials from [AppConfig] (dart-define preferred).
abstract final class SupabaseConfig {
  static String get url => AppConfig.supabaseUrl;

  static String get anonKey => AppConfig.supabaseAnonKey;

  static bool get isConfigured =>
      AppConfig.hasValidSupabaseConfig && Supabase.instance.isInitialized;

  static Future<void> initialize() async {
    if (!AppConfig.hasValidSupabaseConfig) {
      debugPrint(
        'SupabaseConfig: missing or placeholder credentials — '
        'continuing offline (pass SUPABASE_URL / SUPABASE_ANON_KEY via '
        '--dart-define for cloud)',
      );
      return;
    }

    try {
      await Supabase.initialize(url: url, anonKey: anonKey);
      debugPrint('SupabaseConfig: initialized');
    } catch (error) {
      debugPrint(
        'SupabaseConfig: initialize failed — continuing offline: $error',
      );
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
