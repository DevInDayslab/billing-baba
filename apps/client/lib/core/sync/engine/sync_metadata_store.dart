import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';

/// Client sync protocol schema generation (Drift ↔ PG logical gen).
const kSyncLocalSchemaVersion = 1;

const _kSyncZeroUuid = '00000000-0000-0000-0000-000000000000';

/// Opaque pull cursor for “beginning of time” (matches API `cursor.ts`).
String epochSyncCursor() {
  final payload = jsonEncode({
    't': DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toIso8601String(),
    'i': _kSyncZeroUuid,
  });
  return base64Url.encode(utf8.encode(payload)).replaceAll('=', '');
}

/// Preference-backed sync metadata (cursor / bootstrap) — no Drift table.
class SyncMetadataStore {
  SyncMetadataStore(this._storage);

  final StorageService _storage;

  String? get pullCursor {
    final value = _storage.read(StorageKeys.syncPullCursor);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  DateTime? get bootstrappedAt {
    final raw = _storage.read(StorageKeys.syncBootstrappedAt);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  int get localSchemaVersion {
    final raw = _storage.read(StorageKeys.syncLocalSchemaVersion);
    if (raw == null || raw.isEmpty) return kSyncLocalSchemaVersion;
    return int.tryParse(raw) ?? kSyncLocalSchemaVersion;
  }

  int? get lastServerSchemaVersion {
    final raw = _storage.read(StorageKeys.syncLastServerSchemaVersion);
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  Future<void> setPullCursor(String cursor) =>
      _storage.write(StorageKeys.syncPullCursor, cursor);

  Future<void> setBootstrappedAt(DateTime at) =>
      _storage.write(StorageKeys.syncBootstrappedAt, at.toUtc().toIso8601String());

  Future<void> setLocalSchemaVersion(int version) =>
      _storage.write(StorageKeys.syncLocalSchemaVersion, '$version');

  Future<void> setLastServerSchemaVersion(int version) =>
      _storage.write(StorageKeys.syncLastServerSchemaVersion, '$version');

  Future<void> clearBootstrapState() async {
    await _storage.remove(StorageKeys.syncPullCursor);
    await _storage.remove(StorageKeys.syncBootstrappedAt);
    await _storage.remove(StorageKeys.syncLastServerSchemaVersion);
  }
}
