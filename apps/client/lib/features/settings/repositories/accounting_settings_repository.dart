import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/settings/models/accounting_settings.dart';

class AccountingSettingsRepository {
  AccountingSettingsRepository(this._storage, this._businessId);

  final StorageService _storage;
  final String _businessId;

  String get _settingsKey => '${StorageKeys.accountingSettings}_$_businessId';

  Future<AccountingSettings> load() async {
    final raw = _storage.read(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return AccountingSettings.defaults();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return AccountingSettings.defaults();
      }
      return AccountingSettings.fromJson(decoded);
    } on Object {
      return AccountingSettings.defaults();
    }
  }

  Future<void> save(AccountingSettings settings) async {
    await _storage.write(_settingsKey, jsonEncode(settings.toJson()));
  }
}
