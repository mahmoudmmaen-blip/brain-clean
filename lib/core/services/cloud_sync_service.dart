import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/dashboard/domain/daily_snapshot.dart';
import '../../features/emotions/domain/emotion_log_entry.dart';
import '../network/supabase_client.dart';
import '../security/root_detector.dart';

part 'cloud_sync_service.g.dart';

@Riverpod(keepAlive: true)
CloudSyncService cloudSyncService(CloudSyncServiceRef ref) {
  return const CloudSyncService();
}

/// Best-effort Supabase sync for premium cloud backup.
class CloudSyncService {
  const CloudSyncService();

  SupabaseClient? get _client => SupabaseConfig.clientOrNull;

  Future<void> syncDailySnapshot(DailySnapshot snapshot) async {
    if (RootDetector.isCompromised) return;
    final client = _client;
    if (client == null || client.auth.currentSession == null) return;
    try {
      await client.upsertForCurrentUser(
        'daily_snapshots',
        {
          'date': snapshot.date.toIso8601String(),
          'bcs_value': snapshot.bcsValue,
        },
        stampUpdatedAt: false,
      );
    } catch (_) {
      return;
    }
  }

  Future<void> syncEmotionLog(EmotionLogEntry entry) async {
    if (RootDetector.isCompromised) return;
    final client = _client;
    if (client == null || client.auth.currentSession == null) return;
    try {
      await client.upsertForCurrentUser(
        'emotion_logs',
        {
          'timestamp': entry.timestamp.toIso8601String(),
          'emotion_label': entry.label,
          'category': entry.category,
          'recovery_impact': entry.recoveryImpact,
        },
        stampUpdatedAt: false,
      );
    } catch (_) {
      return;
    }
  }
}
