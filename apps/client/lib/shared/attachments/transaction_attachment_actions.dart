import 'dart:async';

import 'package:billing_baba/shared/attachments/attachment_offline_metadata_store.dart';
import 'package:billing_baba/shared/attachments/attachment_picker.dart';
import 'package:billing_baba/shared/attachments/attachment_sync_helper.dart';
import 'package:billing_baba/shared/attachments/document_attachment_providers.dart';
import 'package:billing_baba/shared/attachments/document_attachment_service.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_form_attachments_section.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

({List<SaleFormAttachment> images, List<SaleFormAttachment> documents})
splitTransactionAttachments(List<SaleFormAttachment> attachments) {
  return (
    images: attachments.where((attachment) => attachment.isImage).toList(),
    documents: attachments.where((attachment) => !attachment.isImage).toList(),
  );
}

bool hasPendingTransactionAttachments(
  List<SaleFormAttachment> images,
  List<SaleFormAttachment> documents,
) {
  return [...images, ...documents].any(
    (attachment) =>
        attachment.syncStatus != AttachmentSyncStatus.synced &&
        attachment.localBytes != null,
  );
}

Future<DocumentAttachmentService?> readDocumentAttachmentService(
  WidgetRef ref,
) async {
  return ref.read(documentAttachmentServiceProvider.future);
}

Future<DocumentAttachmentService?> readDocumentAttachmentServiceFromRef(
  Ref ref,
) async {
  return ref.read(documentAttachmentServiceProvider.future);
}

Future<({List<SaleFormAttachment> images, List<SaleFormAttachment> documents})>
loadTransactionAttachments(
  Ref ref, {
  required String entityType,
  required String entityId,
}) async {
  try {
    final service = await readDocumentAttachmentServiceFromRef(ref);
    if (service == null) {
      return (
        images: <SaleFormAttachment>[],
        documents: <SaleFormAttachment>[],
      );
    }
    final attachments = await service.fetchAttachments(
      entityType: entityType,
      entityId: entityId,
    );
    return splitTransactionAttachments(attachments);
  } on Object {
    return (images: <SaleFormAttachment>[], documents: <SaleFormAttachment>[]);
  }
}

Future<
  ({
    List<SaleFormAttachment> images,
    List<SaleFormAttachment> documents,
  })?
>
syncTransactionAttachments(
  Ref ref, {
  required String entityType,
  required String entityId,
  required List<SaleFormAttachment> images,
  required List<SaleFormAttachment> documents,
}) async {
  if (!hasPendingTransactionAttachments(images, documents)) return null;

  final service = await readDocumentAttachmentServiceFromRef(ref);
  if (service == null) return null;

  final synced = await syncPendingAttachments(
    service: service,
    entityType: entityType,
    entityId: entityId,
    attachments: [...images, ...documents],
  );
  await AttachmentOfflineMetadataStore.create().then(
    (store) => store.clear(entityType, entityId),
  );
  return splitTransactionAttachments(synced);
}

Future<void> persistOfflineAttachmentMetadata({
  required String entityType,
  required String entityId,
  required List<SaleFormAttachment> images,
  required List<SaleFormAttachment> documents,
}) async {
  final pending = [...images, ...documents].where(
    (attachment) => attachment.syncStatus == AttachmentSyncStatus.local,
  );
  if (pending.isEmpty) return;

  final store = await AttachmentOfflineMetadataStore.create();
  await store.save(
    entityType,
    entityId,
    pending
        .map(
          (attachment) => offlineAttachmentMetadata(
            id: attachment.id,
            name: attachment.displayName,
            mimeType: attachment.mimeType ?? 'application/octet-stream',
            isImage: attachment.isImage,
            localBytes: attachment.localBytes,
          ),
        )
        .toList(),
  );
}

Future<void> transactionAddImage({
  required BuildContext context,
  required WidgetRef ref,
  required String? entityType,
  required String? entityId,
  required void Function(SaleFormAttachment attachment) onAdded,
}) async {
  final picked = await pickTransactionAttachment(imagesOnly: true);
  if (picked == null) return;

  if (entityType != null &&
      entityId != null &&
      entityId.isNotEmpty &&
      picked.localBytes != null &&
      picked.mimeType != null) {
    try {
      final service = await readDocumentAttachmentService(ref);
      if (service == null) {
        onAdded(picked);
        return;
      }
      final uploaded = await service.upload(
        entityType: entityType,
        entityId: entityId,
        bytes: picked.localBytes!,
        mimeType: picked.mimeType!,
        fileName: picked.displayName,
      );
      onAdded(uploaded);
      return;
    } on Exception catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $error')),
        );
      }
      return;
    }
  }

  onAdded(picked);
}

