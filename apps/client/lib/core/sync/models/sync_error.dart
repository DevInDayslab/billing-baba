/// Structured sync runtime error (not thrown by features).
class SyncError {
  const SyncError({
    required this.code,
    required this.message,
    this.details,
    this.occurredAt,
  });

  factory SyncError.fromMessage(
    String message, {
    String code = 'SYNC_RUNTIME',
  }) {
    return SyncError(
      code: code,
      message: message,
      occurredAt: DateTime.now().toUtc(),
    );
  }

  final String code;
  final String message;
  final Map<String, dynamic>? details;
  final DateTime? occurredAt;

  @override
  String toString() => 'SyncError($code): $message';
}
