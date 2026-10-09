import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/settings/models/gst_tax_settings.dart';

class GstTaxSettingsRepository {
  GstTaxSettingsRepository(this._storage, this._businessId);

  final StorageService _storage;
  final String _businessId;

  String get _key => '${StorageKeys.gstTaxSettings}_$_businessId';

  Future<GstTaxSettings> load() async {
    final raw = _storage.read(_key);
    if (raw == null || raw.isEmpty) return GstTaxSettings.defaults();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return GstTaxSettings.defaults();
      return GstTaxSettings.fromJson(Map<String, dynamic>.from(decoded));
    } on Object {
      return GstTaxSettings.defaults();
    }
  }

  Future<void> save(GstTaxSettings settings) async {
    await _storage.write(_key, jsonEncode(settings.toJson()));
  }
}
