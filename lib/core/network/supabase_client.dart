import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase bootstrap — wire env keys before production.
abstract final class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static Future<void> initialize() async {
    if (url.isEmpty || anonKey.isEmpty) return;
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// Client for optional/offline-tolerant call sites — `null` when the env keys
  /// are missing or Supabase was never initialized.
  static SupabaseClient? get clientOrNull {
    if (url.isEmpty || anonKey.isEmpty) return null;
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
    await from(table).upsert({
      'user_id': userId,
      ...payload,
      if (stampUpdatedAt)
        'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    return true;
  }
}
