import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'daily_challenge_repository_impl.dart';
import '../domain/daily_challenge_repository.dart';

part 'daily_challenge_repository_provider.g.dart';

@Riverpod(keepAlive: true)
DailyChallengeRepository dailyChallengeRepository(
  DailyChallengeRepositoryRef ref,
) {
  return DailyChallengeRepositoryImpl();
}
