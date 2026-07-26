import 'dart:typed_data';

import 'package:billing_baba/shared/attachments/attachment_sync_helper.dart';
import 'package:billing_baba/shared/media/media_upload_client.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:file_picker/file_picker.dart';

Future<SaleFormAttachment?> pickTransactionAttachment({
  required bool imagesOnly,
}) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: imagesOnly
        ? const ['png', 'jpg', 'jpeg', 'webp']
        : const ['png', 'jpg', 'jpeg', 'webp', 'pdf'],
    withData: true,
  );

  final file = result?.files.single;
  if (file == null || file.bytes == null) return null;

  final mime = mimeTypeFromFilename(file.name);
  if (!isAllowedMime(mime, attachmentAllowedMimes)) return null;
  if (file.bytes!.length > attachmentMaxBytes) return null;

  final isImage = isImageMime(mime);
  if (imagesOnly && !isImage) return null;

  return SaleFormAttachment.create(
    name: file.name,
    mimeType: mime,
    localBytes: Uint8List.fromList(file.bytes!),
    isImage: isImage,
  );
}
