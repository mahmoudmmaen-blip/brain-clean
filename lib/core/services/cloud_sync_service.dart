import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/dashboard/domain/daily_snapshot.dart';
import '../../features/emotions/domain/emotion_log_entry.dart';
import '../network/supabase_client.dart';
import '../security/authenticated_session.dart';
import '../security/root_detector.dart';
import '../security/secure_remote_write.dart';

part 'cloud_sync_service.g.dart';

@Riverpod(keepAlive: true)
CloudSyncService cloudSyncService(CloudSyncServiceRef ref) {
  return const CloudSyncService();
}

/// Best-effort Supabase sync for premium cloud backup.
class CloudSyncService {
  const CloudSyncService({SecureRemoteWrite remoteWrite = const SecureRemoteWrite()})
      : _remoteWrite = remoteWrite;

  final SecureRemoteWrite _remoteWrite;

  SupabaseClient? get _client => SupabaseConfig.clientOrNull;

  Future<void> syncDailySnapshot(DailySnapshot snapshot) async {
    if (RootDetector.isCompromised) return;
    final client = _client;
    if (client == null ||
        !AuthenticatedSession.isUsable(client.auth.currentSession)) {
      return;
    }
    try {
      await _remoteWrite.upsert(
        table: 'daily_snapshots',
        row: {
          'date': snapshot.date.toIso8601String(),
          'bcs_value': snapshot.bcsValue,
        },
      );
    } catch (_) {
      return;
    }
  }

  Future<void> syncEmotionLog(EmotionLogEntry entry) async {
    if (RootDetector.isCompromised) return;
    final client = _client;
    if (client == null ||
        !AuthenticatedSession.isUsable(client.auth.currentSession)) {
      return;
    }
    try {
      await _remoteWrite.upsert(
        table: 'emotion_logs',
        row: {
          'timestamp': entry.timestamp.toIso8601String(),
          'emotion_label': entry.label,
          'category': entry.category,
          'recovery_impact': entry.recoveryImpact,
        },
      );
    } catch (_) {
      return;
    }
  }
}
