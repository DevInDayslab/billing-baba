import 'dart:async';
import 'dart:typed_data';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/branding_image_uploader.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:billing_baba/shared/media/media_upload_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _rackPhotoAllowedMimes = {'image/png', 'image/jpeg', 'image/webp'};
const int _rackPhotoMaxBytes = 2 * 1024 * 1024;

class RackPhotoUploader extends ConsumerStatefulWidget {
  const RackPhotoUploader({
    required this.locationId,
    this.photoUrl,
    this.onPhotoChanged,
    super.key,
  });

  final String? locationId;
  final String? photoUrl;
  final ValueChanged<String?>? onPhotoChanged;

  @override
  ConsumerState<RackPhotoUploader> createState() => _RackPhotoUploaderState();
}

class _RackPhotoUploaderState extends ConsumerState<RackPhotoUploader> {
  bool _isUploading = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.photoUrl;
  }

  @override
  void didUpdateWidget(covariant RackPhotoUploader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.photoUrl != oldWidget.photoUrl) {
      _photoUrl = widget.photoUrl;
    }
  }

  Future<({Uint8List bytes, String mimeType})?> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
      withData: true,
    );

    final file = result?.files.single;
    if (file == null || file.bytes == null) return null;

    final mime = mimeTypeFromFilename(file.name);
    if (!isAllowedMime(mime, _rackPhotoAllowedMimes)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unsupported file type: ${file.name}')),
        );
      }
      return null;
    }

    if (file.bytes!.length > _rackPhotoMaxBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image must be 2 MB or smaller')),
        );
      }
      return null;
    }

    return (bytes: file.bytes!, mimeType: mime);
  }

  Future<void> _upload() async {
    final locationId = widget.locationId;
    if (locationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Save the item with a rack location before uploading'),
        ),
      );
      return;
    }

    final picked = await _pickImage();
    if (picked == null) return;

    setState(() => _isUploading = true);
    final previousUrl = _photoUrl;
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final url = await service.uploadRackPhoto(
        locationId: locationId,
        bytes: picked.bytes,
        mimeType: picked.mimeType,
      );
      setState(() => _photoUrl = url);
      widget.onPhotoChanged?.call(url);
      unawaited(
        ref.read(imageServiceProvider).replaceImage(
              oldUrl: previousUrl,
              newUrl: url,
              oldCacheKey: buildImageCacheKey(fallbackUrl: previousUrl),
              newCacheKey: buildImageCacheKey(fallbackUrl: url),
            ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rack photo uploaded successfully')),
        );
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _delete() async {
    final locationId = widget.locationId;
    if (locationId == null) return;

    setState(() => _isUploading = true);
    final previousUrl = _photoUrl;
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.deleteRackPhoto(locationId);
      setState(() => _photoUrl = null);
      widget.onPhotoChanged?.call(null);
      unawaited(
        ref.read(imageServiceProvider).invalidateImage(
              url: previousUrl,
              cacheKey: buildImageCacheKey(fallbackUrl: previousUrl),
            ),
      );
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.locationId == null) {
      return const Text(
        'Save the item with rack/shelf details to add a rack photo.',
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      );
    }

    return BrandingImageUploader(
      label: 'Rack Photo',
      imageUrl: _photoUrl,
      isUploading: _isUploading,
      onUpload: _upload,
      onDelete: _photoUrl != null ? _delete : null,
      height: 120,
    );
  }
}
