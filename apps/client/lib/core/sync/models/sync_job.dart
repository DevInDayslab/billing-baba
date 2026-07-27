import 'package:billing_baba/core/sync/models/sync_direction.dart';
import 'package:billing_baba/core/sync/models/sync_queue_enums.dart';

/// Durable sync queue job (maps 1:1 to a `sync_queue` row).
class SyncJob {
  const SyncJob({
    required this.id,
    required this.mutationId,
    required this.kind,
    required this.entityType,
    required this.operation,
    required this.payload,
    required this.businessId,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.entityId,
    this.deviceId,
    this.commandId,
    this.attemptCount = 0,
    this.scheduledAt,
    this.lastAttemptAt,
    this.nextRetryAt,
    this.lastError,
    this.direction = SyncDirection.push,
  });

  final String id;
  final String mutationId;
  final SyncQueueKind kind;
  final String entityType;
  final String? entityId;
  final SyncQueueOperation operation;
  final Map<String, dynamic> payload;
  final String businessId;
  final String? deviceId;
  final String? commandId;
  final SyncQueueStatus status;
  final SyncQueuePriority priority;
  final int attemptCount;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? lastAttemptAt;
  final DateTime? nextRetryAt;
  final String? lastError;

  /// Legacy field retained for SyncResult compatibility.
  final SyncDirection direction;

  SyncJob copyWith({
    SyncQueueStatus? status,
    SyncQueuePriority? priority,
    int? attemptCount,
    Map<String, dynamic>? payload,
    DateTime? scheduledAt,
    DateTime? lastAttemptAt,
    DateTime? nextRetryAt,
    String? lastError,
    bool clearLastError = false,
    bool clearNextRetryAt = false,
  }) {
    return SyncJob(
      id: id,
      mutationId: mutationId,
      kind: kind,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload ?? this.payload,
      businessId: businessId,
      deviceId: deviceId,
      commandId: commandId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      attemptCount: attemptCount ?? this.attemptCount,
      createdAt: createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      nextRetryAt: clearNextRetryAt ? null : (nextRetryAt ?? this.nextRetryAt),
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      direction: direction,
    );
  }

  // --- Payload meta helpers (stripped before push) ---

  static const baseSyncVersionKey = '_base_sync_version';
  static const clientUpdatedAtKey = '_client_updated_at';

  static Map<String, dynamic> withPayloadMeta(
    Map<String, dynamic> domain, {
    required int baseSyncVersion,
    required DateTime clientUpdatedAt,
  }) {
    return {
      ...domain,
      baseSyncVersionKey: baseSyncVersion,
      clientUpdatedAtKey: clientUpdatedAt.toUtc().toIso8601String(),
    };
  }

  static int readBaseSyncVersion(Map<String, dynamic> payload) {
    final value = payload[baseSyncVersionKey];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static String readClientUpdatedAt(Map<String, dynamic> payload) {
    final value = payload[clientUpdatedAtKey];
    if (value is String && value.isNotEmpty) return value;
    return DateTime.now().toUtc().toIso8601String();
  }

  static Map<String, dynamic> domainOnly(Map<String, dynamic> payload) {
    return Map<String, dynamic>.from(payload)
      ..remove(baseSyncVersionKey)
      ..remove(clientUpdatedAtKey);
  }
}
