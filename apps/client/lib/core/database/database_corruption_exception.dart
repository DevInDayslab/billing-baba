/// Thrown when SQLite [PRAGMA integrity_check] reports corruption on open.
class DatabaseCorruptionException implements Exception {
  DatabaseCorruptionException(this.result);

  final String result;

  @override
  String toString() =>
      'DatabaseCorruptionException: local database integrity check failed ($result)';
}
