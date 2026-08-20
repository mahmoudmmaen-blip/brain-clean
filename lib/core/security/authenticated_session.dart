import 'package:supabase_flutter/supabase_flutter.dart';

/// Live-session gate for every remote write / Edge invoke.
abstract final class AuthenticatedSession {
  AuthenticatedSession._();

  /// Reject tokens that expire within this window so we never send a
  /// near-dead JWT to XP / progress / Safa writes.
  static const skew = Duration(seconds: 30);

  static bool isUsable(Session? session, {DateTime? now}) {
    if (session == null) return false;
    return isAccessTokenLive(
      accessToken: session.accessToken,
      userId: session.user.id,
      expiresAtEpochSeconds: session.expiresAt,
      now: now,
    );
  }

  static bool isAccessTokenLive({
    required String accessToken,
    required String userId,
    required int? expiresAtEpochSeconds,
    DateTime? now,
  }) {
    if (accessToken.trim().isEmpty) return false;
    if (userId.trim().isEmpty) return false;
    if (expiresAtEpochSeconds == null) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch(
      expiresAtEpochSeconds * 1000,
      isUtc: true,
    );
    final clock = now?.toUtc() ?? DateTime.now().toUtc();
    return expiry.isAfter(clock.add(skew));
  }
}
