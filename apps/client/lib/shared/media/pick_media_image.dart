import 'dart:typed_data';

import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/shared/media/media_upload_client.dart';
import 'package:billing_baba/shared/media/prepare_media_upload_bytes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  if (AppPlatform.current.isMobile) {
    return _pickFromGallery(
      context: context,
      allowedMimes: allowedMimes,
      maxBytes: maxBytes,
    );
  }

  return _pickFromFilePicker(
    context: context,
    allowedMimes: allowedMimes,
    maxBytes: maxBytes,
  );
}

Future<({Uint8List bytes, String mimeType})?> _pickFromGallery({
  required BuildContext context,
  required Set<String> allowedMimes,
  required int maxBytes,
}) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 92,
  );
  if (picked == null) return null;

  final bytes = await picked.readAsBytes();
  final mime = _mimeForPickedImage(picked.name, picked.path);

  if (!isAllowedMime(mime, allowedMimes)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a PNG, JPEG, or WebP image'),
        ),
      );
    }
    return null;
  }

  if (bytes.length > maxBytes) {
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

  return (bytes: bytes, mimeType: mime);
}

Future<({Uint8List bytes, String mimeType})?> _pickFromFilePicker({
  required BuildContext context,
  required Set<String> allowedMimes,
  required int maxBytes,
}) async {
  final picked = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: _extensionsForMimes(allowedMimes),
  );

  if (picked.isEmpty) return null;
  final file = picked.single;

  final bytes = await file.readAsBytes();
  if (bytes.isEmpty) return null;

  final mime = mimeTypeFromFilename(file.name);
  if (!isAllowedMime(mime, allowedMimes)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unsupported file type: ${file.name}')),
      );
    }
    return null;
  }

  if (bytes.length > maxBytes) {
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

  return (bytes: bytes, mimeType: mime);
}

String _mimeForPickedImage(String name, String path) {
  final fromName = mimeTypeFromFilename(name);
  if (fromName != 'application/octet-stream') return fromName;
  final fromPath = mimeTypeFromFilename(path);
  if (fromPath != 'application/octet-stream') return fromPath;
  // Gallery picks with [imageQuality] are typically re-encoded as JPEG.
  return 'image/jpeg';
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
