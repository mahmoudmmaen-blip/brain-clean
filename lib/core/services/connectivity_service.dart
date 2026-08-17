import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../diagnostics/app_error_logger.dart';
import '../network/supabase_client.dart';

part 'connectivity_service.g.dart';

/// Lightweight online gate for sync — Supabase configured + authenticated session.
///
/// Does not add a network probe dependency; failed sync calls imply offline.
@Riverpod(keepAlive: true)
bool connectivityOnline(ConnectivityOnlineRef ref) {
  try {
    if (SupabaseConfig.url.isEmpty) return false;
    final session = SupabaseConfig.client.auth.currentSession;
    return session != null;
  } catch (error, stackTrace) {
    logAppError('connectivityOnline', error, stackTrace);
    return false;
  }
}
