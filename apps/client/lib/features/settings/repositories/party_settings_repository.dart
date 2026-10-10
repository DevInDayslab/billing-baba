import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/settings/models/party_settings.dart';

class PartySettingsRepository {
  PartySettingsRepository(this._storage, this._businessId);

  final StorageService _storage;
  final String _businessId;

  String get _settingsKey => '${StorageKeys.partySettings}_$_businessId';

  Future<PartySettings> load() async {
    final raw = _storage.read(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return PartySettings.defaults();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return PartySettings.defaults();
      }
      return PartySettings.fromJson(decoded);
    } on Object {
      return PartySettings.defaults();
    }
  }

  Future<void> save(PartySettings settings) async {
    await _storage.write(_settingsKey, jsonEncode(settings.toJson()));
  }
}
