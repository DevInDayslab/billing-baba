import 'dart:typed_data';

import 'package:billing_baba/shared/media/media_upload_client.dart';
import 'package:billing_baba/shared/media/prepare_media_upload_bytes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

const Set<String> kDefaultMediaImageMimes = {
  'image/png',
  'image/jpeg',
  'image/webp',
};
const int kDefaultMediaImageMaxBytes = 2 * 1024 * 1024;

/// Shared pick + validate flow used by Business Profile and Item Images.
Future<({Uint8List bytes, String mimeType})?> pickMediaImageBytes({
  required BuildContext context,
  Set<String> allowedMimes = kDefaultMediaImageMimes,
  int maxBytes = kDefaultMediaImageMaxBytes,
}) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: _extensionsForMimes(allowedMimes),
    withData: true,
  );

  final file = result?.files.single;
  if (file == null || file.bytes == null) return null;

  final mime = mimeTypeFromFilename(file.name);
  if (!isAllowedMime(mime, allowedMimes)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unsupported file type: ${file.name}')),
      );
    }
    return null;
  }

  if (file.bytes!.length > maxBytes) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'File is too large (max ${(maxBytes / (1024 * 1024)).toStringAsFixed(0)} MB)',
          ),
        ),
      );
    }
    return null;
  }

  return (bytes: file.bytes!, mimeType: mime);
}

/// Pick, then downscale for a faster upload — same pipeline as Business Profile.
Future<({Uint8List bytes, String mimeType, Uint8List previewBytes})?>
pickAndPrepareMediaImage({
  required BuildContext context,
  Set<String> allowedMimes = kDefaultMediaImageMimes,
  int maxBytes = kDefaultMediaImageMaxBytes,
}) async {
  final picked = await pickMediaImageBytes(
    context: context,
    allowedMimes: allowedMimes,
    maxBytes: maxBytes,
  );
  if (picked == null) return null;

  final prepared = await prepareMediaUploadBytes(
    bytes: picked.bytes,
    mimeType: picked.mimeType,
  );

  return (
    bytes: prepared.bytes,
    mimeType: prepared.mimeType,
    previewBytes: picked.bytes,
  );
}

List<String> _extensionsForMimes(Set<String> mimes) {
  final extensions = <String>[];
  if (mimes.contains('image/png')) extensions.add('png');
  if (mimes.contains('image/jpeg')) {
    extensions.addAll(['jpg', 'jpeg']);
  }
  if (mimes.contains('image/webp')) extensions.add('webp');
  return extensions;
}
