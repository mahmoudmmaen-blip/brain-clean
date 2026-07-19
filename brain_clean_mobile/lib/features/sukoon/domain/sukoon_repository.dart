import 'sukoon_session.dart';

abstract interface class SukoonRepository {
  Future<void> saveSession(SukoonSession session);

  Future<List<SukoonSession>> getTodaySessions();

  Future<List<SukoonSession>> getAllSessions();

  Future<int> getTotalMinutes();
}
