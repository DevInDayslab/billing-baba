import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/auth/models/account_profile.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/business/models/create_business_request.dart';

class BusinessCache {
  BusinessCache(this._storage);

  final StorageService _storage;

  Future<void> saveBusinesses(
    List<Map<String, dynamic>> businesses, {
    required String accountId,
  }) async {
    await _storage.write(StorageKeys.cachedBusinessesAccountId, accountId);
    await _storage.write(
      StorageKeys.cachedBusinesses,
      jsonEncode(businesses),
    );
  }

  String? readCachedBusinessesAccountId() =>
      _storage.read(StorageKeys.cachedBusinessesAccountId);

  Future<void> clearAll() async {
    await _storage.write(StorageKeys.cachedBusinesses, '[]');
    await _storage.write(StorageKeys.cachedBusinessesAccountId, '');
    await _storage.write(StorageKeys.cachedProfile, '');
    await _storage.write(StorageKeys.lastOpenedBusinessId, '');
    await _storage.write(StorageKeys.cachedBusinessProfile, '');
    await _storage.write(StorageKeys.pendingBusinessCreates, '[]');
  }

  Future<List<Map<String, dynamic>>> readBusinesses() async {
    final raw = _storage.read(StorageKeys.cachedBusinesses);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.cast<Map<String, dynamic>>();
    } on Object catch (_) {
      return [];
    }
  }

  Future<void> saveProfile(AccountProfile profile) async {
    await _storage.write(
      StorageKeys.cachedProfile,
      jsonEncode(profile.toJson()),
    );
  }

  Future<AccountProfile?> readProfile() async {
    final raw = _storage.read(StorageKeys.cachedProfile);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AccountProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object catch (_) {
      return null;
    }
  }

  Future<void> saveLastOpenedBusinessId(String businessId) async {
    await _storage.write(StorageKeys.lastOpenedBusinessId, businessId);
  }

  String? readLastOpenedBusinessId() =>
      _storage.read(StorageKeys.lastOpenedBusinessId);

  Future<void> queuePendingCreate(CreateBusinessRequest request) async {
    final pending = await readPendingCreates();
    pending.add(request.toJson());
    await _storage.write(
      StorageKeys.pendingBusinessCreates,
      jsonEncode(pending),
    );
  }

  Future<List<Map<String, dynamic>>> readPendingCreates() async {
    final raw = _storage.read(StorageKeys.pendingBusinessCreates);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.cast<Map<String, dynamic>>();
    } on Object catch (_) {
      return [];
    }
  }

  Future<void> clearPendingCreates() async {
    await _storage.write(StorageKeys.pendingBusinessCreates, '[]');
  }

  Future<void> saveBusinessProfile(BusinessProfileModel profile) async {
    await _storage.write(
      StorageKeys.cachedBusinessProfile,
      jsonEncode(profile.toJson()),
    );
  }

  Future<BusinessProfileModel?> readBusinessProfile() async {
    final raw = _storage.read(StorageKeys.cachedBusinessProfile);
    if (raw == null || raw.isEmpty) return null;
    try {
      return BusinessProfileModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object catch (_) {
      return null;
    }
  }

  Future<void> updateBusinessListEntry(BusinessProfileModel profile) async {
    final businesses = await readBusinesses();
    if (businesses.isEmpty) return;

    final updated = businesses
        .map(
          (business) => business['id'] == profile.id
              ? {
                  ...business,
                  'name': profile.name,
                  'gstin': profile.gstin,
                  'phone': profile.phone,
                  'email': profile.email,
                  'address': profile.address,
                }
              : business,
        )
        .toList();

    final accountId = readCachedBusinessesAccountId();
    if (accountId == null || accountId.isEmpty) {
      await _storage.write(
        StorageKeys.cachedBusinesses,
        jsonEncode(updated),
      );
      return;
    }

    await saveBusinesses(updated, accountId: accountId);
  }

  Future<void> updateSelectedBusiness(BusinessProfileModel profile) async {
    await saveBusinessProfile(profile);
    await saveLastOpenedBusinessId(profile.id);
  }

  Future<void> removeBusiness(String businessId) async {
    final businesses = await readBusinesses();
    if (businesses.isEmpty) return;

    final updated = businesses
        .where((business) => business['id'] != businessId)
        .toList();

    final accountId = readCachedBusinessesAccountId();
    if (accountId == null || accountId.isEmpty) {
      await _storage.write(
        StorageKeys.cachedBusinesses,
        jsonEncode(updated),
      );
      return;
    }

    await saveBusinesses(updated, accountId: accountId);
  }

  Future<void> clearSelectedBusiness() async {
    await _storage.write(StorageKeys.lastOpenedBusinessId, '');
    await _storage.write(StorageKeys.cachedBusinessProfile, '');
    await _storage.deleteSecure(StorageKeys.selectedBusinessId);
  }

  Future<void> clearBusinessProfile() async {
    await _storage.write(StorageKeys.cachedBusinessProfile, '');
  }
}
