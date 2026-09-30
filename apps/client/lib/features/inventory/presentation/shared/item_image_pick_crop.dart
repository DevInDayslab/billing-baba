import 'dart:typed_data';

import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/desktop_add_item_image_editor_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_item_image_editor_screen.dart';
import 'package:billing_baba/shared/media/pick_media_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const _maxItemImages = 20;

/// Picks image(s), opens crop UI, returns JPEG-ready bytes ready for upload.
Future<List<Uint8List>> pickItemImagesForUpload(
  BuildContext context, {
  required int existingCount,
  int maxImages = _maxItemImages,
}) async {
  final remaining = maxImages - existingCount;
  if (remaining <= 0) return const [];

  if (AppPlatform.current.isDesktop) {
    final picked = await pickMediaImageBytes(context: context);
    if (picked == null || !context.mounted) return const [];

    final result = await showDesktopAddItemImageEditorDialog(
      context,
      initialBytes: picked.bytes,
      maxNewImages: remaining,
    );
    if (result is ItemImageEditorSaved) return result.images;
    return const [];
  }

  final bytes = await pickRawItemImageBytes(context);
  if (bytes == null || !context.mounted) return const [];

  final cropped = await Navigator.of(context, rootNavigator: true).push<Uint8List>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => MobileItemImageEditorScreen(imageBytes: bytes),
    ),
  );
  return cropped != null ? [cropped] : const [];
}

/// Outcome of re-opening the desktop crop editor for an existing pending image.
sealed class ItemImageBytesCropResult {
  const ItemImageBytesCropResult();
}

final class ItemImageBytesCropUpdated extends ItemImageBytesCropResult {
  const ItemImageBytesCropUpdated(this.bytes);

  final Uint8List bytes;
}

final class ItemImageBytesCropRemoved extends ItemImageBytesCropResult {
  const ItemImageBytesCropRemoved();
}

/// Crop a single in-memory image (desktop editor).
Future<ItemImageBytesCropResult?> cropItemImageBytes(
  BuildContext context, {
  required Uint8List imageBytes,
}) async {
  if (!AppPlatform.current.isDesktop) {
    final cropped = await Navigator.of(context, rootNavigator: true).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MobileItemImageEditorScreen(imageBytes: imageBytes),
      ),
    );
    return cropped == null ? null : ItemImageBytesCropUpdated(cropped);
  }

  final result = await showDesktopAddItemImageEditorDialog(
    context,
    initialBytes: imageBytes,
    maxNewImages: 1,
  );
  return switch (result) {
    null => null,
    ItemImageEditorRemoved() => const ItemImageBytesCropRemoved(),
    ItemImageEditorSaved(:final images) =>
      images.isEmpty ? null : ItemImageBytesCropUpdated(images.first),
  };
}

/// Gallery-only pick on mobile (no camera sheet).
Future<Uint8List?> pickRawItemImageBytes(BuildContext context) async {
  if (AppPlatform.current.isDesktop) {
    final picked = await pickMediaImageBytes(context: context);
    return picked?.bytes;
  }

  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 92,
  );
  if (picked == null) return null;
  return picked.readAsBytes();
}
