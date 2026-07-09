import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/anxiety_result.dart';
import '../data/anxiety_repository_provider.dart';

part 'anxiety_latest_result_provider.g.dart';

@riverpod
Future<AnxietyResult?> anxietyLatestResult(AnxietyLatestResultRef ref) {
  return ref.watch(anxietyRepositoryProvider).getLatestResult();
}
