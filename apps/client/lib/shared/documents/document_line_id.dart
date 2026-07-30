import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

/// Sync `entity_id` and local line PKs must be UUIDs (API validates with z.uuid).
String newDocumentLineId() => _uuid.v4();

bool isDocumentUuid(String value) => _uuidPattern.hasMatch(value.trim());

/// Keeps an existing UUID; otherwise allocates a fresh one.
String ensureDocumentLineId(String? candidate) {
  final value = candidate?.trim() ?? '';
  if (value.isNotEmpty && isDocumentUuid(value)) return value;
  return newDocumentLineId();
}
