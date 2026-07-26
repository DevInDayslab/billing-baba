/// Keys embedded in queue payload for push contract fields (stripped before
/// sending domain `payload` to the server).
abstract final class SyncJobPayloadMeta {
  static const baseSyncVersionKey = '_base_sync_version';
  static const clientUpdatedAtKey = '_client_updated_at';

  static Map<String, dynamic> withMeta(
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
