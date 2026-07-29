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
///
/// Pull cursor, bootstrap timestamp, and last server schema version are scoped
/// per business. [localSchemaVersion] is device-wide (Drift schema generation).
class SyncMetadataStore {
  SyncMetadataStore(this._storage);

  final StorageService _storage;

  String? pullCursorFor(String businessId) {
    final scoped = _storage.read(StorageKeys.syncPullCursorFor(businessId));
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return _migrateLegacyString(
      businessId: businessId,
      legacyKey: StorageKeys.syncPullCursor,
      scopedKey: StorageKeys.syncPullCursorFor(businessId),
    );
  }

  DateTime? bootstrappedAtFor(String businessId) {
    final raw = _storage.read(StorageKeys.syncBootstrappedAtFor(businessId));
    if (raw != null && raw.isNotEmpty) return DateTime.tryParse(raw);
    final migrated = _migrateLegacyString(
      businessId: businessId,
      legacyKey: StorageKeys.syncBootstrappedAt,
      scopedKey: StorageKeys.syncBootstrappedAtFor(businessId),
    );
    if (migrated == null || migrated.isEmpty) return null;
    return DateTime.tryParse(migrated);
  }

  int get localSchemaVersion {
    final raw = _storage.read(StorageKeys.syncLocalSchemaVersion);
    if (raw == null || raw.isEmpty) return kSyncLocalSchemaVersion;
    return int.tryParse(raw) ?? kSyncLocalSchemaVersion;
  }

  int? lastServerSchemaVersionFor(String businessId) {
    final raw =
        _storage.read(StorageKeys.syncLastServerSchemaVersionFor(businessId));
    if (raw != null && raw.isNotEmpty) return int.tryParse(raw);
    final migrated = _migrateLegacyString(
      businessId: businessId,
      legacyKey: StorageKeys.syncLastServerSchemaVersion,
      scopedKey: StorageKeys.syncLastServerSchemaVersionFor(businessId),
    );
    if (migrated == null || migrated.isEmpty) return null;
    return int.tryParse(migrated);
  }

  Future<void> setPullCursorFor(String businessId, String cursor) =>
      _storage.write(StorageKeys.syncPullCursorFor(businessId), cursor);

  Future<void> setBootstrappedAtFor(String businessId, DateTime at) =>
      _storage.write(
        StorageKeys.syncBootstrappedAtFor(businessId),
        at.toUtc().toIso8601String(),
      );

  Future<void> setLocalSchemaVersion(int version) =>
      _storage.write(StorageKeys.syncLocalSchemaVersion, '$version');

  Future<void> setLastServerSchemaVersionFor(String businessId, int version) =>
      _storage.write(
        StorageKeys.syncLastServerSchemaVersionFor(businessId),
        '$version',
      );

  Future<void> clearBootstrapStateFor(String businessId) async {
    await _storage.remove(StorageKeys.syncPullCursorFor(businessId));
    await _storage.remove(StorageKeys.syncBootstrappedAtFor(businessId));
    await _storage.remove(StorageKeys.syncLastServerSchemaVersionFor(businessId));
  }

  /// One-time migration: copy legacy global cursor/bootstrap to the active business.
  String? _migrateLegacyString({
    required String businessId,
    required String legacyKey,
    required String scopedKey,
  }) {
    final activeBusinessId = _storage.read(StorageKeys.lastOpenedBusinessId);
    if (activeBusinessId != businessId) return null;

    final legacy = _storage.read(legacyKey);
    if (legacy == null || legacy.isEmpty) return null;

    _storage.write(scopedKey, legacy);
    return legacy;
  }

  // Deprecated accessors — use *For(businessId) variants. Kept for backup export
  // callers that resolve businessId separately.

  @Deprecated('Use pullCursorFor(businessId)')
  String? get pullCursor {
    final businessId = _storage.read(StorageKeys.lastOpenedBusinessId);
    if (businessId == null || businessId.isEmpty) return null;
    return pullCursorFor(businessId);
  }

  @Deprecated('Use bootstrappedAtFor(businessId)')
  DateTime? get bootstrappedAt {
    final businessId = _storage.read(StorageKeys.lastOpenedBusinessId);
    if (businessId == null || businessId.isEmpty) return null;
    return bootstrappedAtFor(businessId);
  }

  @Deprecated('Use lastServerSchemaVersionFor(businessId)')
  int? get lastServerSchemaVersion {
    final businessId = _storage.read(StorageKeys.lastOpenedBusinessId);
    if (businessId == null || businessId.isEmpty) return null;
    return lastServerSchemaVersionFor(businessId);
  }

  @Deprecated('Use setPullCursorFor(businessId, cursor)')
  Future<void> setPullCursor(String cursor) async {
    final businessId = _storage.read(StorageKeys.lastOpenedBusinessId);
    if (businessId == null || businessId.isEmpty) return;
    await setPullCursorFor(businessId, cursor);
  }

  @Deprecated('Use setBootstrappedAtFor(businessId, at)')
  Future<void> setBootstrappedAt(DateTime at) async {
    final businessId = _storage.read(StorageKeys.lastOpenedBusinessId);
    if (businessId == null || businessId.isEmpty) return;
    await setBootstrappedAtFor(businessId, at);
  }

  @Deprecated('Use setLastServerSchemaVersionFor(businessId, version)')
  Future<void> setLastServerSchemaVersion(int version) async {
    final businessId = _storage.read(StorageKeys.lastOpenedBusinessId);
    if (businessId == null || businessId.isEmpty) return;
    await setLastServerSchemaVersionFor(businessId, version);
  }

  @Deprecated('Use clearBootstrapStateFor(businessId)')
  Future<void> clearBootstrapState() async {
    final businessId = _storage.read(StorageKeys.lastOpenedBusinessId);
    if (businessId == null || businessId.isEmpty) return;
    await clearBootstrapStateFor(businessId);
  }
}
