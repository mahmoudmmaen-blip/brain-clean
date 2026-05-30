import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../emotions/data/emotion_log_repository.dart';
import '../../emotions/domain/emotion_log_entry.dart';

part 'profile_emotions_provider.g.dart';

class ProfileEmotionsData {
  const ProfileEmotionsData({
    required this.count,
    required this.recent,
  });

  final int count;
  final List<EmotionLogEntry> recent;
}

@riverpod
Future<ProfileEmotionsData> profileEmotions(ProfileEmotionsRef ref) async {
  try {
    final repo = ref.watch(emotionLogRepositoryProvider);
    return ProfileEmotionsData(
      count: repo.count,
      recent: repo.recentEntries(limit: 5),
    );
  } catch (error, _) {
    throw Exception(error);
  }
}
