import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';

/// Clears persisted business and party data when the session changes.
class SessionCacheCleanup {
  SessionCacheCleanup(this._storage);

  final StorageService _storage;

  Future<void> clearAll() async {
    await clearBusinessListCache();
    await clearBusinessScopedData();
  }

  Future<void> clearBusinessListCache() async {
    await _storage.write(StorageKeys.cachedBusinesses, '[]');
    await _storage.write(StorageKeys.cachedBusinessesAccountId, '');
    await _storage.write(StorageKeys.pendingBusinessCreates, '[]');
  }

  Future<void> clearBusinessScopedData() async {
    await _storage.write(StorageKeys.cachedBusinessProfile, '');
    await _storage.write(StorageKeys.cachedProfile, '');
    await _storage.write(StorageKeys.lastOpenedBusinessId, '');
    await _clearPartyCaches();
  }

  Future<void> _clearPartyCaches() async {
    final keys = _storage.preferenceKeys;
    for (final key in keys) {
      if (_isPartyScopedKey(key)) {
        await _storage.remove(key);
      }
    }
  }

  bool _isPartyScopedKey(String key) {
    return key.startsWith('${StorageKeys.cachedParties}_') ||
        key.startsWith('${StorageKeys.partyLocalExtensions}_') ||
        key.startsWith('${StorageKeys.pendingPartyOperations}_') ||
        key.startsWith('${StorageKeys.partyListFilter}_') ||
        key.startsWith('${StorageKeys.selectedPartyId}_') ||
        key.startsWith('${StorageKeys.partyGroupNames}_');
  }
}
