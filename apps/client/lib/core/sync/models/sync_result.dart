/// Outcome of one sync pass.
class SyncResult {
  const SyncResult({
    required this.success,
    required this.completedAt,
    this.message,
    this.acceptedCount = 0,
    this.conflictCount = 0,
    this.errorCount = 0,
  });

  factory SyncResult.noop({
    String message = 'Sync runtime idle — no sync executed',
  }) {
    return SyncResult(
      success: true,
      completedAt: DateTime.now().toUtc(),
      message: message,
    );
  }

  final bool success;
  final DateTime completedAt;
  final String? message;
  final int acceptedCount;
  final int conflictCount;
  final int errorCount;
}