Future<void> transactionAddDocument({
  required BuildContext context,
  required WidgetRef ref,
  required String? entityType,
  required String? entityId,
  required void Function(SaleFormAttachment attachment) onAdded,
}) async {
  final picked = await pickTransactionAttachment(imagesOnly: false);
  if (picked == null) return;

  if (entityType != null &&
      entityId != null &&
      entityId.isNotEmpty &&
      picked.localBytes != null &&
      picked.mimeType != null) {
    try {
      final service = await readDocumentAttachmentService(ref);
      if (service == null) {
        onAdded(picked);
        return;
      }
      final uploaded = await service.upload(
        entityType: entityType,
        entityId: entityId,
        bytes: picked.localBytes!,
        mimeType: picked.mimeType!,
        fileName: picked.displayName,
      );
      onAdded(uploaded);
      return;
    } on Exception catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $error')),
        );
      }
      return;
    }
  }

  onAdded(picked);
}

Future<void> transactionRemoveAttachment({
  required WidgetRef ref,
  required List<SaleFormAttachment> attachments,
  required String id,
  required void Function(String id) onRemoved,
}) async {
  final attachment = attachments.cast<SaleFormAttachment?>().firstWhere(
    (item) => item?.id == id,
    orElse: () => null,
  );
  if (attachment?.remoteId != null) {
    try {
      final service = await readDocumentAttachmentService(ref);
      await service?.delete(attachment!);
    } on Object {
      // Local state still removed so the user can retry upload later.
    }
  }
  if (attachment != null &&
      attachment.isImage &&
      normalizeImageUrl(attachment.fileUrl) != null) {
    unawaited(
      ref
          .read(imageServiceProvider)
          .invalidateImage(
            url: attachment.fileUrl,
            cacheKey: buildImageCacheKey(fallbackUrl: attachment.fileUrl),
          ),
    );
  }
  onRemoved(id);
}

Future<void> transactionRenameAttachment({
  required WidgetRef ref,
  required List<SaleFormAttachment> attachments,
  required String id,
  required String name,
  required void Function(String id, String name) onRenamed,
}) async {
  final attachment = attachments.cast<SaleFormAttachment?>().firstWhere(
    (item) => item?.id == id,
    orElse: () => null,
  );
  if (attachment?.remoteId != null) {
    try {
      final service = await readDocumentAttachmentService(ref);
      final renamed = await service?.rename(attachment!, name);
      if (renamed != null) {
        onRenamed(id, renamed.displayName);
        return;
      }
    } on Object {
      // Fall back to local rename.
    }
  }
  onRenamed(id, name);
}

Widget transactionAttachmentsSection({
  required BuildContext context,
  required WidgetRef ref,
  required String entityType,
  required String? entityId,
  required String description,
  required List<SaleFormAttachment> images,
  required List<SaleFormAttachment> documents,
  required ValueChanged<String> onDescriptionChanged,
  required void Function(SaleFormAttachment attachment) addImage,
  required void Function(SaleFormAttachment attachment) addDocument,
  required ValueChanged<String> removeImage,
  required ValueChanged<String> removeDocument,
  required void Function(String id, String name) updateImage,
  required void Function(String id, String name) updateDocument,
}) {
  final attachmentService = ref.watch(documentAttachmentServiceProvider).value;
  return SaleFormAttachmentsSection(
    description: description,
    images: images,
    documents: documents,
    entityType: entityType,
    entityId: entityId,
    attachmentService: attachmentService,
    onDescriptionChanged: onDescriptionChanged,
    onAddImage: () => transactionAddImage(
      context: context,
      ref: ref,
      entityType: entityType,
      entityId: entityId,
      onAdded: addImage,
    ),
    onRemoveImage: (id) => transactionRemoveAttachment(
      ref: ref,
      attachments: images,
      id: id,
      onRemoved: removeImage,
    ),
    onUpdateImage: (id, name) => transactionRenameAttachment(
      ref: ref,
      attachments: images,
      id: id,
      name: name,
      onRenamed: updateImage,
    ),
    onAddDocument: () => transactionAddDocument(
      context: context,
      ref: ref,
      entityType: entityType,
      entityId: entityId,
      onAdded: addDocument,
    ),
    onRemoveDocument: (id) => transactionRemoveAttachment(
      ref: ref,
      attachments: documents,
      id: id,
      onRemoved: removeDocument,
    ),
    onUpdateDocument: (id, name) => transactionRenameAttachment(
      ref: ref,
      attachments: documents,
      id: id,
      name: name,
      onRenamed: updateDocument,
    ),
  );
}
