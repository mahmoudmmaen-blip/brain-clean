import 'anxiety_result.dart';

abstract class AnxietyRepository {
  Future<void> saveResult(AnxietyResult result);

  Future<AnxietyResult?> getLatestResult();

  Future<List<AnxietyResult>> getAllResults();
}
