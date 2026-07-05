/// Failure during print data loading or PDF generation.
class PrintException implements Exception {
  const PrintException(this.message);

  final String message;

  @override
  String toString() => 'PrintException: $message';
}
