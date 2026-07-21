import 'package:billing_baba/core/attachments/document_attachment_service.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:flutter/foundation.dart';

/// Uploads local-only attachments after a transaction receives an ID.
Future<List<SaleFormAttachment>> syncPendingAttachments({
  required DocumentAttachmentService service,
  required String entityType,
  required String entityId,
  required List<SaleFormAttachment> attachments,
}) async {
  final synced = <SaleFormAttachment>[];

  for (final attachment in attachments) {
    if (attachment.syncStatus == AttachmentSyncStatus.synced) {
      synced.add(attachment);
      continue;
    }

    final bytes = attachment.localBytes;
    if (bytes == null || attachment.mimeType == null) {
      synced.add(attachment);
      continue;
    }

    final uploaded = await service.upload(
      entityType: entityType,
      entityId: entityId,
      bytes: bytes,
      mimeType: attachment.mimeType!,
      fileName: attachment.displayName,
      replacesAttachmentId: attachment.replacesRemoteId,
    );
    synced.add(uploaded);
  }

  return synced;
}

bool attachmentListsEqual(
  List<SaleFormAttachment> a,
  List<SaleFormAttachment> b,
) => listEquals(a, b);

bool isImageMime(String mimeType) => mimeType.startsWith('image/');

bool isPdfMime(String mimeType) => mimeType == 'application/pdf';

const attachmentAllowedMimes = {
  'image/png',
  'image/jpeg',
  'image/webp',
  'application/pdf',
};

const attachmentMaxBytes = 10 * 1024 * 1024;
