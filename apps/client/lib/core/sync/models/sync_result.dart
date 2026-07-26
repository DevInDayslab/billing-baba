import 'package:billing_baba/core/sync/models/sync_direction.dart';

/// Outcome of a sync attempt (engine / worker placeholder).
class SyncResult {
  const SyncResult({
    required this.success,
    required this.direction,
    required this.completedAt,
    this.message,
    this.acceptedCount = 0,
    this.conflictCount = 0,
    this.errorCount = 0,
  });

  factory SyncResult.noop({
    SyncDirection direction = SyncDirection.full,
    String message = 'Sync runtime idle — no sync executed',
  }) {
    return SyncResult(
      success: true,
      direction: direction,
      completedAt: DateTime.now().toUtc(),
      message: message,
    );
  }

  final bool success;
  final SyncDirection direction;
  final DateTime completedAt;
  final String? message;
  final int acceptedCount;
  final int conflictCount;
  final int errorCount;
}
