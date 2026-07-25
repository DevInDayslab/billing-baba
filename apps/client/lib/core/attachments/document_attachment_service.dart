import 'dart:typed_data';

import 'package:billing_baba/core/attachments/document_attachment_repository.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:uuid/uuid.dart';

class DocumentAttachmentService {
  DocumentAttachmentService(this._repository);

  final DocumentAttachmentRepository _repository;

  Future<List<SaleFormAttachment>> fetchAttachments({
    required String entityType,
    required String entityId,
  }) async {
    final rows = await _repository.list(
      entityType: entityType,
      entityId: entityId,
    );
    return rows.map(SaleFormAttachment.fromApi).toList();
  }

  Future<SaleFormAttachment> upload({
    required String entityType,
    required String entityId,
    required Uint8List bytes,
    required String mimeType,
    required String fileName,
    String? replacesAttachmentId,
  }) async {
    final result = await _repository.upload(
      entityType: entityType,
      entityId: entityId,
      bytes: bytes,
      mimeType: mimeType,
      fileName: fileName,
      replacesAttachmentId: replacesAttachmentId,
    );
    return SaleFormAttachment.fromApi(result);
  }

  Future<void> delete(SaleFormAttachment attachment) async {
    if (attachment.remoteId == null) return;
    await _repository.delete(attachment.remoteId!);
  }

  Future<String> resolveDownloadUrl(SaleFormAttachment attachment) async {
    if (attachment.remoteId == null) {
      throw StateError('Attachment is not synced');
    }
    final result = await _repository.getDownloadUrl(attachment.remoteId!);
    return result['download_url'] as String? ?? '';
  }

  Future<SaleFormAttachment> rename(
    SaleFormAttachment attachment,
    String fileName,
  ) async {
    if (attachment.remoteId == null) {
      return attachment.copyWith(name: fileName);
    }
    final result = await _repository.rename(
      attachmentId: attachment.remoteId!,
      fileName: fileName,
    );
    return SaleFormAttachment.fromApi(result);
  }

  SaleFormAttachment createLocal({
    required String name,
    required String mimeType,
    required Uint8List bytes,
    required bool isImage,
  }) {
    return SaleFormAttachment(
      id: const Uuid().v4(),
      name: name,
      mimeType: mimeType,
      localBytes: bytes,
      isImage: isImage,
    );
  }
}
