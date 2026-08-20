import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../security/authenticated_session.dart';

/// Supabase bootstrap — credentials from [AppConfig] (dart-define preferred).
abstract final class SupabaseConfig {
  static const _sessionTimeout = Duration(seconds: 8);

  static String get url => AppConfig.supabaseUrl;

  static String get anonKey => AppConfig.supabaseAnonKey;

  static bool get isConfigured =>
      AppConfig.hasValidSupabaseConfig && _sdkInitialized;

  static Future<void> initialize() async {
    if (!AppConfig.hasValidSupabaseConfig) {
      debugPrint(
        'SupabaseConfig: missing or placeholder credentials — '
        'continuing offline (pass SUPABASE_URL / SUPABASE_ANON_KEY via '
        '--dart-define, or put real values in .env)',
      );
      return;
    }

    try {
      if (!_sdkInitialized) {
        await Supabase.initialize(url: url, anonKey: anonKey);
      }
      await _ensureAnonymousSession();
      debugPrint('SupabaseConfig: initialized');
    } catch (error) {
      debugPrint(
        'SupabaseConfig: initialize failed — continuing offline: $error',
      );
    }
  }

  static bool get _sdkInitialized {
    try {
      return Supabase.instance.isInitialized;
    } catch (_) {
      return false;
    }
  }

  /// Restores an existing session, or signs in anonymously so RLS (`auth.uid()`)
  /// and Edge Functions (`verify-xp`, `safa-chat`) can run.
  static Future<void> _ensureAnonymousSession() async {
    if (!_sdkInitialized) return;

    final client = Supabase.instance.client;
    final existing = client.auth.currentUser;
    if (existing != null) {
      AppConfig.supabaseUserId = existing.id;
      return;
    }

    try {
      final response = await client.auth
          .signInAnonymously()
          .timeout(_sessionTimeout);
      final userId = response.user?.id;
      if (userId != null) {
        AppConfig.supabaseUserId = userId;
      }
    } on TimeoutException {
      debugPrint(
        'SupabaseConfig: anonymous sign-in timed out — continuing offline',
      );
    } catch (error) {
      debugPrint(
        'SupabaseConfig: anonymous sign-in failed — continuing offline',
      );
      assert(() {
        debugPrint('SupabaseConfig: sign-in error detail: $error');
        return true;
      }());
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// Client for optional/offline-tolerant call sites — `null` when the env keys
  /// are missing or Supabase was never initialized.
  static SupabaseClient? get clientOrNull {
    if (!AppConfig.hasValidSupabaseConfig) return null;
    if (!_sdkInitialized) return null;
    try {
      return client;
    } catch (_) {
      return null;
    }
  }
}

extension SupabaseUserScope on SupabaseClient {
  /// Id of the signed-in user, or `null` when there is no session.
  String? get authenticatedUserId => auth.currentUser?.id;

  /// Upserts [payload] into [table] scoped to the signed-in user.
  ///
  /// Returns `false` without writing when nobody is signed in. Stamps
  /// `updated_at` unless [stampUpdatedAt] is false.
  Future<bool> upsertForCurrentUser(
    String table,
    Map<String, dynamic> payload, {
    bool stampUpdatedAt = true,
  }) async {
    final userId = authenticatedUserId;
    if (userId == null) return false;
    if (!AuthenticatedSession.isUsable(auth.currentSession)) return false;
    await from(table).upsert({
      'user_id': userId,
      ...payload,
      if (stampUpdatedAt)
        'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    return true;
  }
}
