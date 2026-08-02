import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'claude_ai_service.dart';

part 'claude_ai_service_provider.g.dart';

@riverpod
ClaudeAiService claudeAiService(ClaudeAiServiceRef ref) => ClaudeAiService();
