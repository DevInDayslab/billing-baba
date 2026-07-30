import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';

class ItemSettingsRepository {
  ItemSettingsRepository(this._storageService, this._businessId);

  final StorageService _storageService;
  final String _businessId;

  String get _key => '${StorageKeys.itemSettings}_$_businessId';

  Future<ItemSettings> load() async {
    final raw = _storageService.read(_key);
    if (raw == null || raw.isEmpty) {
      return ItemSettings.defaults();
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return ItemSettings.defaults();
      }
      return ItemSettings.fromJson(decoded);
    } on Object {
      return ItemSettings.defaults();
    }
  }

  Future<void> save(ItemSettings settings) async {
    await _storageService.write(_key, jsonEncode(settings.toJson()));
  }
}
