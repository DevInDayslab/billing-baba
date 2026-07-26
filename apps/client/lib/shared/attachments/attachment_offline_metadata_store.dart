import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists pending attachment metadata locally until a transaction is saved/synced.
class AttachmentOfflineMetadataStore {
  AttachmentOfflineMetadataStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<AttachmentOfflineMetadataStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AttachmentOfflineMetadataStore(prefs);
  }

  String _key(String entityType, String entityId) =>
      'attachment_meta_${entityType}_$entityId';

  Future<void> save(
    String entityType,
    String entityId,
    List<Map<String, dynamic>> items,
  ) async {
    await _prefs.setString(_key(entityType, entityId), jsonEncode(items));
  }

  List<Map<String, dynamic>> load(String entityType, String entityId) {
    final raw = _prefs.getString(_key(entityType, entityId));
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> clear(String entityType, String entityId) async {
    await _prefs.remove(_key(entityType, entityId));
  }
}

Map<String, dynamic> offlineAttachmentMetadata({
  required String id,
  required String name,
  required String mimeType,
  required bool isImage,
  Uint8List? localBytes,
}) {
  return {
    'id': id,
    'name': name,
    'mime_type': mimeType,
    'is_image': isImage,
    if (localBytes != null) 'byte_length': localBytes.length,
  };
}
