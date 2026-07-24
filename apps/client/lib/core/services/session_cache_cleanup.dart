import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';

/// Clears persisted business and party data when the session changes.
class SessionCacheCleanup {
  SessionCacheCleanup(this._storage);

  final StorageService _storage;

  Future<void> clearAll() async {
    await clearBusinessListCache();
    await clearActiveBusinessSession();
    await _clearAllBusinessPreferenceKeys();
  }

  Future<void> clearBusinessListCache() async {
    await _storage.write(StorageKeys.cachedBusinesses, '[]');
    await _storage.write(StorageKeys.cachedBusinessesAccountId, '');
    await _storage.write(StorageKeys.pendingBusinessCreates, '[]');
  }

  /// Clears active-business session markers without deleting per-business caches.
  Future<void> clearActiveBusinessSession() async {
    await _storage.write(StorageKeys.cachedBusinessProfile, '');
    await _storage.write(StorageKeys.cachedProfile, '');
    await _storage.write(StorageKeys.lastOpenedBusinessId, '');
    await _storage.deleteSecure(StorageKeys.selectedBusinessId);
  }

  /// Removes persisted data for a single business (delete or purge).
  Future<void> clearBusinessData(String businessId) async {
    if (businessId.isEmpty) return;

    final keys = _storage.preferenceKeys;
    for (final key in keys) {
      if (_isBusinessScopedKey(key, businessId)) {
        await _storage.remove(key);
      }
    }
  }

  Future<void> _clearAllBusinessPreferenceKeys() async {
    final keys = _storage.preferenceKeys;
    for (final key in keys) {
      if (_isAnyBusinessScopedKey(key)) {
        await _storage.remove(key);
      }
    }
  }

  bool _isBusinessScopedKey(String key, String businessId) {
    final suffix = '_$businessId';
    return key.endsWith(suffix) &&
        (key.startsWith('${StorageKeys.cachedParties}_') ||
            key.startsWith('${StorageKeys.partyLocalExtensions}_') ||
            key.startsWith('${StorageKeys.pendingPartyOperations}_') ||
            key.startsWith('${StorageKeys.partyListFilter}_') ||
            key.startsWith('${StorageKeys.selectedPartyId}_') ||
            key.startsWith('${StorageKeys.partyGroupNames}_') ||
            key.startsWith('${StorageKeys.localItemTierPrices}_') ||
            key.startsWith('${StorageKeys.saleLineItemColumnVisibility}_') ||
            key.startsWith('${StorageKeys.dashboardTasks}_') ||
            key.startsWith('${StorageKeys.dashboardSideWidgets}_') ||
            key.startsWith('${StorageKeys.printSettings}_') ||
            key.startsWith('${StorageKeys.whatsappSettings}_') ||
            key.startsWith('${StorageKeys.transactionMessageSettings}_') ||
            key.startsWith('${StorageKeys.partyReminderSchedule}_'));
  }

  bool _isAnyBusinessScopedKey(String key) {
    return key.startsWith('${StorageKeys.cachedParties}_') ||
        key.startsWith('${StorageKeys.partyLocalExtensions}_') ||
        key.startsWith('${StorageKeys.pendingPartyOperations}_') ||
        key.startsWith('${StorageKeys.partyListFilter}_') ||
        key.startsWith('${StorageKeys.selectedPartyId}_') ||
        key.startsWith('${StorageKeys.partyGroupNames}_') ||
        key.startsWith('${StorageKeys.localItemTierPrices}_') ||
        key.startsWith('${StorageKeys.saleLineItemColumnVisibility}_') ||
        key.startsWith('${StorageKeys.dashboardTasks}_') ||
        key.startsWith('${StorageKeys.dashboardSideWidgets}_') ||
        key.startsWith('${StorageKeys.printSettings}_') ||
        key.startsWith('${StorageKeys.whatsappSettings}_') ||
        key.startsWith('${StorageKeys.transactionMessageSettings}_') ||
        key.startsWith('${StorageKeys.partyReminderSchedule}_');
  }
}
