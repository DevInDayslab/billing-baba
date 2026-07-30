class PosRepositoryException implements Exception {
  const PosRepositoryException({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
