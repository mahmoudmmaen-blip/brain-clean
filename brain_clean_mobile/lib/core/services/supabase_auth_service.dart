import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

final supabaseUserIdProvider = Provider<String?>(
  (ref) => AppConfig.supabaseUserId,
);

/// Anonymous Supabase auth for offline-first apps — JWT used by XP Edge Functions.
class SupabaseAuthService {
  const SupabaseAuthService();

  static const _signInTimeout = Duration(seconds: 8);

  Future<void> signInAnonymouslyIfNeeded() async {
    if (!AppConfig.hasValidSupabaseConfig) {
      debugPrint(
        'SupabaseAuthService: skipped anonymous sign-in '
        '(missing or placeholder Supabase config)',
      );
      return;
    }

    try {
      if (!Supabase.instance.isInitialized) {
        debugPrint(
          'SupabaseAuthService: skipped anonymous sign-in '
          '(Supabase SDK not initialized)',
        );
        return;
      }

      final client = Supabase.instance.client;
      final existingUser = client.auth.currentUser;
      if (existingUser != null) {
        AppConfig.supabaseUserId = existingUser.id;
        return;
      }

      final response = await client.auth
          .signInAnonymously()
          .timeout(_signInTimeout);
      final userId = response.user?.id;
      if (userId != null) {
        AppConfig.supabaseUserId = userId;
      }
    } on TimeoutException {
      debugPrint(
        'SupabaseAuthService: anonymous sign-in timed out — continuing offline',
      );
    } catch (error) {
      // Avoid dumping network URLs that may embed project refs repeatedly.
      debugPrint(
        'SupabaseAuthService: anonymous sign-in failed — continuing offline',
      );
      assert(() {
        debugPrint('SupabaseAuthService: sign-in error detail: $error');
        return true;
      }());
    }
  }
}
