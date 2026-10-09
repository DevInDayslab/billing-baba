import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/settings/models/general_settings.dart';

class GeneralSettingsRepository {
  GeneralSettingsRepository(this._storage, this._businessId);

  final StorageService _storage;
  final String _businessId;

  String get _settingsKey => '${StorageKeys.generalSettings}_$_businessId';

  String get _lastBackupKey => '${StorageKeys.lastLocalBackupAt}_$_businessId';

  Future<GeneralSettings> load() async {
    final raw = _storage.read(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return GeneralSettings.defaults();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return GeneralSettings.defaults();
      }
      return GeneralSettings.fromJson(decoded);
    } on Object {
      return GeneralSettings.defaults();
    }
  }

  Future<void> save(GeneralSettings settings) async {
    await _storage.write(_settingsKey, jsonEncode(settings.toJson()));
  }

  DateTime? readLastBackupAt() {
    final raw = _storage.read(_lastBackupKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> recordLastBackupAt(DateTime at) async {
    await _storage.write(_lastBackupKey, at.toUtc().toIso8601String());
  }
}
