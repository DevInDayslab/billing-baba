import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_form_attachments_section.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists pending attachment metadata and bytes locally until save/sync.
class AttachmentOfflineMetadataStore {
  AttachmentOfflineMetadataStore(this._prefs, this._bytesDir);

  final SharedPreferences _prefs;
  final Directory _bytesDir;

  static Future<AttachmentOfflineMetadataStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    final base = await getApplicationSupportDirectory();
    final bytesDir = Directory(
      p.join(base.path, 'billing_baba', 'pending_attachments'),
    );
    if (!await bytesDir.exists()) {
      await bytesDir.create(recursive: true);
    }
    return AttachmentOfflineMetadataStore(prefs, bytesDir);
  }

  String _metaKey(String entityType, String entityId) =>
      'attachment_meta_${entityType}_$entityId';

  String _bytesPath(String entityType, String entityId, String attachmentId) =>
      p.join(_bytesDir.path, '${entityType}_${entityId}_$attachmentId.bin');

  Future<void> save(
    String entityType,
    String entityId,
    List<Map<String, dynamic>> items,
  ) async {
    await _prefs.setString(_metaKey(entityType, entityId), jsonEncode(items));
  }

  List<Map<String, dynamic>> loadMetadata(String entityType, String entityId) {
    final raw = _prefs.getString(_metaKey(entityType, entityId));
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> saveBytes({
    required String entityType,
    required String entityId,
    required String attachmentId,
    required Uint8List bytes,
  }) async {
    final file = File(_bytesPath(entityType, entityId, attachmentId));
    await file.writeAsBytes(bytes, flush: true);
  }

  Future<Uint8List?> loadBytes({
    required String entityType,
    required String entityId,
    required String attachmentId,
  }) async {
    final file = File(_bytesPath(entityType, entityId, attachmentId));
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  Future<List<SaleFormAttachment>> loadAttachments({
    required String entityType,
    required String entityId,
  }) async {
    final metadata = loadMetadata(entityType, entityId);
    final attachments = <SaleFormAttachment>[];
    for (final item in metadata) {
      final id = item['id']?.toString();
      if (id == null || id.isEmpty) continue;
      final bytes = await loadBytes(
        entityType: entityType,
        entityId: entityId,
        attachmentId: id,
      );
      attachments.add(
        SaleFormAttachment(
          id: id,
          name: item['name']?.toString() ?? 'attachment',
          mimeType: item['mime_type']?.toString(),
          isImage: item['is_image'] == true,
          localBytes: bytes,
        ),
      );
    }
    return attachments;
  }

  Future<void> clear(String entityType, String entityId) async {
    for (final item in loadMetadata(entityType, entityId)) {
      final id = item['id']?.toString();
      if (id == null) continue;
      final file = File(_bytesPath(entityType, entityId, id));
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _prefs.remove(_metaKey(entityType, entityId));
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
