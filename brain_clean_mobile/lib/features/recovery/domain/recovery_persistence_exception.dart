/// Thrown when local recovery JSON violates the camelCase persistence contract.
final class RecoveryPersistenceException implements Exception {
  RecoveryPersistenceException(this.message);

  final String message;

  @override
  String toString() => 'RecoveryPersistenceException: $message';
}
