import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'detox_ai_coach_service.dart';

part 'detox_ai_coach_service_provider.g.dart';

@riverpod
DetoxAiCoachService detoxAiCoachService(DetoxAiCoachServiceRef ref) {
  return DetoxAiCoachService();
}
