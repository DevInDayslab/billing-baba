/// Thrown when the API responds with field-level validation errors.
class ApiValidationException implements Exception {
  const ApiValidationException({
    required this.message,
    required this.fieldErrors,
  });

  final String message;
  final Map<String, String> fieldErrors;

  @override
  String toString() => message;
}
