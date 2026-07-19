import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/settings/models/whatsapp_settings.dart';

class WhatsAppSettingsRepository {
  WhatsAppSettingsRepository(this._storage, this._businessId);

  final StorageService _storage;
  final String _businessId;

  String get _key => '${StorageKeys.whatsappSettings}_$_businessId.enabled';

  Future<WhatsAppSettings> load() async {
    final raw = _storage.read(_key);
    if (raw == null) return const WhatsAppSettings.defaults();
    return WhatsAppSettings(enabled: raw == 'true');
  }

  Future<void> save(WhatsAppSettings settings) async {
    await _storage.write(_key, settings.enabled ? 'true' : 'false');
  }
}
