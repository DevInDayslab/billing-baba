import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/shared/attachments/attachment_sync_helper.dart';
import 'package:billing_baba/shared/media/media_upload_client.dart';
import 'package:file_picker/file_picker.dart';

Future<SaleFormAttachment?> pickTransactionAttachment({
  required bool imagesOnly,
}) async {
  final picked = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: imagesOnly
        ? const ['png', 'jpg', 'jpeg', 'webp']
        : const [
            'png',
            'jpg',
            'jpeg',
            'webp',
            'pdf',
            'txt',
            'doc',
            'docx',
            'xls',
            'xlsx',
          ],
  );

  if (picked.isEmpty) return null;
  final file = picked.single;

  final bytes = await file.readAsBytes();
  if (bytes.isEmpty) return null;

  final mime = mimeTypeFromFilename(file.name);
  if (!isAllowedMime(mime, attachmentAllowedMimes)) return null;
  if (bytes.length > attachmentMaxBytes) return null;

  final isImage = isImageMime(mime);
  if (imagesOnly && !isImage) return null;

  return SaleFormAttachment.create(
    name: file.name,
    mimeType: mime,
    localBytes: bytes,
    isImage: isImage,
  );
}
