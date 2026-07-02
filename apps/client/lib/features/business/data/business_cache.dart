import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/auth/models/account_profile.dart';
import 'package:billing_baba/features/business/models/create_business_request.dart';

class BusinessCache {
  BusinessCache(this._storage);

  final StorageService _storage;

  Future<void> saveBusinesses(List<Map<String, dynamic>> businesses) async {
    await _storage.write(
      StorageKeys.cachedBusinesses,
      jsonEncode(businesses),
    );
  }

  Future<List<Map<String, dynamic>>> readBusinesses() async {
    final raw = _storage.read(StorageKeys.cachedBusinesses);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
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
    } catch (_) {
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
    } catch (_) {
      return [];
    }
  }

  Future<void> clearPendingCreates() async {
    await _storage.write(StorageKeys.pendingBusinessCreates, '[]');
  }
}
