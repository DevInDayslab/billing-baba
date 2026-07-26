import 'dart:convert';

/// Opaque pull cursor helpers (matches API `cursor.ts` encoding).
const kSyncZeroUuid = '00000000-0000-0000-0000-000000000000';

String encodeSyncCursor({required DateTime updatedAt, required String id}) {
  final payload = jsonEncode({
    't': updatedAt.toUtc().toIso8601String(),
    'i': id,
  });
  final b64 = base64Url.encode(utf8.encode(payload));
  return b64.replaceAll('=', '');
}

String watermarkSyncCursor([DateTime? serverTime]) {
  return encodeSyncCursor(
    updatedAt: serverTime ?? DateTime.now().toUtc(),
    id: kSyncZeroUuid,
  );
}

String epochSyncCursor() {
  return encodeSyncCursor(
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    id: kSyncZeroUuid,
  );
}
