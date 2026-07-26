/// Pure bootstrap gate — decision only; does not call POST /bootstrap.
class BootstrapDecision {
  const BootstrapDecision({
    required this.needsBootstrap,
    required this.reason,
  });

  /// Heuristic from local metadata + server status (no network bootstrap).
  factory BootstrapDecision.evaluate({
    required String? businessId,
    required String? pullCursor,
    required DateTime? bootstrappedAt,
    required int localSchemaVersion,
    required int? lastServerSchemaVersion,
    required int? serverSchemaVersion,
  }) {
    if (businessId == null || businessId.isEmpty) {
      return const BootstrapDecision(
        needsBootstrap: true,
        reason: 'no_business_selected',
      );
    }
    if (bootstrappedAt == null || pullCursor == null || pullCursor.isEmpty) {
      return const BootstrapDecision(
        needsBootstrap: true,
        reason: 'no_local_cursor',
      );
    }
    if (serverSchemaVersion != null &&
        lastServerSchemaVersion != null &&
        serverSchemaVersion > lastServerSchemaVersion) {
      return const BootstrapDecision(
        needsBootstrap: true,
        reason: 'server_schema_ahead',
      );
    }
    if (serverSchemaVersion != null &&
        serverSchemaVersion > localSchemaVersion &&
        lastServerSchemaVersion == null) {
      return const BootstrapDecision(
        needsBootstrap: true,
        reason: 'schema_unrecorded',
      );
    }
    return BootstrapDecision.ready;
  }

  static const ready = BootstrapDecision(
    needsBootstrap: false,
    reason: 'steady_state',
  );

  final bool needsBootstrap;
  final String reason;
}
