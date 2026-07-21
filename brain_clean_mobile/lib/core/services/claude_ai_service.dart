import 'package:supabase_flutter/supabase_flutter.dart';

class ClaudeAiService {
  Future<String?> chat(String userMessage) async {
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'safa-chat',
        body: {'message': userMessage},
      );
      final data = res.data;
      if (data is Map && data['reply'] is String) {
        final reply = (data['reply'] as String).trim();
        return reply.isEmpty ? null : reply;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
