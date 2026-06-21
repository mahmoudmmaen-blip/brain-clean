import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/dashboard/domain/daily_snapshot.dart';
import '../../features/emotions/domain/emotion_log_entry.dart';
import '../network/supabase_client.dart';

part 'cloud_sync_service.g.dart';

@Riverpod(keepAlive: true)
CloudSyncService cloudSyncService(CloudSyncServiceRef ref) {
  return const CloudSyncService();
}

/// Best-effort Supabase sync for premium cloud backup.
class CloudSyncService {
  const CloudSyncService();

  SupabaseClient? get _client {
    try {
      if (SupabaseConfig.url.isEmpty) return null;
      return SupabaseConfig.client;
    } catch (_) {
      return null;
    }
  }

  String? get _userId => _client?.auth.currentSession?.user.id;

  Future<void> syncDailySnapshot(DailySnapshot snapshot) async {
    final client = _client;
    if (client == null || client.auth.currentSession == null) return;
    final userId = _userId;
    if (userId == null) return;
    try {
      await client.from('daily_snapshots').upsert({
        'user_id': userId,
        'date': snapshot.date.toIso8601String(),
        'bcs_value': snapshot.bcsValue,
      });
    } catch (_) {
      return;
    }
  }

  Future<void> syncEmotionLog(EmotionLogEntry entry) async {
    final client = _client;
    if (client == null || client.auth.currentSession == null) return;
    final userId = _userId;
    if (userId == null) return;
    try {
      await client.from('emotion_logs').upsert({
        'user_id': userId,
        'timestamp': entry.timestamp.toIso8601String(),
        'emotion_label': entry.label,
        'category': entry.category,
        'recovery_impact': entry.recoveryImpact,
      });
    } catch (_) {
      return;
    }
  }
}
