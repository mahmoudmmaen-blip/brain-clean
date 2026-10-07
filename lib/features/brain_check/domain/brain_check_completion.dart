import '../data/brain_check_local_repository.dart';
import '../domain/brain_check_result.dart';

/// Single source of truth for whether Brain Check has ever been completed.
///
/// Home, Progress, and Profile must all use this — never invent status from
/// starter plans, empty profiles, or marketing copy.
abstract final class BrainCheckCompletion {
  static Future<BrainCheckResult?> loadResult(
    BrainCheckLocalRepository repo,
  ) async {
    try {
      return await repo.loadResult();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isCompleted(BrainCheckLocalRepository repo) async {
    final result = await loadResult(repo);
    return result != null;
  }

  static bool fromResult(BrainCheckResult? result) => result != null;
}
